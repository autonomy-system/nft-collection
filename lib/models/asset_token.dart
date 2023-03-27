//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:nft_collection/models/asset.dart';
import 'package:nft_collection/models/attributes.dart';
import 'package:nft_collection/models/origin_token_info.dart';
import 'package:nft_collection/models/provenance.dart';

class AssetToken {
  AssetToken({
    required this.id,
    required this.edition,
    required this.editionName,
    required this.blockchain,
    required this.fungible,
    this.mintedAt,
    required this.contractType,
    required this.tokenId,
    required this.contractAddress,
    required this.balance,
    required this.owner,
    required this.owners,
    this.projectMetadata,
    required this.lastActivityTime,
    required this.lastRefreshedTime,
    required this.provenance,
    required this.originTokenInfo,
    this.swapped = false,
    this.attributes,
    this.burned,
    this.ipfsPinned,
    this.asset,
    this.pending,
    this.isDebugged,
    this.scrollable,
    this.originTokenInfoId,
  });

  String id;
  int edition;
  String? editionName;
  String blockchain;
  bool fungible;
  DateTime? mintedAt;
  String contractType;
  String? tokenId;
  String? contractAddress;
  int? balance;
  String owner;
  Map<String, int>
      owners; // Map from owner's address to number of owned tokens.
  ProjectMetadata? projectMetadata;
  DateTime lastActivityTime;
  DateTime lastRefreshedTime;
  List<Provenance> provenance;
  List<OriginTokenInfo>? originTokenInfo;
  bool? swapped;
  Attributes? attributes;

  bool? burned;
  bool? pending;
  bool? isDebugged;
  bool? scrollable;
  String? originTokenInfoId;
  bool? ipfsPinned;

  Asset? asset;

  String? get artistID => asset?.artistID;

  String? get artistName => asset?.artistName;

  String? get artistURL => asset?.artistURL;

  String? get assetID => asset?.artistID;

  String? get title => asset?.title;

  String? get description => asset?.description;

  String? get mimeType => asset?.mimeType;

  String? get medium => asset?.medium;

  int? get maxEdition => asset?.maxEdition;

  String? get source => asset?.source;

  String? get sourceURL => asset?.sourceURL;

  String? get previewURL => asset?.previewURL;

  String? get thumbnailURL => asset?.thumbnailURL;

  String? get thumbnailID => asset?.thumbnailID;

  String? get galleryThumbnailURL => asset?.galleryThumbnailURL;

  String? get assetData => asset?.assetData;

  String? get assetURL => asset?.assetURL;

  bool? get isFeralfileFrame => asset?.isFeralfileFrame;

  String? get initialSaleModel => asset?.initialSaleModel;

  String? get originalFileURL => asset?.originalFileURL;

  String? get artworkMetadata => asset?.artworkMetadata;

  factory AssetToken.fromJson(Map<String, dynamic> json) {
    final Map<String, int> owners = json["owners"]?.map<String, int>(
            (key, value) => MapEntry(key as String, (value as int?) ?? 0)) ??
        {};
    final projectMetadata = ProjectMetadata.fromJson(json["asset"]);
    final lastActivityTime =
        DateTime.parse(json['lastActivityTime']).isAfter(DateTime(1970))
            ? DateTime.parse(json['lastActivityTime'])
            : DateTime.parse(json['lastRefreshedTime']);
    return AssetToken(
      id: json["indexID"],
      edition: json["edition"],
      editionName: json["editionName"],
      blockchain: json["blockchain"],
      fungible: json["fungible"] == true,
      mintedAt:
          json["mintedAt"] != null ? DateTime.parse(json["mintedAt"]) : null,
      contractType: json["contractType"],
      tokenId: json["id"],
      contractAddress: json["contractAddress"],
      balance: json["balance"],
      owner: json["owner"],
      owners: owners,
      projectMetadata: projectMetadata,
      lastActivityTime: lastActivityTime,
      lastRefreshedTime: DateTime.parse(json['lastRefreshedTime']),
      provenance: json["provenance"] != null
          ? (json["provenance"] as List<dynamic>)
              .asMap()
              .map<int, Provenance>((key, value) => MapEntry(
                  key, Provenance.fromJson(value, json['indexID'], key)))
              .values
              .toList()
          : [],
      originTokenInfo: json["originTokenInfo"] != null
          ? (json["originTokenInfo"] as List<dynamic>)
              .map((e) => OriginTokenInfo.fromJson(e))
              .toList()
          : null,
      swapped: json["swapped"] as bool?,
      ipfsPinned: json["ipfsPinned"] as bool?,
      burned: json["burned"] as bool?,
      pending: json["pending"] as bool?,
      attributes: json['attributes'] != null
          ? Attributes.fromJson(json['attributes'])
          : null,
      asset: projectMetadata.toAsset,
    );
  }

