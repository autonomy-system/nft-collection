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

// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart' as sqflite;

@dao
class AlbumDao {
  AlbumDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  static AlbumModel Function(Map<String, Object?>) mapper =
      (Map<String, Object?> row) => AlbumModel(
            id: row['id'] as String,
            name: row['name'] as String?,
            total: row['total'] as int? ?? 0,
            thumbnailID: row['thumbnailID'] as String?,
          );

  final QueryAdapter _queryAdapter;
  Future<List<AlbumModel>> getAlbumsByArtist() async {
    return _queryAdapter.queryList(
      'SELECT count(Token.id) as total, artistID as id, artistName as name FROM Token LEFT JOIN Asset ON Token.indexID = Asset.indexID GROUP BY artistID ORDER BY total DESC',
      mapper: mapper,
    );
  }

  Future<List<AlbumModel>> getAlbumsByMedium() async {
    return _queryAdapter.queryList(
      'SELECT count(Token.id) as total, medium as id, medium as name FROM Token LEFT JOIN Asset ON Token.indexID = Asset.indexID GROUP BY medium ORDER BY total DESC',
      mapper: mapper,
    );
  }
}
