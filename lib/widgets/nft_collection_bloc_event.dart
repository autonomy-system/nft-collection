enum NftLoadingState { notRequested, loading, error, done }

abstract class NftCollectionBlocEvent {}

class RefreshNftCollection extends NftCollectionBlocEvent {}

class UpdateHiddenTokens extends NftCollectionBlocEvent {
  final List<String> ownerAddresses;

  UpdateHiddenTokens({this.ownerAddresses = const []});
}

class RefreshTokenEvent extends NftCollectionBlocEvent {
  final List<String> addresses;
  final List<String> debugTokens;

  RefreshTokenEvent({required this.addresses, this.debugTokens = const []});
}

class FetchTokenEvent extends NftCollectionBlocEvent {
  final List<String> addresses;

  FetchTokenEvent(this.addresses);
}

class RequestIndexEvent extends NftCollectionBlocEvent {
  final List<String> addresses;

  RequestIndexEvent(this.addresses);
}

class PurgeCache extends NftCollectionBlocEvent {}
