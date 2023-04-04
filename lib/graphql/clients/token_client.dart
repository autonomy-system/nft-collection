
import 'package:graphql_flutter/graphql_flutter.dart';

class TokenClient {
  GraphQLClient getClient({String? token}) {
    // should get from env
    const url = "https://indexer.autonomy.io/v2/graphql";
    final HttpLink httpLink = HttpLink(
      url,
    );
    final AuthLink authLink = AuthLink(
      getToken: () => token,
    );
    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  Future<Map<String, dynamic>?> query({
    required String doc,
    Map<String, dynamic> vars = const {},
    bool withToken = false,
  }) async {
    try {
      final client = getClient(token: withToken ? await _getToken() : null);
      final options = QueryOptions(
        document: gql(doc),
        variables: vars,
      );
      final result = await client.query(options);
      return result.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> mutate({
    required String doc,
    Map<String, dynamic> vars = const {},
    bool withToken = false,
  }) async {
    try {
      final client = getClient(token: withToken ? await _getToken() : null);
      final options = MutationOptions(
        document: gql(doc),
        variables: vars,
      );
      final result = await client.mutate(options);
      return result.data;
    } catch (e) {
      return null;
    }
  }

  Future<String> _getToken() async {
    return "";
  }
}
