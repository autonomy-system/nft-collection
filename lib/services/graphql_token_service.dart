import 'package:nft_collection/graphql/clients/token_client.dart';
import 'package:nft_collection/graphql/queries/token_queries.dart';
import 'package:nft_collection/graphql/responseModels/tokensFullData.dart';
import 'package:nft_collection/models/asset_token.dart';

class GraphqlTokenService {
  Future<List<AssetToken>> getNftTokensByOwner(
    String owner,
    int offset,
    int size,
    int? lastUpdatedAt,
  ) async {
    final vars = {
      'owner': owner,
      'offset': offset,
      'size': size,
      'lastUpdatedAt': lastUpdatedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastUpdatedAt ~/ 1000)
              .toIso8601String(),
    };
    final client = TokenClient();
    final result = await client.query(doc: tokensByOwnerAllQuery, vars: vars);
    if (result == null) {
      return [];
    }
    final data = FullTokens.fromJson(result);
    return data.tokens;
  }
}
