// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:nft_collection/database/nft_collection_database.dart';
import 'package:nft_collection/models/address_index.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/nft_collection.dart';
import 'package:nft_collection/services/configuration_service.dart';
import 'package:nft_collection/services/tokens_service.dart';
import 'package:nft_collection/utils/constants.dart';
import 'package:nft_collection/utils/list_extentions.dart';

class NftCollectionBlocState {
  final NftLoadingState state;
  final List<AssetToken> tokens;

  final PageKey? nextKey;

  final bool isLoading;

  NftCollectionBlocState({
    required this.state,
    required this.tokens,
    this.nextKey,
    this.isLoading = false,
  });

  NftCollectionBlocState copyWith({
    NftLoadingState? state,
    List<AssetToken>? tokens,
    required PageKey? nextKey,
    bool? isLoading,
  }) {
    return NftCollectionBlocState(
      state: state ?? this.state,
      tokens: tokens ?? this.tokens,
      nextKey: nextKey,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NftCollectionBloc
    extends Bloc<NftCollectionBlocEvent, NftCollectionBlocState>
    with ChangeNotifier {
  final TokensService tokensService;
  final NftCollectionDatabase database;
  final Duration pendingTokenExpire;
  final NftCollectionPrefs prefs;

  static List<AddressIndex> _addresses = [];
  static List<AddressIndex> _hiddenAddresses = [];
  List<String> _debugTokenIds = [];

  static List<AddressIndex> get addresses => _addresses;
  static List<AddressIndex> get hiddenAddresses => _hiddenAddresses;
  List<String> get debugTokenIds => _debugTokenIds;

  static List<String> get activeAddress => addresses
      .map((e) => e.address)
      .toSet()
      .difference(hiddenAddresses.map((e) => e.address).toSet())
      .toList();

  static StreamController<NftCollectionBlocEvent> eventController =
      StreamController<NftCollectionBlocEvent>.broadcast();

  Future<List<String>> fetchManuallyTokens(List<String> indexerIds) async {
    if (indexerIds.isNotEmpty) {
      final assets = await tokensService.fetchManualTokens(indexerIds);
      if (assets.isNotEmpty) {
        add(UpdateTokensEvent(tokens: assets, state: state.state));
      }
    }
    return indexerIds;
  }

  NftCollectionBloc(this.tokensService, this.database, this.prefs,
      {required this.pendingTokenExpire})
      : super(
          NftCollectionBlocState(
            state: NftLoadingState.notRequested,
            tokens: [],
            nextKey: PageKey.init(),
          ),
        ) {
    on<GetTokensByOwnerEvent>((event, emit) async {
      if (state.isLoading) {
        return;
      }
      final currentTokens = state.tokens;
      if (event.pageKey == PageKey.init()) {
        currentTokens.clear();
      }
      state.nextKey?.isLoaded = true;
      emit(state.copyWith(
        isLoading: true,
        nextKey: state.nextKey,
        state: NftLoadingState.loading,
      ));

      const limit = indexerTokensPageSize;
      final lastTime =
          event.pageKey.offset ?? DateTime.now().millisecondsSinceEpoch;
      final id = event.pageKey.id;

      final assetTokens = await database.assetTokenDao
          .findAllAssetTokensByOwners(activeAddress, limit, lastTime, id);

      final isLastPage = assetTokens.length < indexerTokensPageSize;
      PageKey? nextKey;
      if (assetTokens.isNotEmpty) {
        nextKey = PageKey(
          offset: assetTokens.last.lastActivityTime.millisecondsSinceEpoch,
          id: assetTokens.last.id,
        );
      }

      if (isLastPage) {
        emit(state.copyWith(
          tokens: currentTokens + assetTokens,
          nextKey: null,
          isLoading: false,
          state: NftLoadingState.done,
        ));
      } else {
        emit(
          state.copyWith(
            tokens: currentTokens + assetTokens,
            nextKey: nextKey,
            isLoading: false,
            state: NftLoadingState.loading,
          ),
        );
      }
    });
    on<GetTokensBeforeByOwnerEvent>((event, emit) async {
      List<AssetToken> assetTokens = [];
      if (event.pageKey == null) {
        assetTokens = await database.assetTokenDao
            .findAllAssetTokensWithoutOffset(event.owners);
      } else {
        final id = event.pageKey!.id;
        final lastTime =
            event.pageKey!.offset ?? DateTime.now().millisecondsSinceEpoch;
        assetTokens = await database.assetTokenDao
            .findAllAssetTokensBeforeByOwners(event.owners, lastTime, id);
      }

      if (assetTokens.isEmpty) return;
      add(UpdateTokensEvent(state: state.state, tokens: assetTokens));
    });

    on<RefreshNftCollectionByOwners>((event, emit) async {
      NftCollection.logger
          .info("[NftCollectionBloc] RefreshNftCollectionByOwners");
      _hiddenAddresses = _filterAddressIndexes(event.hiddenAddresses!);
      NftCollection.logger.info("[NftCollectionBloc] UpdateAddresses. "
          "Hidden Addresses: $_hiddenAddresses");

      _addresses = _filterAddressIndexes(event.addresses!);
      NftCollection.logger.info("[NftCollectionBloc] UpdateAddresses. "
          "Addresses: $_addresses");

      _debugTokenIds = event.debugTokens.unique((e) => e) ?? [];
      NftCollection.logger.info("[NftCollectionBloc] UpdateAddresses. "
          "debugTokenIds: $_debugTokenIds");

      try {
        final lastRefreshedTime = prefs.getLatestRefreshTokens();

        final mapAddresses = mapAddressesByLastRefreshedTime(
          _addresses,
          lastRefreshedTime,
        );

        await database.tokenDao
            .deleteTokensNotBelongs(_addresses.map((e) => e.address).toList());

        add(UpdateTokensEvent(state: state.state));

        final pendingTokens = await database.tokenDao.findAllPendingTokens();
        NftCollection.logger
            .info("[NftCollectionBloc] ${pendingTokens.length} pending tokens. "
                "${pendingTokens.map((e) => e.id).toList()}");

        final removePendingIds = pendingTokens
            .where(
              (e) => e.lastActivityTime
                  .add(pendingTokenExpire)
                  .isBefore(DateTime.now()),
            )
            .map((e) => e.id)
            .toList();

        if (removePendingIds.isNotEmpty) {
          NftCollection.logger.info(
              "[NftCollectionBloc] Delete old pending tokens $removePendingIds");
          await database.tokenDao.deleteTokens(removePendingIds);
        }

        fetchManuallyTokens(_debugTokenIds);

        NftCollection.logger.info(
            "[NftCollectionBloc][start] _tokensService.refreshTokensInIsolate");
        final stream = await tokensService.refreshTokensInIsolate(mapAddresses);
        if (tokensService.isRefreshAllTokensListen) return;
        emit(state.copyWith(
            nextKey: state.nextKey, state: NftLoadingState.loading));
        stream.listen((event) async {
          NftCollection.logger.info("[Stream.refreshTokensInIsolate] getEvent");

          if (event.isNotEmpty) {
            NftCollection.logger.info(
                "[Stream.refreshTokensInIsolate] UpdateTokensEvent ${event.length} tokens");
            if (state.nextKey?.offset != null) {
              final addingTokens = event
                  .where(
                    (element) =>
                        element.lastActivityTime.millisecondsSinceEpoch >=
                        state.nextKey!.offset!,
                  )
                  .toList();
              add(UpdateTokensEvent(
                  state: NftLoadingState.loading, tokens: addingTokens));
            }
          }
        }, onDone: () async {
          NftCollection.logger
              .info("[Stream.refreshTokensInIsolate] getEvent Done");
          add(UpdateTokensEvent(state: NftLoadingState.done));
        });
      } catch (exception) {
        add(UpdateTokensEvent(state: NftLoadingState.error));

        NftCollection.logger.warning("Error: $exception");
      }
    });

    on<RefreshNftCollectionByIDs>((event, emit) async {
      NftCollection.logger
          .info("[NftCollectionBloc] RefreshNftCollectionByIDs");
      if (event.debugTokenIds?.isNotEmpty ?? false) {
        _debugTokenIds = event.debugTokenIds ?? [];
        fetchManuallyTokens(_debugTokenIds);
      }
      if (event.ids?.isEmpty ?? true) {
        emit(state.copyWith(
          nextKey: state.nextKey,
          tokens: [],
          state: NftLoadingState.done,
        ));
        return;
      }

      final assetTokens =
          await database.assetTokenDao.findAllAssetTokensByTokenIDs(event.ids!);
      emit(state.copyWith(
        nextKey: state.nextKey,
        tokens: assetTokens,
        state: NftLoadingState.done,
      ));
    });

    on<UpdateTokensEvent>((event, emit) async {
      final tokens = [...event.tokens, ...state.tokens]
          .unique((element) => element.id + element.owner);

      tokens?.removeWhere((element) =>
          !activeAddress.contains(element.owner) && element.isDebugged != true);

      emit(
        state.copyWith(
          state: event.state,
          tokens: tokens,
          nextKey: state.nextKey,
        ),
      );
    });

    on<ReloadEvent>((event, emit) async {
      emit(state.copyWith(nextKey: state.nextKey));
    });

    on<RequestIndexEvent>((event, emit) async {
      tokensService.reindexAddresses(_filterAddresses(event.addresses));
    });
  }
  Map<int, List<String>> mapAddressesByLastRefreshedTime(
      List<AddressIndex> addresses, DateTime? lastRefreshedTime) {
    if (addresses.isEmpty) return {};
    final listAddresses = addresses.map((e) => e.address).toList();
    if (lastRefreshedTime == null) {
      return {0: listAddresses};
    }
    final result = <int, List<String>>{};
    final listPendingAddresses = prefs.getPendingAddresses();
    final timestamp = lastRefreshedTime.millisecondsSinceEpoch ~/ 1000;

    for (var address in addresses) {
      if (address.createdAt.isBefore(lastRefreshedTime) &&
          !(listPendingAddresses?.contains(address.address) ?? false)) {
        if (result[timestamp] == null) {
          result[timestamp] = [];
        }
        result[timestamp]?.add(address.address);
        continue;
      }

      if (result[0] == null) {
        result[0] = [];
      }
      result[0]?.add(address.address);
    }

    return result;
  }

  Future getTokenByLastRefreshedTime(
    List<String> address,
    int lastRefreshedTime,
  ) async {}

  List<AddressIndex> _filterAddressIndexes(List<AddressIndex> addressIndexes) {
    return addressIndexes
        .where((element) => element.address.trim().isNotEmpty)
        .toList();
  }

  List<String> _filterAddresses(List<String> addresses) {
    return addresses.map((e) => e.trim()).whereNot((e) => e.isEmpty).toList();
  }
}
