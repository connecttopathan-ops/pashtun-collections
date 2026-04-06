import 'package:graphql_flutter/graphql_flutter.dart';
import '../constants/api_constants.dart';

class ShopifyGraphQLClient {
  ShopifyGraphQLClient._();

  static GraphQLClient? _client;

  static GraphQLClient get instance {
    _client ??= _buildClient();
    return _client!;
  }

  static GraphQLClient _buildClient() {
    final httpLink = HttpLink(
      ApiConstants.shopifyGraphqlEndpoint,
      defaultHeaders: {
        ApiConstants.storefrontAccessTokenHeader: ApiConstants.storefrontToken,
        'Content-Type': 'application/json',
      },
    );

    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  static Future<QueryResult> query(QueryOptions options) async {
    return instance.query(options);
  }

  static Future<QueryResult> mutate(MutationOptions options) async {
    return instance.mutate(options);
  }
}
