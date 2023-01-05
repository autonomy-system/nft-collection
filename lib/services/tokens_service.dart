//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'dart:async';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:nft_collection/data/api/indexer_api.dart';
import 'package:nft_collection/data/api/tzkt_api.dart';
import 'package:nft_collection/database/dao/asset_token_dao.dart';
import 'package:nft_collection/database/nft_collection_database.dart';
import 'package:nft_collection/models/asset.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/models/pending_tx_params.dart';
import 'package:nft_collection/models/provenance.dart';
import 'package:nft_collection/nft_collection.dart';
import 'package:nft_collection/services/configuration_service.dart';
import 'package:nft_collection/utils/constants.dart';
import 'package:nft_collection/utils/logging_interceptor.dart';
import 'package:uuid/uuid.dart';

abstract class TokensService {
  Future fetchTokensForAddresses(List<String> addresses);
  Future fetchManualTokens(List<String> indexerIds);
  Future setCustomTokens(List<AssetToken> tokens);
  Future<Stream<int>> refreshTokensInIsolate(
    List<String> addresses,
    List<String> debugTokenIDs,
  );
  Future reindexAddresses(List<String> addresses);
  Future<List<Asset>> fetchLatestAssets(List<String> addresses, int size);
  Future purgeCachedGallery();
  Future postPendingToken(PendingTxParams params);
}

final _isolateScopeInjector = GetIt.asNewInstance();

class TokensServiceImpl extends TokensService {
  final String _indexerUrl;
  late IndexerApi _indexer;
  late TZKTApi _tzkt;
  final NftCollectionDatabase _database;
  final NftCollectionPrefs _configurationService;

  final Map<String, DateTime> _tokenUpdateTime = {};

  static const _stringListEquality = ListEquality<String>();
  static const REFRESH_ALL_TOKENS = 'REFRESH_ALL_TOKENS';
  static const FETCH_TOKENS = 'FETCH_TOKENS';
  static const REINDEX_ADDRESSES = 'REINDEX_ADDRESSES';

  TokensServiceImpl(
      this._indexerUrl, this._database, this._configurationService) {
    final dio = Dio()..interceptors.add(LoggingInterceptor());
    _indexer = IndexerApi(
      dio,
      baseUrl: _indexerUrl,
    );
    _tzkt = TZKTApi(dio);
  }

  SendPort? _sendPort;
  ReceivePort? _receivePort;
  Isolate? _isolate;
  var _isolateReady = Completer<void>();
  StreamController<int>? _refreshAllTokensWorker;
  List<String>? _currentAddresses;
  Map<String, Completer<void>> _fetchTokensCompleters = {};
  final Map<String, Completer<void>> _reindexAddressesCompleters = {};
  Future<void> get isolateReady => _isolateReady.future;

  AssetTokenDao get _assetDao => _database.assetDao;

  Future<void> start() async {
    if (_sendPort != null) return;

    _receivePort = ReceivePort();
    _receivePort!.listen(_handleMessageInMain);

    _isolate = await Isolate.spawn(_isolateEntry, [
      _receivePort!.sendPort,
      _indexerUrl,
    ]);
  }

  Future startIsolateOrWait() async {
    NftCollection.logger.info("[FeedService] startIsolateOrWait");
    if (_sendPort == null) {
      await start();
      await isolateReady;
      //
    } else if (!_isolateReady.isCompleted) {
      await isolateReady;
    }
  }

  void disposeIsolate() {
    NftCollection.logger.info("[TokensService][disposeIsolate] Start");
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _receivePort?.close();
    _currentAddresses = null;
    _isolateReady = Completer<void>();
    _fetchTokensCompleters = {};
    NftCollection.logger.info("[TokensService][disposeIsolate] Done");
  }

  @override
  Future purgeCachedGallery() async {
    disposeIsolate();
    _configurationService.setLatestRefreshTokens(null);
    await _assetDao.removeAllExcludePending();
  }

  Future<List<String>> _getPendingTokenIds() async {
    return (await _database.assetDao.findAllPendingTokens())
        .map((e) => e.id)
        .toList();
  }