  String? get saleModel {
    String? latestSaleModel = projectMetadata?.latest.initialSaleModel?.trim();
    return latestSaleModel?.isNotEmpty == true
        ? latestSaleModel
        : projectMetadata?.origin.initialSaleModel;
  }
}

class CompactedAssetToken extends Comparable<CompactedAssetToken> {
  CompactedAssetToken({
    required this.id,
    required this.balance,
    required this.owner,
    required this.lastActivityTime,
    required this.lastRefreshedTime,
    this.mimeType,
    this.previewURL,
    this.thumbnailURL,
    this.thumbnailID,
    this.galleryThumbnailURL,
    this.pending,
    this.isDebugged,
    this.artistID,
    this.blockchain,
    this.tokenId,
    this.title,
    this.source,
  });

  final String id;

  int? balance;
  String owner;

  final DateTime lastActivityTime;
  DateTime lastRefreshedTime;

  bool? pending;
  bool? isDebugged;

  String? mimeType;
  String? previewURL;
  String? thumbnailURL;
  String? thumbnailID;
  String? galleryThumbnailURL;
  String? artistID;
  String? blockchain;
  String? tokenId;
  String? title;
  String? source;

  factory CompactedAssetToken.fromAssetToken(AssetToken assetToken) {
    return CompactedAssetToken(
      id: assetToken.id,
      balance: assetToken.balance,
      owner: assetToken.owner,
      lastActivityTime: assetToken.lastActivityTime,
      lastRefreshedTime: assetToken.lastRefreshedTime,
      mimeType: assetToken.mimeType,
      previewURL: assetToken.previewURL,
      thumbnailURL: assetToken.thumbnailURL,
      thumbnailID: assetToken.thumbnailID,
      galleryThumbnailURL: assetToken.galleryThumbnailURL,
      pending: assetToken.pending,
      isDebugged: assetToken.isDebugged,
      artistID: assetToken.artistID,
      blockchain: assetToken.blockchain,
      tokenId: assetToken.tokenId,
      title: assetToken.title,
      source: assetToken.source,
    );
  }

  @override
  int compareTo(other) {
    if (other.id.compareTo(id) == 0 && other.owner.compareTo(owner) == 0) {
      return other.id.compareTo(id);
    }

    if (other.lastActivityTime.compareTo(lastActivityTime) == 0) {
      return other.id.compareTo(id);
    }

    return other.lastActivityTime.compareTo(lastActivityTime);
  }
}

class ProjectMetadata {
  ProjectMetadata({
    required this.origin,
    required this.latest,
    this.lastRefreshedTime,
    this.thumbnailID,
    this.indexID,
  });

  String? indexID;
  String? thumbnailID;
  DateTime? lastRefreshedTime;

  ProjectMetadataData origin;
  ProjectMetadataData latest;

