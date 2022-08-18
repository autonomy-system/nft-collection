//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'dart:convert';

import 'package:floor_annotation/floor_annotation.dart';
import 'package:nft_collection/models/asset.dart';
import 'package:nft_collection/models/provenance.dart';

@entity
class AssetToken {
  String? artistName;
  String? artistURL;
  String? artistID;
  String? assetData;
  String? assetID;
  String? assetURL;
  double? basePrice;
  String? baseCurrency;
  String blockchain;
  String? blockchainUrl;
  bool? fungible;
  String? contractType;
  String? tokenId;
  String? contractAddress;
  String? desc;
  int edition;
  @primaryKey
  String id;
  int? maxEdition;
  String? medium;
  String? mimeType;
  String? mintedAt;
  String? previewURL;
  String? source;
  String? sourceURL;
  String? thumbnailID;
  String? thumbnailURL;
  String? galleryThumbnailURL;
  String title;
  String? ownerAddress;
  Map<String, int> owners;
  DateTime lastActivityTime;
  @ignore
  List<Provenance>? provenances;

  AssetToken({
    required this.artistName,
    required this.artistURL,
    required this.artistID,
    required this.assetData,
    required this.assetID,
    required this.assetURL,
    required this.basePrice,
    required this.baseCurrency,
    required this.blockchain,
    required this.blockchainUrl,
    required this.fungible,
    required this.contractType,
    required this.tokenId,
    required this.contractAddress,
    required this.desc,
    required this.edition,
    required this.id,
    required this.maxEdition,
    required this.medium,
    required this.mimeType,
    required this.mintedAt,
    required this.previewURL,
    required this.source,
    required this.sourceURL,
    required this.thumbnailID,
    required this.thumbnailURL,
    required this.galleryThumbnailURL,
    required this.title,
    required this.ownerAddress,
    required this.owners,
    required this.lastActivityTime,
    this.provenances,
  });

  factory AssetToken.fromAsset(Asset asset) => AssetToken(
        artistName: asset.projectMetadata.latest.artistName,
        artistURL: asset.projectMetadata.latest.artistUrl,
        artistID: asset.projectMetadata.latest.artistId,
        assetData: asset.projectMetadata.latest.assetData,
        assetID: asset.projectMetadata.latest.assetId,
        assetURL: asset.projectMetadata.latest.assetUrl,
        basePrice: asset.projectMetadata.latest.basePrice,
        baseCurrency: asset.projectMetadata.latest.baseCurrency,
        blockchain: asset.blockchain,
        blockchainUrl: asset.blockchainURL,
        fungible: asset.fungible,
        contractType: asset.contractType,
        tokenId: asset.tokenId,
        contractAddress: asset.contractAddress,
        desc: asset.projectMetadata.latest.description,
        edition: asset.edition,
        id: asset.id,
        maxEdition: asset.projectMetadata.latest.maxEdition,
        medium: asset.projectMetadata.latest.medium,
        mimeType: asset.projectMetadata.latest.mimeType,
        mintedAt: asset.mintedAt.toIso8601String(),
        previewURL: asset.projectMetadata.latest.previewUrl,
        source: asset.projectMetadata.latest.source,
        sourceURL: asset.projectMetadata.latest.sourceUrl,
        thumbnailID: asset.thumbnailID,
        thumbnailURL: asset.projectMetadata.latest.thumbnailUrl,
        galleryThumbnailURL: asset.projectMetadata.latest.galleryThumbnailUrl,
        title: asset.projectMetadata.latest.title,
        ownerAddress: asset.owner,
        owners: asset.owners,
        lastActivityTime: asset.lastActivityTime,
        provenances: asset.provenance,
      );
}

class TokenOwnersConverter extends TypeConverter<Map<String, int>, String> {
  @override
  Map<String, int> decode(String? databaseValue) {
    if (databaseValue?.isNotEmpty == true) {
      return (json.decode(databaseValue!) as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as int?) ?? 0)) ??
          {};
    } else {
      return {};
    }
  }

  @override
  String encode(Map<String, int>? value) {
    if (value == null) {
      return "{}";
    } else {
      return json.encode(value);
    }
  }
}