  @override
  Future<Stream<int>> refreshTokensInIsolate(
    List<String> addresses,
    List<String> debugTokenIDs,
  ) async {
    if (_currentAddresses != null) {
      if (_currentAddresses?.join(",") == addresses.join(",")) {
        if (_refreshAllTokensWorker != null &&
            !_refreshAllTokensWorker!.isClosed) {
          NftCollection.logger.info("[refreshTokensInIsolate] skip because worker is running");
          return _refreshAllTokensWorker!.stream;
        }
      } else {
        NftCollection.logger.info("[refreshTokensInIsolate] kill the obsolete worker");
        disposeIsolate();
      }
    }

    NftCollection.logger.info("[refreshTokensInIsolate] start");
    await startIsolateOrWait();

    final pendingTokens = await _getPendingTokenIds();
    NftCollection.logger.info("[refreshTokensInIsolate] Pending tokens: "
        "$pendingTokens");
    List<String> tokenIDs = [];

    for (final address in addresses) {
      final ids = await _indexer.getNftIDsByOwner(address);
      await _database.assetDao.deleteAssetsNotInByOwner(ids + pendingTokens, address);
      tokenIDs.addAll(ids);
    }

    await _database.assetDao.deleteAssetsNotIn(tokenIDs + debugTokenIDs + pendingTokens);

    final dbTokenIDs = (await _assetDao.findAllAssetTokenIDs()).toSet();
    final expectedNewTokenIDs = tokenIDs.toSet().difference(dbTokenIDs);
    NftCollection.logger.info(
        "[TokensService] Expected ${expectedNewTokenIDs.length} new tokens");

    _refreshAllTokensWorker = StreamController<int>();
    _currentAddresses = addresses;

    _sendPort?.send([
      REFRESH_ALL_TOKENS,
      addresses,
      expectedNewTokenIDs,
      await _configurationService.getLatestRefreshTokens(),
    ]);
    NftCollection.logger.info("[REFRESH_ALL_TOKENS][start]");

    return _refreshAllTokensWorker!.stream;
  }

  @override
  Future<List<Asset>> fetchLatestAssets(
    List<String> addresses,
    int size,
  ) async {
    if (!_stringListEquality.equals(addresses, _currentAddresses)) {
      disposeIsolate();
    }

    final pendingTokens = await _getPendingTokenIds();
    NftCollection.logger
        .info("[fetchLatestAssets] Pending tokens: $pendingTokens");

    final assetsLists = await Future.wait(
      addresses.map(
            (address) async {
          final rawAssets = await _indexer.getNftTokensByOwner(address, 0, size);
          final assets = mapOwnerAddress(rawAssets, address);
          await insertAssetsWithProvenance(assets, retainOwners: addresses);
          if (assets.length < size && assets.isNotEmpty) {
            final tokenIDs = assets.map((e) => e.id).toList();
            await _database.assetDao
                .deleteAssetsNotInByOwner(tokenIDs + pendingTokens, address);
          }
          return assets;
        },
      ),
    );
    final assets = assetsLists.flattened.toList();

    if (assets.length < size) {
      if (assets.isNotEmpty) {
        final tokenIDs = assets.map((e) => e.id).toList();
        final pendingTokens = await _getPendingTokenIds();
        NftCollection.logger
            .info("[fetchLatestAssets] Pending tokens: $pendingTokens");
        await _database.assetDao.deleteAssetsNotIn(tokenIDs + pendingTokens);
        await _database.provenanceDao.deleteProvenanceNotBelongs(tokenIDs + pendingTokens);
      } else {
        await _database.assetDao.removeAllExcludePending();
        await _database.provenanceDao.removeAll();
      }
    }
    return assets;
  }

  @override
  Future reindexAddresses(List<String> addresses) async {
    await startIsolateOrWait();

    final uuid = const Uuid().v4();
    final completer = Completer();
    _reindexAddressesCompleters[uuid] = completer;

    _sendPort?.send([
      REINDEX_ADDRESSES,
      uuid,
      addresses
    ]);

    NftCollection.logger.info("[reindexAddresses][start] $addresses");
    return completer.future;
  }

  Future<Map<String, DateTime>> _getTezosTokensUpdateTime(
    List<Asset> tokens,
    List<String>? owners,
  ) async {
    if (tokens.isEmpty) return {};
    try {
      final tokenIds = tokens
          .map((e) => e.tokenId)
          .where((e) => e != null)
          .map((e) => e as String)
          .toList();
      final ownerAddresses = tokens
          .map((e) => e.owners.keys)
          .flattened
          .where((owner) => owners?.contains(owner) ?? true)
          .toList();
      final transfers = await _tzkt.getTokenTransfer(
        to: ownerAddresses.join(","),
        tokenIds: tokenIds.join(","),
        select: ["id", "level", "timestamp", "token"].join(","),
      );
      final Map<String, DateTime> result = {};
      for (var tx in transfers) {
        final token = tx.token;
        if (token != null) {
          final indexerId = "tez-${token.contract?.address}-${token.tokenId}";
          result[indexerId] = tx.timestamp;
        }
      }
      return result;
    } catch (e) {
      NftCollection.logger.info("[TokensService] Get token transfer failed $e");
      return {};
    }
  }

