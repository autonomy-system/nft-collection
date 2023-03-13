// ignore_for_file: public_member_api_docs, sort_constructors_first
//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:floor_annotation/floor_annotation.dart';

@Entity(primaryKeys: ["indexID"])
class Asset {
  String? indexID;
  String? thumbnailID;
  DateTime? lastRefreshedTime;
  String? artistID;
  String? artistName;
  String? artistURL;
  String? assetID;
  String? title;
  String? description;
  String? mimeType;
  String? medium;
  int? maxEdition;
  String? source;
  String? sourceURL;
  String? previewURL;
  String? thumbnailURL;
  String? galleryThumbnailURL;
  String? assetData;
  String? assetURL;
  bool? isFeralfileFrame;
  String? initialSaleModel;
  String? originalFileURL;

  Asset(
    this.indexID,
    this.thumbnailID,
    this.lastRefreshedTime,
    this.artistID,
    this.artistName,
    this.artistURL,
    this.assetID,
    this.title,
    this.description,
    this.mimeType,
    this.medium,
    this.maxEdition,
    this.source,
    this.sourceURL,
    this.previewURL,
    this.thumbnailURL,
    this.galleryThumbnailURL,
    this.assetData,
    this.assetURL,
    this.initialSaleModel,
    this.originalFileURL,
    this.isFeralfileFrame,
  );
  Asset.init({
    this.indexID,
    this.thumbnailID,
    this.lastRefreshedTime,
    this.artistID,
    this.artistName,
    this.artistURL,
    this.assetID,
    this.title,
    this.description,
    this.mimeType,
    this.medium,
    this.maxEdition,
    this.source,
    this.sourceURL,
    this.previewURL,
    this.thumbnailURL,
    this.galleryThumbnailURL,
    this.assetData,
    this.assetURL,
    this.initialSaleModel,
    this.originalFileURL,
    this.isFeralfileFrame,
  });

  factory Asset.fromJson(Map<String, dynamic> map) {
    return Asset(
      map['indexID'] != null ? map['indexID'] as String : null,
      map['thumbnailID'] != null ? map['thumbnailID'] as String : null,
      map['lastRefreshedTime'] != null
          ? DateTime.tryParse(map['lastRefreshedTime'])
          : null,
      map['metadata']['artistID'] != null ? map['artistID'] as String : null,
      map['artistName'] != null ? map['artistName'] as String : null,
      map['artistURL'] != null ? map['artistURL'] as String : null,
      map['assetID'] != null ? map['assetID'] as String : null,
      map['title'] != null ? map['title'] as String : null,
      map['description'] != null ? map['description'] as String : null,
      map['mimeType'] != null ? map['mimeType'] as String : null,
      map['medium'] != null ? map['medium'] as String : null,
      map['maxEdition'] != null ? map['maxEdition'] as int : null,
      map['source'] != null ? map['source'] as String : null,
      map['sourceURL'] != null ? map['sourceURL'] as String : null,
      map['previewURL'] != null ? map['previewURL'] as String : null,
      map['thumbnailURL'] != null ? map['thumbnailURL'] as String : null,
      map['galleryThumbnailURL'] != null
          ? map['galleryThumbnailURL'] as String
          : null,
      map['assetData'] != null ? map['assetData'] as String : null,
      map['assetURL'] != null ? map['assetURL'] as String : null,
      map['initialSaleModel'] != null
          ? map['initialSaleModel'] as String
          : null,
      map['originalFileURL'] != null ? map['originalFileURL'] as String : null,
      map['isFeralfileFrame'] != null ? map['isFeralfileFrame'] as bool : null,
    );
  }
}
