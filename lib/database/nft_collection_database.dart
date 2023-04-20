//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'dart:async';

import 'package:floor/floor.dart';
import 'package:nft_collection/database/dao/album_dao.dart';
import 'package:nft_collection/database/dao/asset_dao.dart';
import 'package:nft_collection/database/dao/asset_token_dao.dart';
import 'package:nft_collection/database/dao/token_dao.dart';
import 'package:nft_collection/database/dao/provenance_dao.dart';
import 'package:nft_collection/models/asset.dart';
import 'package:nft_collection/models/token.dart';
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
@Database(version: 2, entities: [Token, Asset, Provenance])
abstract class NftCollectionDatabase extends FloorDatabase {
  TokenDao get tokenDao;
  AssetTokenDao get assetTokenDao => AssetTokenDao(database, changeListener);
  AlbumDao get albumDao => AlbumDao(database, changeListener);
  AssetDao get assetDao;
  ProvenanceDao get provenanceDao;

  Future<dynamic> removeAll() async {
    await provenanceDao.removeAll();
    await tokenDao.removeAll();
    await assetDao.removeAll();
  }
}

final migrations = <Migration>[migrateV1ToV2];

final migrateV1ToV2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE Asset ADD COLUMN artworkMetadata TEXT');
  await database
      .execute('ALTER TABLE Provenance ADD COLUMN blockNumber INTEGER');
});
