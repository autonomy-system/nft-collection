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
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:nft_collection/data/api/indexer_api.dart';
import 'package:nft_collection/database/dao/asset_token_dao.dart';
import 'package:nft_collection/database/nft_collection_database.dart';
import 'package:nft_collection/models/asset.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/models/provenance.dart';
import 'package:nft_collection/nft_collection.dart';
import 'package:nft_collection/services/configuration_service.dart';
import 'package:nft_collection/utils/constants.dart';
import 'package:nft_collection/utils/logging_interceptor.dart';
import 'package:uuid/uuid.dart';

abstract class TokensService {
  Future fetchTokensForAddresses(List<String> addresses);
  Future fetchManualTokens(List<String> indexerIds);
  Future<Stream<int>> refreshTokensInIsolate(
      List<String> addresses, List<String> debugTokenIDs);
  Future reindexAddresses(List<String> addresses);
  Future<List<Asset>> fetchLatestAssets(List<String> addresses, int size);
  Future purgeCachedGallery();
}

final _isolateScopeInjector = GetIt.asNewInstance();

class TokensServiceImpl extends TokensService {
  final String _indexerUrl;
  late IndexerApi _indexer;
  final NftCollectionDatabase _database;
  final NftCollectionPrefs _configurationService;

  static const _stringListEquality = ListEquality<String>();
  static const REFRESH_ALL_TOKENS = 'REFRESH_ALL_TOKENS';
  static const FETCH_TOKENS = 'FETCH_TOKENS';
  static const REINDEX_ADDRESSES = 'REINDEX_ADDRESSES';

  TokensServiceImpl(
      this._indexerUrl, this._database, this._configurationService) {
    _indexer = IndexerApi(Dio(), baseUrl: _indexerUrl);
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
    await _assetDao.removeAll();
  }

  @override
  Future<Stream<int>> refreshTokensInIsolate(
      List<String> addresses, List<String> debugTokenIDs) async {
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

    final tokenIDs = await getTokenIDs(addresses);
    await _database.assetDao.deleteAssetsNotIn(tokenIDs + debugTokenIDs);

    final dbTokenIDs = (await _assetDao.findAllAssetTokenIDs()).toSet();

    _refreshAllTokensWorker = StreamController<int>();
    _currentAddresses = addresses;

    _sendPort?.send([
      REFRESH_ALL_TOKENS,
      addresses,
      tokenIDs.toSet().difference(dbTokenIDs),
      await _configurationService.getLatestRefreshTokens(),
    ]);
    NftCollection.logger.info("[REFRESH_ALL_TOKENS][start]");

    return _refreshAllTokensWorker!.stream;
  }

  @override
  Future<List<Asset>> fetchLatestAssets(
      List<String> addresses, int size) async {
    if (!_stringListEquality.equals(addresses, _currentAddresses)) {
      disposeIsolate();
    }

    var owners = addresses.join(',');
    final assets = await _indexer.getNftTokensByOwner(owners, 0, size);
    await insertAssetsWithProvenance(assets);
    if (assets.length < size) {
      if (assets.isNotEmpty) {
        final tokenIDs = assets.map((e) => e.id).toList();
        await _database.assetDao.deleteAssetsNotIn(tokenIDs);
        await _database.provenanceDao.deleteProvenanceNotBelongs(tokenIDs);
      } else {
        await _database.assetDao.removeAll();
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

  Future insertAssetsWithProvenance(List<Asset> assets) async {
    List<AssetToken> tokens = [];
    List<Provenance> provenance = [];
    for (var asset in assets) {
      var token = AssetToken.fromAsset(asset);
      tokens.add(token);
      provenance.addAll(asset.provenance);
    }
    await _database.assetDao.insertAssets(tokens);
    await _database.provenanceDao.insertProvenance(provenance);
  }

  Future<List<String>> getTokenIDs(List<String> addresses) async {
    return _indexer.getNftIDsByOwner(addresses.join(","));
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
    await insertAssetsWithProvenance(manuallyAssets);
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
  }

  void _handleMessageInMain(dynamic message) async {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();

      return;
    }

    final result = message;
    if (result is FetchTokensSuccess) {
      await insertAssetsWithProvenance(result.assets);
      NftCollection.logger.info("[${result.key}] receive ${result.assets.length} tokens");

      if (result.key == REFRESH_ALL_TOKENS) {
        if (!result.done) {
          _refreshAllTokensWorker?.sink.add(1);
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
      final owners = addresses.join(",");

      final isolateIndexerAPI = _isolateScopeInjector<IndexerApi>();

      var offset = 0;
      Set<String> tokenIDs = {};

      while (true) {
        final assets = await isolateIndexerAPI.getNftTokensByOwner(
            owners, offset, indexerTokensPageSize);
        tokenIDs.addAll(assets.map((e) => e.id));

        if (assets.length < indexerTokensPageSize) {
          _isolateSendPort?.send(FetchTokensSuccess(key, uuid, assets, true));
          break;
        }

        if (latestRefreshToken != null) {
          expectedNewTokenIDs.difference(tokenIDs);
          if (assets.last.lastActivityTime.compareTo(latestRefreshToken) < 0 &&
              expectedNewTokenIDs.isEmpty) {
            _isolateSendPort?.send(FetchTokensSuccess(key, uuid, assets, true));
            break;
          }
        }

        _isolateSendPort?.send(FetchTokensSuccess(key, uuid, assets, false));
        offset += indexerTokensPageSize;
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

abstract class TokensServiceResult {}

class FetchTokensSuccess extends TokensServiceResult {
  final String key;
  final String uuid;
  final List<Asset> assets;
  bool done;

  FetchTokensSuccess(this.key, this.uuid, this.assets, this.done);
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