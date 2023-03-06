// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:nft_collection/models/address_index.dart';
import 'package:nft_collection/models/asset_token.dart';

enum NftLoadingState { notRequested, loading, error, done }

abstract class NftCollectionBlocEvent {}

class RefreshNftCollectionByOwners extends NftCollectionBlocEvent {
  final List<AddressIndex>? addresses;
  final List<AddressIndex>? hiddenAddresses;
  final List<String>? debugTokens;
  RefreshNftCollectionByOwners({
    this.addresses,
    this.hiddenAddresses,
    this.debugTokens,
  });

  RefreshNftCollectionByOwners copyWith({
    List<AddressIndex>? addresses,
    List<AddressIndex>? hiddenAddresses,
    List<String>? debugTokens,
  }) {
    return RefreshNftCollectionByOwners(
      addresses: addresses ?? this.addresses,
      hiddenAddresses: hiddenAddresses ?? this.hiddenAddresses,
      debugTokens: debugTokens ?? this.debugTokens,
    );
  }
}

class AddNewTokensEvent extends NftCollectionBlocEvent {
  final NftLoadingState state;
  final List<AssetToken> tokens;
  AddNewTokensEvent({required this.state, this.tokens = const []});
}

class ReloadEvent extends NftCollectionBlocEvent {
  ReloadEvent();
}

class RefreshNftCollectionByIDs extends NftCollectionBlocEvent {
  final List<String>? ids;
  final List<String>? debugTokenIds;
  RefreshNftCollectionByIDs({this.ids, this.debugTokenIds});
}

class UpdateHiddenTokens extends NftCollectionBlocEvent {
  final List<String> tokens;

  UpdateHiddenTokens({this.tokens = const []});
}

class RefreshTokenEvent extends NftCollectionBlocEvent {
  RefreshTokenEvent();
}

class GetTokensByOwnerEvent extends NftCollectionBlocEvent {
  final PageKey pageKey;
  GetTokensByOwnerEvent({required this.pageKey});
}

class GetTokensByIDsEvent extends NftCollectionBlocEvent {
  final PageKey pageKey;
  GetTokensByIDsEvent({required this.pageKey});
}

class PingIndexerEvent extends NftCollectionBlocEvent {
  PingIndexerEvent();
}

class InitPageController extends NftCollectionBlocEvent {
  /// load collection by address or by token id
  final bool getByAddress;
  InitPageController({this.getByAddress = true});
}

// class FetchTokenEvent extends NftCollectionBlocEvent {
//   final List<String> addresses;

//   FetchTokenEvent(this.addresses);
// }

class PageKey {
  final int? offset;
  final String id;
  bool isLoaded;
  PageKey({
    required this.offset,
    required this.id,
    this.isLoaded = false,
  });

  factory PageKey.init() {
    return PageKey(
      id: '',
      offset: null,
    );
  }

  @override
  bool operator ==(covariant PageKey other) {
    if (identical(this, other)) return true;

    return other.offset == offset &&
        other.id == id &&
        other.isLoaded == isLoaded;
  }

  @override
  int get hashCode => offset.hashCode ^ id.hashCode ^ isLoaded.hashCode;

  @override
  String toString() => 'PageKey(offset: $offset, id: $id, isLoaded: $isLoaded)';
}

class RequestIndexEvent extends NftCollectionBlocEvent {
  final List<String> addresses;

  RequestIndexEvent(this.addresses);
}

class PurgeCache extends NftCollectionBlocEvent {}
