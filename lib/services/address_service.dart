import 'package:nft_collection/database/nft_collection_database.dart';
import 'package:nft_collection/models/address_collection.dart';

class AddressService {
  final NftCollectionDatabase _database;

  AddressService(this._database);

  Future<void> addAddresses(List<String> addresses) async {
    await _database.addressCollectionDao.insertAddressesAbort(addresses
        .map((e) => AddressCollection(
            address: e,
            lastRefreshedTime: DateTime.fromMillisecondsSinceEpoch(0)))
        .toList());
  }

  Future<void> deleteAddresses(List<String> addresses) async {
    await _database.addressCollectionDao.deleteAddresses(addresses);
  }

  Future<List<AddressCollection>> getAllAddresses() async {
    return await _database.addressCollectionDao.findAllAddresses();
  }

  Future<void> setIsHiddenAddresses(
      List<String> addresses, bool isHidden) async {
    await _database.addressCollectionDao
        .setAddressIsHidden(addresses, isHidden);
  }

  Future<void> updateRefreshedTime(
      List<String> addresses, DateTime time) async {
    await _database.addressCollectionDao
        .updateRefreshTime(addresses, time.millisecondsSinceEpoch);
  }

  Future<List<String>> getActiveAddresses() async {
    return await _database.addressCollectionDao.findAddressesIsHidden(false);
  }
}
