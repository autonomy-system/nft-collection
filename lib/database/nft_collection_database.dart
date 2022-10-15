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
import 'package:nft_collection/database/dao/token_owner_dao.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/models/provenance.dart';
import 'package:nft_collection/models/token_owner.dart';
import 'package:nft_collection/utils/date_time_converter.dart';

// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart' as sqflite;

part 'nft_collection_database.g.dart'; // the generated code will be there

@TypeConverters([
  DateTimeConverter,
  NullableDateTimeConverter,
  TokenOwnersConverter,
])
@Database(version: 5, entities: [AssetToken, TokenOwner, Provenance])
abstract class NftCollectionDatabase extends FloorDatabase {
  AssetTokenDao get assetDao;
  TokenOwnerDao get tokenOwnerDao;
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