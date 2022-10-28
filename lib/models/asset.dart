//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:nft_collection/models/provenance.dart';

class Asset {
  Asset({
    required this.id,
    required this.edition,
    required this.blockchain,
    required this.fungible,
    required this.mintedAt,
    required this.contractType,
    required this.tokenId,
    required this.contractAddress,
    required this.blockchainURL,
    required this.balance,
    required this.owner,
    required this.owners,
    required this.thumbnailID,
    required this.projectMetadata,
    required this.lastActivityTime,
    required this.provenance,
  });

  String id;
  int edition;
  String blockchain;
  bool fungible;
  DateTime mintedAt;
  String contractType;
  String? tokenId;
  String? contractAddress;
  String? blockchainURL;
  int? balance;
  String owner;
  Map<String, int>
      owners; // Map from owner's address to number of owned tokens.
  String thumbnailID;
  ProjectMetadata projectMetadata;
  DateTime lastActivityTime;
  List<Provenance> provenance;

  factory Asset.fromJson(Map<String, dynamic> json) {
    final Map<String, int> owners = json["owners"]?.map<String, int>(
            (key, value) => MapEntry(key as String, (value as int?) ?? 0)) ??
        {};

    return Asset(
      id: json["indexID"],
      edition: json["edition"],
      blockchain: json["blockchain"],
      fungible: json["fungible"] == true,
      mintedAt: DateTime.parse(json["mintedAt"]),
      contractType: json["contractType"],
      tokenId: json["id"],
      contractAddress: json["contractAddress"],
      blockchainURL: json["blockchainURL"],
      balance: json["balance"],
      owner: json["owner"],
      owners: owners,
      thumbnailID: json["thumbnailID"],
      projectMetadata: ProjectMetadata.fromJson(json["projectMetadata"]),
      lastActivityTime: DateTime.parse(json['lastActivityTime']),
      provenance: json["provenance"] != null
          ? (json["provenance"] as List<dynamic>)
              .asMap()
              .map<int, Provenance>((key, value) => MapEntry(
                  key, Provenance.fromJson(value, json['indexID'], key)))
              .values
              .toList()
          : [],
    );
  }

  String? get saleModel {
    String? latestSaleModel = projectMetadata.latest.initialSaleModel?.trim();
    return latestSaleModel?.isNotEmpty == true
        ? latestSaleModel
        : projectMetadata.origin.initialSaleModel;
  }
}

class ProjectMetadata {
  ProjectMetadata({
    required this.origin,
    required this.latest,
  });

  ProjectMetadataData origin;
  ProjectMetadataData latest;

  factory ProjectMetadata.fromJson(Map<String, dynamic> json) =>
      ProjectMetadata(
        origin: ProjectMetadataData.fromJson(json["origin"]),
        latest: ProjectMetadataData.fromJson(json["latest"]),
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
      };
}