  Future insertAssetsWithProvenance(
    List<Asset> assets, {
    List<String>? retainOwners,
  }) async {
    List<AssetToken> tokens = [];
    List<Provenance> provenance = [];

    final fa2Tokens = assets
        .where((token) => token.contractType == "fa2")
        .where((token) => !_tokenUpdateTime.keys.contains(token.id))
        .toList();
    final updateTimes = await _getTezosTokensUpdateTime(
      fa2Tokens,
      retainOwners,
    );
    _tokenUpdateTime.addAll(updateTimes);

    for (var asset in assets) {
      var token = AssetToken.fromAsset(asset);
      token.updateTime = _tokenUpdateTime[token.id] ?? token.lastActivityTime;
      tokens.add(token);
      provenance.addAll(asset.provenance);
    }
    await _database.assetDao.insertAssets(tokens);
    await _database.provenanceDao.insertProvenance(provenance);
  }

  @override
  Future fetchTokensForAddresses(List<String> addresses) async {
    await startIsolateOrWait();

    final uuid = const Uuid().v4();
    final completer = Completer();
    _fetchTokensCompleters[uuid] = completer;

    _sendPort!.send([FETCH_TOKENS, uuid, addresses]);
    NftCollection.logger.info("[FETCH_TOKENS][start] $addresses");

    return completer.future;
  }

  @override
  Future fetchManualTokens(List<String> indexerIds) async {
    final manuallyAssets = (await _indexer.getNftTokens({"ids": indexerIds}));

    //stripe owner for manual asset
    for (var i = 0; i < manuallyAssets.length; i++) {
      manuallyAssets[i].owner = "";
    }

    NftCollection.logger.info("[TokensService] "
        "fetched ${manuallyAssets.length} manual tokens. "
        "IDs: $indexerIds");
    await insertAssetsWithProvenance(manuallyAssets);
  }

  @override
  Future setCustomTokens(List<AssetToken> tokens) async {
    await _database.assetDao.insertAssets(tokens);
  }

  @override
  Future postPendingToken(PendingTxParams params) async {
    await _indexer.postNftPendingToken(params.toJson());
  }

  static void _isolateEntry(List<dynamic> arguments) {
    SendPort sendPort = arguments[0];

    final receivePort = ReceivePort();
    receivePort.listen(_handleMessageInIsolate);

    _setupInjector(arguments[1]);
    sendPort.send(receivePort.sendPort);
    _isolateSendPort = sendPort;
  }

  static void _setupInjector(String indexerUrl) {
    final dio = Dio();
    dio.interceptors.add(LoggingInterceptor());
    _isolateScopeInjector
        .registerLazySingleton(() => IndexerApi(dio, baseUrl: indexerUrl));
    _isolateScopeInjector
        .registerLazySingleton(() => TZKTApi(dio));
  }

  void _handleMessageInMain(dynamic message) async {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();

      return;
    }

