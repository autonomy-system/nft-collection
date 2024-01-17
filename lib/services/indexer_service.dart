import 'package:nft_collection/graphql/clients/indexer_client.dart';
import 'package:nft_collection/graphql/model/identity.dart';
import 'package:nft_collection/graphql/queries/queries.dart';
import 'package:nft_collection/graphql/model/get_list_tokens.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/models/identity.dart';

class IndexerService {
  final IndexerClient _client;

  IndexerService(this._client);

  Future<List<AssetToken>> getNftTokens(QueryListTokensRequest request) async {
    final vars = request.toJson();
    final result = await _client.query(
      doc: getTokens,
      vars: vars,
    );
    if (result == null) {
      return [];
    }
    final data = QueryListTokensResponse.fromJson(result);
    return data.tokens;
  }

  Future<Identity> getIdentity(QueryIdentityRequest request) async {
    final vars = request.toJson();
    final result = await _client.query(
      doc: identity,
      vars: vars,
    );
    if (result == null) {
      return Identity('', '', '');
    }
    final data = QueryIdentityResponse.fromJson(result);
    return data.identity;
  }
}
