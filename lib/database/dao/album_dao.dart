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
    final nameFilter = "%$name%";
    return _queryAdapter.queryList(
      'SELECT count(Token.id) as total, artistID as id, artistName as name, Asset.galleryThumbnailURL as  thumbnailURL FROM Token LEFT JOIN Asset  ON Token.indexID = Asset.indexID JOIN AddressCollection ON Token.owner = AddressCollection.address WHERE name LIKE ?1 AND AddressCollection.isHidden = FALSE GROUP BY artistID ORDER BY total DESC',
      mapper: mapper,
      arguments: [nameFilter],
    );
  }

  Future<List<AlbumModel>> getAlbumsByMedium(
      {String title = "", required String mediumCategory}) async {
    final titleFilter = "%$title%";
    final mineTypes = MediumCategory.mineTypes(mediumCategory);
    final mimeTypeFilter = "(${mineTypes.map((e) => "'$e'").join(",")})";
    final albumId = mediumCategory;
    return _queryAdapter.queryList(
      'SELECT count(Token.id) as total, ?3 as id, ?3 as name, Asset.galleryThumbnailURL as  thumbnailURL FROM Token LEFT JOIN Asset  ON Token.indexID = Asset.indexID JOIN AddressCollection ON Token.owner = AddressCollection.address WHERE Asset.title LIKE ?1 AND AddressCollection.isHidden = FALSE AND mimeType IN ?2 ORDER BY total DESC',
      mapper: mapper,
      arguments: [titleFilter, mimeTypeFilter, albumId],
    );
  }
}

class MediumCategory {
  static const image = "image";
  static const video = "video";
  static const model = "model";
  static const webView = "webView";
  static const other = "other";

  static List<String> mineTypes(String category) {
    switch (category) {
      case MediumCategory.image:
        return [
          "image/avif",
          "image/bmp",
          "image/jpeg",
          "image/jpg",
          "image/png",
          "image/tiff",
          "image/svg+xml",
          "image/gif",
        ];
      case MediumCategory.video:
        return [
          "video/x-msvideo",
          "video/3gpp",
          "video/mp4",
          "video/mpeg",
          "video/ogg",
          "video/3gpp2",
          "video/quicktime",
          "application/x-mpegURL",
          "video/x-flv",
          "video/MP2T",
          "video/webm",
          "application/octet-stream",
        ];
      case MediumCategory.model:
        return ['model/gltf-binary'];
      case MediumCategory.webView:
        return ['text/html'];
      case MediumCategory.other:
        return [];
    }
    return [];
  }
}
