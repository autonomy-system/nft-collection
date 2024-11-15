import 'package:nft_collection/data/api/indexer_api.dart';
import 'package:nft_collection/graphql/clients/indexer_client.dart';
import 'package:nft_collection/graphql/model/get_list_collection.dart';
import 'package:nft_collection/graphql/model/get_list_tokens.dart';
import 'package:nft_collection/graphql/model/identity.dart';
import 'package:nft_collection/graphql/queries/collection_queries.dart';
import 'package:nft_collection/graphql/queries/queries.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/models/identity.dart';
import 'package:nft_collection/models/user_collection.dart';

class IndexerService {
  final IndexerClient _client;
  final IndexerApi _indexerApi;

  IndexerService(this._client, this._indexerApi);

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

  Future<List<UserCollection>> getUserCollections(String address) async {
    return _indexerApi.getCollection(address, 100);
  }

  Future<List<UserCollection>> getCollectionsByAddresses(
      List<String> addresses) async {
    final vars = {'creators': addresses, 'size': 100, 'offset': 0};
    final res = await _client.query(doc: collectionQuery, vars: vars);
    final data = QueryListCollectionResponse.fromJson(res);
    return data.collections;
  }

  Future<List<AssetToken>> getCollectionListToken(String collectionId) async {
    final res = await _client.query(
        doc: getColectionTokenQuery,
        vars: {'collectionID': collectionId, 'offset': 0, 'size': 100});
    final data = QueryListTokensResponse.fromJson(res);
    return data.tokens;
  }
}
