import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/models/asset.dart' as indexer;
import 'package:nft_collection/models/origin_token_info.dart';
import 'package:nft_collection/models/provenance.dart';

class FullTokens {
  List<Token> tokens;

  // constructor
  FullTokens({
    required this.tokens,
  });

  // factory constructor
  factory FullTokens.fromJson(Map<String, dynamic> json) {
    return FullTokens(
      tokens: List<Token>.from(json['tokens'].map((x) => Token.fromJson(x))),
    );
  }
}


class Token {
  String id;
  String blockchain;
  bool fungible;
  String contractType;
  String contractAddress;
  int edition;
  String editionName;
  DateTime? mintAt;
  int balance;
  String owner;
  String indexID;
  String source;
  bool swapped;
  bool burned;
  List<Provenance> provenance;
  DateTime? lastActivityTime;
  DateTime? lastRefreshedTime;
  Asset asset;

  // constructor
  Token({
    required this.id,
    required this.blockchain,
    required this.fungible,
    required this.contractType,
    required this.contractAddress,
    required this.edition,
    required this.editionName,
    required this.mintAt,
    required this.balance,
    required this.owner,
    required this.indexID,
    required this.source,
    required this.swapped,
    required this.burned,
    required this.provenance,
    this.lastActivityTime,
    this.lastRefreshedTime,
    required this.asset,
  });

  // factory constructor
  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'],
      blockchain: json['blockchain'],
      fungible: json['fungible'],
      contractType: json['contractType'],
      contractAddress: json['contractAddress'],
      edition: json['edition'],
      editionName: json['editionName'],
      mintAt: json['mintAt'] != null ? DateTime.parse(json['mintAt']) : null,
      balance: json['balance'],
      owner: json['owner'],
      indexID: json['indexID'],
      source: json['source'],
      swapped: json['swapped'],
      burned: json['burned'],
      provenance: json["provenance"] != null
          ? (json["provenance"] as List<dynamic>)
          .asMap()
          .map<int, Provenance>((key, value) =>
          MapEntry(
              key, Provenance.fromJson(value, json['indexID'], key)))
          .values
          .toList()
          : [],
      lastActivityTime: json['lastActivityTime'] != null
          ? DateTime.parse(json['lastActivityTime'])
          : null,
      lastRefreshedTime: json['lastRefreshedTime'] != null
          ? DateTime.parse(json['lastRefreshedTime'])
          : null,
      asset: Asset.fromJson(json['asset']),
    );
  }

  AssetToken toAssetToken() {
    return AssetToken(
      id: indexID,
      blockchain: blockchain,
      fungible: fungible,
      contractType: contractType,
      contractAddress: contractAddress,
      edition: edition,
      editionName: editionName,
      mintedAt: mintAt,
      balance: balance,
      owner: owner,
      tokenId: id,
      swapped: swapped,
      burned: burned,
      provenance: provenance,
      lastActivityTime: lastActivityTime ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastRefreshedTime: lastRefreshedTime ??
          DateTime.fromMillisecondsSinceEpoch(0),
      asset: indexer.Asset(
        asset.indexID,
        asset.thumbnailID,
        asset.lastRefreshedTime,
        asset.metadata.project.latest.artistID,
        asset.metadata.project.latest.artistName,
        asset.metadata.project.latest.artistURL,
        asset.metadata.project.latest.assetID,
        asset.metadata.project.latest.title,
        asset.metadata.project.latest.description,
        asset.metadata.project.latest.mimeType,
        asset.metadata.project.latest.medium,
        asset.metadata.project.latest.maxEdition,
        asset.metadata.project.latest.source,
        asset.metadata.project.latest.sourceURL,
        asset.metadata.project.latest.previewURL,
        asset.metadata.project.latest.thumbnailURL,
        asset.metadata.project.latest.galleryThumbnailURL,
        asset.metadata.project.latest.assetData,
        asset.metadata.project.latest.assetURL,
        null,
        null,
        null,
      ),
      owners: {},
      originTokenInfo: provenance.map((e) => OriginTokenInfo(
        id: e.id,
        blockchain: e.blockchain,
        fungible: e.fungible,
        contractType: e.type,
      )).toList(),

    );
  }
}

class Asset {
  String indexID;
  String thumbnailID;
  DateTime? lastRefreshedTime;
  AssetMetadata metadata;

  // constructor
  Asset({
    required this.indexID,
    required this.thumbnailID,
    required this.lastRefreshedTime,
    required this.metadata,
  });

  // factory constructor
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      indexID: json['indexID'],
      thumbnailID: json['thumbnailID'],
      lastRefreshedTime: json['lastRefreshedTime'] != null
          ? DateTime.parse(json['lastRefreshedTime'])
          : null,
      metadata: AssetMetadata.fromJson(json['metadata']),
    );
  }
}

class AssetMetadata {
  VersionedProjectMetadata project;

  // constructor
  AssetMetadata({
    required this.project,
  });

  // factory constructor
  factory AssetMetadata.fromJson(Map<String, dynamic> json) {
    return AssetMetadata(
      project: VersionedProjectMetadata.fromJson(json['project']),
    );
  }
}

class VersionedProjectMetadata {
  ProjectMetadata origin;
  ProjectMetadata latest;

  // constructor
  VersionedProjectMetadata({
    required this.origin,
    required this.latest,
  });

  // factory constructor
  factory VersionedProjectMetadata.fromJson(Map<String, dynamic> json) {
    return VersionedProjectMetadata(
      origin: ProjectMetadata.fromJson(json['origin']),
      latest: ProjectMetadata.fromJson(json['latest']),
    );
  }
}

class ProjectMetadata {
  String artistID;
  String artistName;
  String artistURL;
  String assetID;
  String title;
  String description;
  String mimeType;
  String medium;
  int maxEdition;
  String baseCurrency;
  int basePrice;
  String source;
  String sourceURL;
  String previewURL;
  String thumbnailURL;
  String galleryThumbnailURL;
  String assetData;
  String assetURL;

  // constructor
  ProjectMetadata({
    required this.artistID,
    required this.artistName,
    required this.artistURL,
    required this.assetID,
    required this.title,
    required this.description,
    required this.mimeType,
    required this.medium,
    required this.maxEdition,
    required this.baseCurrency,
    required this.basePrice,
    required this.source,
    required this.sourceURL,
    required this.previewURL,
    required this.thumbnailURL,
    required this.galleryThumbnailURL,
    required this.assetData,
    required this.assetURL,
  });

  // factory constructor
  factory ProjectMetadata.fromJson(Map<String, dynamic> json) {
    return ProjectMetadata(
      artistID: json['artistID'],
      artistName: json['artistName'],
      artistURL: json['artistURL'],
      assetID: json['assetID'],
      title: json['title'],
      description: json['description'],
      mimeType: json['mimeType'],
      medium: json['medium'],
      maxEdition: json['maxEdition'],
      baseCurrency: json['baseCurrency'],
      basePrice: json['basePrice'],
      source: json['source'],
      sourceURL: json['sourceURL'],
      previewURL: json['previewURL'],
      thumbnailURL: json['thumbnailURL'],
      galleryThumbnailURL: json['galleryThumbnailURL'],
      assetData: json['assetData'],
      assetURL: json['assetURL'],
    );
  }
}


