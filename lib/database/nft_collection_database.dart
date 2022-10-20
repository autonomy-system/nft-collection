//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'dart:async';

import 'package:floor/floor.dart';
import 'package:nft_collection/database/dao/asset_token_dao.dart';
import 'package:nft_collection/database/dao/provenance_dao.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/models/provenance.dart';
import 'package:nft_collection/utils/date_time_converter.dart';

// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart' as sqflite;

part 'nft_collection_database.g.dart'; // the generated code will be there

@TypeConverters([
  DateTimeConverter,
  NullableDateTimeConverter,
  TokenOwnersConverter,
])
@Database(version: 6, entities: [AssetToken, Provenance])
abstract class NftCollectionDatabase extends FloorDatabase {
  AssetTokenDao get assetDao;
  ProvenanceDao get provenanceDao;

  Future<dynamic> removeAll() async {
    await provenanceDao.removeAll();
    await assetDao.removeAll();
  }
}

final migrations = [
  migrateV1ToV2,
  migrateV2ToV3,
  migrateV3ToV4,
  migrateV4ToV5,
  migrateV5ToV6
];

final migrateV1ToV2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE `AssetToken` ADD `pending` INTEGER');
});

final migrateV2ToV3 = Migration(2, 3, (database) async {
  await database.execute(
      'CREATE TABLE IF NOT EXISTS `TokenOwner` (`indexerId` TEXT NOT NULL, `owner` TEXT NOT NULL, `quantity` INTEGER NOT NULL, FOREIGN KEY (`indexerId`) REFERENCES `AssetToken` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`indexerId`, `owner`))');
});

final migrateV3ToV4 = Migration(3, 4, (database) async {
  await database.execute('ALTER TABLE `TokenOwner` ADD `updateTime` INTEGER');
});

final migrateV4ToV5 = Migration(4, 5, (database) async {
  await database.execute('ALTER TABLE `AssetToken` ADD `initialSaleModel` TEXT');
});

final migrateV5ToV6 = Migration(5, 6, (database) async {
  await database.execute('DROP TABLE `Provenance`');
  await database.execute('DROP TABLE `TokenOwner`');
  await database.execute('DROP TABLE `AssetToken`');
  await database.execute('CREATE TABLE IF NOT EXISTS `AssetToken` (`artistName` TEXT, `artistURL` TEXT, `artistID` TEXT, `assetData` TEXT, `assetID` TEXT, `assetURL` TEXT, `basePrice` REAL, `baseCurrency` TEXT, `blockchain` TEXT NOT NULL, `blockchainUrl` TEXT, `fungible` INTEGER, `contractType` TEXT, `tokenId` TEXT, `contractAddress` TEXT, `desc` TEXT, `edition` INTEGER NOT NULL, `id` TEXT NOT NULL, `maxEdition` INTEGER, `medium` TEXT, `mimeType` TEXT, `mintedAt` TEXT, `previewURL` TEXT, `source` TEXT, `sourceURL` TEXT, `thumbnailID` TEXT, `thumbnailURL` TEXT, `galleryThumbnailURL` TEXT, `title` TEXT NOT NULL, `ownerAddress` TEXT NOT NULL, `owners` TEXT NOT NULL, `balance` INTEGER, `lastActivityTime` INTEGER NOT NULL, `updateTime` INTEGER, `pending` INTEGER, `initialSaleModel` TEXT, PRIMARY KEY (`id`, `ownerAddress`))');
  await database.execute('CREATE TABLE IF NOT EXISTS `Provenance` (`txID` TEXT NOT NULL, `type` TEXT NOT NULL, `blockchain` TEXT NOT NULL, `owner` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, `txURL` TEXT NOT NULL, `tokenID` TEXT NOT NULL, PRIMARY KEY (`txID`))');
  await database.execute('CREATE INDEX `index_Provenance_tokenID` ON `Provenance` (`tokenID`)');
});