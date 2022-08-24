import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:nft_collection/database/nft_collection_database.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/nft_collection.dart';
import 'package:nft_collection/services/tokens_service.dart';
import 'package:nft_collection/utils/constants.dart';

class NftCollectionBlocState {

  static const _tokensEquality = ListEquality<AssetToken>();

  final NftLoadingState state;
  final List<AssetToken> tokens;

  NftCollectionBlocState({required this.tokens, required this.state});

  NftCollectionBlocState copyWith(
      {List<AssetToken>? tokens,
      NftLoadingState? state,
      List<String>? addresses,
      List<String>? debugTokens}) {
    return NftCollectionBlocState(
        state: state ?? this.state, tokens: tokens ?? this.tokens);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NftCollectionBlocState &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          _tokensEquality.equals(tokens, other.tokens);

  @override
  int get hashCode => state.hashCode ^ tokens.hashCode;
}

class NftCollectionBloc
    extends Bloc<NftCollectionBlocEvent, NftCollectionBlocState> {
  final TokensService tokensService;
  final NftCollectionDatabase database;

  List<String> _addresses = [];
  List<String> _indexerIds = [];
  List<String> _hiddenAddresses = [];

  Future<List<String>> fetchManuallyTokens(List<String> indexerIds) async {
    if (indexerIds.isNotEmpty) {
      await tokensService.fetchManualTokens(indexerIds);
    }
    return indexerIds;
  }

  NftCollectionBloc(this.tokensService, this.database)
      : super(NftCollectionBlocState(
            state: NftLoadingState.notRequested, tokens: [])) {
    on<RefreshNftCollection>((event, emit) {
      add(_SubRefreshTokensEvent(state.state));
    });

    on<UpdateHiddenTokens>((event, emit) {
      _hiddenAddresses = event.ownerAddresses;
      add(_SubRefreshTokensEvent(state.state));
    });

    on<_SubRefreshTokensEvent>((event, emit) async {
      final assetTokens =
          await database.assetDao.findAllAssetTokensWhereNot(_hiddenAddresses);
      emit(state.copyWith(tokens: assetTokens, state: event.state));
    });

    on<FetchTokenEvent>((event, emit) async {
      tokensService.fetchTokensForAddresses(event.addresses);
    });

    on<RefreshTokenEvent>((event, emit) async {
      NftCollection.logger.info("[NftCollectionBloc] RefreshTokensEvent start");
      _addresses = event.addresses;
      _indexerIds = event.debugTokens;

      try {
        List<String> allAccountNumbers = event.addresses;

        await database.assetDao.deleteAssetsNotBelongs(allAccountNumbers);

        add(_SubRefreshTokensEvent(NftLoadingState.notRequested));

        final latestAssets = await tokensService.fetchLatestAssets(
            allAccountNumbers, indexerTokensPageSize);

        NftCollection.logger.info(
            "[NftCollectionBloc] fetch ${latestAssets.length} latest NFTs");

        if (latestAssets.length < indexerTokensPageSize) {
          await fetchManuallyTokens(event.debugTokens);
          add(_SubRefreshTokensEvent(NftLoadingState.done));
        } else {
          final debugTokenIDs = await fetchManuallyTokens(event.debugTokens);
          add(_SubRefreshTokensEvent(NftLoadingState.loading));
          NftCollection.logger.info(
              "[NftCollectionBloc][start] _tokensService.refreshTokensInIsolate");

          final stream = await tokensService.refreshTokensInIsolate(
              allAccountNumbers, debugTokenIDs);
          stream.listen((event) async {
            NftCollection.logger
                .info("[Stream.refreshTokensInIsolate] getEvent");
            add(_SubRefreshTokensEvent(NftLoadingState.loading));
          }, onDone: () async {
            NftCollection.logger
                .info("[Stream.refreshTokensInIsolate] getEvent Done");
            add(_SubRefreshTokensEvent(NftLoadingState.done));
          });
        }
      } catch (exception) {
        NftCollection.logger.warning("Error: $exception");
      }
    });

    on<RequestIndexEvent>((event, emit) async {
      tokensService.reindexAddresses(event.addresses);
    });

    on<PurgeCache>((event, emit) async {
      await tokensService.purgeCachedGallery();
      add(RefreshTokenEvent(addresses: _addresses, debugTokens: _indexerIds));
    });
  }
}

class _SubRefreshTokensEvent extends NftCollectionBlocEvent {
  final NftLoadingState state;

  _SubRefreshTokensEvent(this.state);
}
