//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:floor/floor.dart';
import 'package:nft_collection/models/album_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

@dao
class AlbumDao {
  AlbumDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  static AlbumModel Function(Map<String, Object?>) mapper =
      (Map<String, Object?> row) {
    return AlbumModel(
      id: row['id'] as String? ?? '',
      name: row['name'] as String?,
      total: row['total'] as int? ?? 0,
      thumbnailURL: row['thumbnailURL'] as String?,
    );
  };

  final QueryAdapter _queryAdapter;
  Future<List<AlbumModel>> getAlbumsByArtist({String name = ""}) async {
    final nameFilter = "%${name}%";
    return _queryAdapter.queryList(
      'SELECT count(Token.id) as total, artistID as id, artistName as name, Asset.galleryThumbnailURL as  thumbnailURL FROM Token LEFT JOIN Asset  ON Token.indexID = Asset.indexID JOIN AddressCollection ON Token.owner = AddressCollection.address WHERE name LIKE ?1 AND AddressCollection.isHidden = FALSE GROUP BY artistID ORDER BY total DESC',
      mapper: mapper,
      arguments: [nameFilter],
    );
  }

  Future<List<AlbumModel>> getAlbumsByMedium({String title = ""}) async {
    final titleFilter = "%${title}%";
    return _queryAdapter.queryList(
      'SELECT count(Token.id) as total, medium as id, medium as name, Asset.galleryThumbnailURL as  thumbnailURL FROM Token LEFT JOIN Asset  ON Token.indexID = Asset.indexID JOIN AddressCollection ON Token.owner = AddressCollection.address WHERE Asset.title LIKE ?1 AND AddressCollection.isHidden = FALSE GROUP BY medium ORDER BY total DESC',
      mapper: mapper,
      arguments: [titleFilter],
    );
  }
}