  Asset get toAsset => Asset(
        indexID,
        thumbnailID,
        lastRefreshedTime,
        latest.artistId,
        latest.artistName,
        latest.artistUrl,
        latest.assetId,
        latest.title,
        latest.description,
        latest.mimeType,
        latest.medium,
        latest.maxEdition,
        latest.source,
        latest.sourceUrl,
        latest.previewUrl,
        latest.thumbnailUrl,
        latest.galleryThumbnailUrl,
        latest.assetData,
        latest.assetUrl,
        latest.initialSaleModel,
        latest.originalFileUrl,
        latest.artworkMetadata?['isFeralfileFrame'],
        latest.artworkMetadata.toString(),
      );

  factory ProjectMetadata.fromJson(Map<String, dynamic> json) =>
      ProjectMetadata(
        indexID: json["indexID"],
        thumbnailID: json["thumbnailID"],
        lastRefreshedTime: json['lastRefreshedTime'] != null
            ? DateTime.tryParse(json['lastRefreshedTime'])
            : null,
        origin:
            ProjectMetadataData.fromJson(json['metadata']['project']["origin"]),
        latest:
            ProjectMetadataData.fromJson(json['metadata']['project']["latest"]),
      );

  Map<String, dynamic> toJson() => {
        "origin": origin.toJson(),
        "latest": latest.toJson(),
      };
}

class ProjectMetadataData {
  ProjectMetadataData({
    required this.artistName,
    required this.artistUrl,
    required this.assetId,
    required this.title,
    required this.description,
    required this.medium,
    required this.mimeType,
    required this.maxEdition,
    required this.baseCurrency,
    required this.basePrice,
    required this.source,
    required this.sourceUrl,
    required this.previewUrl,
    required this.thumbnailUrl,
    required this.galleryThumbnailUrl,
    required this.assetData,
    required this.assetUrl,
    required this.artistId,
    required this.originalFileUrl,
    required this.initialSaleModel,
    required this.artworkMetadata,
  });

  String? artistName;
  String? artistUrl;
  String? assetId;
  String title;
  String? description;
  String? medium;
  String? mimeType;
  int? maxEdition;
  String? baseCurrency;
  double? basePrice;
  String? source;
  String? sourceUrl;
  String previewUrl;
  String thumbnailUrl;
  String? galleryThumbnailUrl;
  String? assetData;
  String? assetUrl;
  String? artistId;
  String? originalFileUrl;
  String? initialSaleModel;
  Map<String, dynamic>? artworkMetadata;

  factory ProjectMetadataData.fromJson(Map<String, dynamic> json) =>
      ProjectMetadataData(
        artistName: json["artistName"],
        artistUrl: json["artistURL"],
        assetId: json["assetID"],
        title: json["title"],
        description: json["description"],
        medium: json["medium"],
        mimeType: json["mimeType"],
        maxEdition: json["maxEdition"],
        baseCurrency: json["baseCurrency"],
        basePrice: json["basePrice"]?.toDouble(),
        source: json["source"],
        sourceUrl: json["sourceURL"],
        previewUrl: json["previewURL"],
        thumbnailUrl: json["thumbnailURL"],
        galleryThumbnailUrl: json["galleryThumbnailURL"],
        assetData: json["assetData"],
        assetUrl: json["assetURL"],
        artistId: json["artistID"],
        originalFileUrl: json["originalFileURL"],
        initialSaleModel: json["initialSaleModel"],
        artworkMetadata: json["artworkMetadata"],
      );

  Map<String, dynamic> toJson() => {
        "artistName": artistName,
        "artistURL": artistUrl,
        "assetID": assetId,
        "title": title,
        "description": description,
        "medium": medium,
        "maxEdition": maxEdition,
        "baseCurrency": baseCurrency,
        "basePrice": basePrice,
        "source": source,
        "sourceURL": sourceUrl,
        "previewURL": previewUrl,
        "thumbnailURL": thumbnailUrl,
        "galleryThumbnailURL": galleryThumbnailUrl,
        "assetData": assetData,
        "assetURL": assetUrl,
        "artistID": artistId,
        "originalFileURL": originalFileUrl,
        "initialSaleModel": initialSaleModel,
        "artworkMetadata": artworkMetadata,
      };
}