    final result = message;
    if (result is FetchTokensSuccess) {
      await insertAssetsWithProvenance(
        result.assets,
        retainOwners: result.addresses,
      );
      NftCollection.logger.info("[${result.key}] receive ${result.assets.length} tokens");

      if (result.key == REFRESH_ALL_TOKENS) {
        if (!result.done) {
          if (_refreshAllTokensWorker != null &&
              !_refreshAllTokensWorker!.isClosed) {
            _refreshAllTokensWorker!.sink.add(1);
          }
        } else {
          _configurationService.setLatestRefreshTokens(DateTime.now());
          _refreshAllTokensWorker?.close();
          NftCollection.logger.info("[REFRESH_ALL_TOKENS][end]");
        }
      } else if (result.key == FETCH_TOKENS) {
        if (result.done) {
          _fetchTokensCompleters[result.uuid]?.complete();
          _fetchTokensCompleters.remove(result.uuid);
          NftCollection.logger.info("[FETCH_TOKENS][end]");
        }
      }
      //
    } else if (result is FetchTokenFailure) {
      // Sentry.captureException(result.exception);

      NftCollection.logger.info("[REFRESH_ALL_TOKENS] end in error ${result.exception}");

      if (result.key == REFRESH_ALL_TOKENS) {
        _refreshAllTokensWorker?.close();
      } else if (result.key == FETCH_TOKENS) {
        _fetchTokensCompleters[result.uuid]?.completeError(result.exception);
        _fetchTokensCompleters.remove(result.uuid);
      }
      //
    } else if (result is ReindexAddressesDone) {
      _reindexAddressesCompleters[result.uuid]?.complete();
      _fetchTokensCompleters.remove(result.uuid);
      NftCollection.logger.info("[reindexAddresses][end]");
      //
    }
  }

  static SendPort? _isolateSendPort;

  static void _handleMessageInIsolate(dynamic message) {
    if (message is List<dynamic>) {
      switch (message[0]) {
        case REFRESH_ALL_TOKENS:
          _refreshAllTokens(REFRESH_ALL_TOKENS, '', message[1], message[2],
              message[3]);
          break;

        case FETCH_TOKENS:
          _refreshAllTokens(
              FETCH_TOKENS, message[1], message[2], {}, null);
          break;

        case REINDEX_ADDRESSES:
          _reindexAddressesInIndexer(message[1], message[2]);
          break;

        default:
          break;
      }
    }
  }

  static void _refreshAllTokens(
      String key,
      String uuid,
      List<String> addresses,
      Set<String> expectedNewTokenIDs,
      DateTime? latestRefreshToken,
      ) async {

    try {

      final isolateIndexerAPI = _isolateScopeInjector<IndexerApi>();

      final Map<String, int> offsetMap = {};
      Set<String> tokenIDs = {};

      while (true) {
        final assetsLists = await Future.wait(
          addresses.map((address) async {
            final assets = await isolateIndexerAPI.getNftTokensByOwner(
                address, offsetMap[address] ?? 0, indexerTokensPageSize);
            return mapOwnerAddress(assets, address);
          }),
        );
        final assets = assetsLists.flattened.toList();
        tokenIDs.addAll(assets.map((e) => e.id));

        if (assets.length < indexerTokensPageSize) {
          _isolateSendPort?.send(FetchTokensSuccess(key, uuid, addresses, assets, true));
          break;
        }

        if (latestRefreshToken != null) {
          expectedNewTokenIDs = expectedNewTokenIDs.difference(tokenIDs);
          if (assets.last.lastActivityTime.compareTo(latestRefreshToken) < 0 &&
              expectedNewTokenIDs.isEmpty) {
            _isolateSendPort?.send(FetchTokensSuccess(key, uuid, addresses, assets, true));
            break;
          }
        }

        _isolateSendPort?.send(FetchTokensSuccess(key, uuid, addresses, assets, false));

        for (int i = 0; i < addresses.length; i++) {
          final address = addresses[i];
          final newAssets = assetsLists[i].length;
          offsetMap[address] = (offsetMap[address] ?? 0) + newAssets;
        }
      }
    } catch (exception) {
      _isolateSendPort?.send(FetchTokenFailure(key, uuid, exception));
    }
  }

  static void _reindexAddressesInIndexer(
      String uuid, List<String> addresses) async {
    final indexerAPI = _isolateScopeInjector<IndexerApi>();
    for (final address in addresses) {
      if (address.startsWith("tz")) {
        indexerAPI.requestIndex({"owner": address, "blockchain": "tezos"});
      } else if (address.startsWith("0x")) {
        indexerAPI.requestIndex({"owner": address});
      }
    }

    _isolateSendPort?.send(ReindexAddressesDone(uuid));
  }
}

List<Asset> mapOwnerAddress(List<Asset> assets, String owner) {
  return assets.map((asset) {
    asset.owner = owner;
    // map balance for missing balance (ETH supported later)
    if (asset.balance == null || asset.balance == 0) {
      asset.balance = asset.owners[owner] ?? 0;
    }
    return asset;
  }).toList();
}

abstract class TokensServiceResult {}

class FetchTokensSuccess extends TokensServiceResult {
  final String key;
  final String uuid;
  final List<String> addresses;
  final List<Asset> assets;
  bool done;

  FetchTokensSuccess(
      this.key, this.uuid, this.addresses, this.assets, this.done);
}

class FetchTokenFailure extends TokensServiceResult {
  final String uuid;
  final String key;
  final Object exception;

  FetchTokenFailure(this.uuid, this.key, this.exception);
}

class ReindexAddressesDone extends TokensServiceResult {
  final String uuid;

  ReindexAddressesDone(this.uuid);
}