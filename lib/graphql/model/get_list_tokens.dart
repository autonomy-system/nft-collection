import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/utils/constants.dart';

class QueryListTokensResponse {
  List<AssetToken> tokens;

  QueryListTokensResponse({
    required this.tokens,
  });

  factory QueryListTokensResponse.fromJson(Map<String, dynamic> map) {
    return QueryListTokensResponse(
      tokens: map['tokens'] != null
          ? List<AssetToken>.from(
              (map['tokens'] as List<dynamic>).map<AssetToken>(
                (x) => AssetToken.fromJsonGraphQl(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }
}

class QueryListTokensRequest {
  final List<String> owners;
  final List<String> ids;
  final DateTime? lastUpdatedAt;
  final int offset;
  final int size;

  QueryListTokensRequest({
    this.owners = const [],
    this.ids = const [],
    this.lastUpdatedAt,
    this.offset = 0,
    this.size = indexerTokensPageSize,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'owners': owners,
      'ids': ids,
      'lastUpdatedAt': lastUpdatedAt?.toUtc().toIso8601String(),
      'offset': offset,
      'size': size,
    };
  }
}
