import 'package:nft_collection/database/nft_collection_database.dart';
import 'package:nft_collection/di/injector.dart';
import 'package:nft_collection/models/address_collection.dart';
import 'package:nft_collection/nft_collection.dart';
import 'package:nft_collection/services/tokens_service.dart';

class AddressService {
  final NftCollectionDatabase _database;

  AddressService(this._database);

  Future<void> addAddresses(List<String> addresses) async {
    await _database.addressCollectionDao.insertAddressesAbort(addresses
        .map((e) => AddressCollection(
            address: e,
            lastRefreshedTime: DateTime.fromMillisecondsSinceEpoch(0)))
        .toList());
    await ncInjector<TokensService>().reindexAddresses(addresses);
  }

  Future<void> deleteAddresses(List<String> addresses) async {
    await _database.addressCollectionDao.deleteAddresses(addresses);
    await _database.tokenDao.deleteTokensByOwners(addresses);
    NftCollection.logger.info("Delete address $addresses");
    NftCollectionBloc.eventController
        .add(UpdateTokensEvent(state: NftLoadingState.done, tokens: []));
  }

  Future<List<AddressCollection>> getAllAddresses() async {
    return await _database.addressCollectionDao.findAllAddresses();
  }

  Future<void> setIsHiddenAddresses(
      List<String> addresses, bool isHidden) async {
    await _database.addressCollectionDao
        .setAddressIsHidden(addresses, isHidden);
    if (isHidden) {
      NftCollectionBloc.eventController
          .add(UpdateTokensEvent(state: NftLoadingState.done, tokens: []));
    } else {
      NftCollectionBloc.eventController
          .add(GetTokensBeforeByOwnerEvent(owners: addresses));
    }
  }

  Future<void> updateRefreshedTime(
      List<String> addresses, DateTime time) async {
    await _database.addressCollectionDao
        .updateRefreshTime(addresses, time.millisecondsSinceEpoch);
  }

  Future<List<String>> getActiveAddresses() async {
    return await _database.addressCollectionDao.findAddressesIsHidden(false);
  }

  Future<List<String>> getHiddenAddresses() async {
    return await _database.addressCollectionDao.findAddressesIsHidden(true);
  }
}
