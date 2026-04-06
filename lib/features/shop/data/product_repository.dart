import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/graphql/client.dart';
import '../../../core/graphql/queries.dart';
import '../../../shared/models/product.dart';
import '../../../shared/models/collection.dart';

class ProductRepository {
  const ProductRepository._();

  static const ProductRepository instance = ProductRepository._();

  /// Returns (products, hasNextPage, endCursor)
  Future<(List<Product>, bool, String?)> getCollectionProducts({
    required String handle,
    int first = 20,
    String? after,
    String sortKey = 'COLLECTION_DEFAULT',
    bool reverse = false,
  }) async {
    final result = await ShopifyGraphQLClient.query(
      QueryOptions(
        document: gql(ShopifyQueries.getCollectionProductsQuery),
        variables: {
          'handle': handle,
          'first': first,
          if (after != null) 'after': after,
          'sortKey': sortKey,
          'reverse': reverse,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final collectionData =
        result.data?['collection'] as Map<String, dynamic>?;
    if (collectionData == null) return ([], false, null);

    final productsData =
        collectionData['products'] as Map<String, dynamic>? ?? {};
    final edges = productsData['edges'] as List<dynamic>? ?? [];
    final pageInfo =
        productsData['pageInfo'] as Map<String, dynamic>? ?? {};

    final products = edges
        .map((e) => Product.fromJson(
            (e as Map<String, dynamic>)['node'] as Map<String, dynamic>))
        .toList();
    final hasNextPage = pageInfo['hasNextPage'] as bool? ?? false;
    final endCursor = pageInfo['endCursor'] as String?;

    return (products, hasNextPage, endCursor);
  }

  Future<Product?> getProductByHandle(String handle) async {
    final result = await ShopifyGraphQLClient.query(
      QueryOptions(
        document: gql(ShopifyQueries.getProductByHandleQuery),
        variables: {'handle': handle},
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final productData =
        result.data?['product'] as Map<String, dynamic>?;
    if (productData == null) return null;
    return Product.fromJson(productData);
  }

  Future<List<Product>> getRelatedProducts({
    required String productHandle,
    required String collectionHandle,
    int first = 6,
  }) async {
    final result = await ShopifyGraphQLClient.query(
      QueryOptions(
        document: gql(ShopifyQueries.getRelatedProductsQuery),
        variables: {
          'productHandle': productHandle,
          'collectionHandle': collectionHandle,
          'first': first,
        },
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    );

    if (result.hasException) return [];

    final collectionData =
        result.data?['collection'] as Map<String, dynamic>?;
    final edges = (collectionData?['products'] as Map<String, dynamic>?)?[
            'edges'] as List<dynamic>? ??
        [];

    return edges
        .map((e) => Product.fromJson(
            (e as Map<String, dynamic>)['node'] as Map<String, dynamic>))
        .where((p) => p.handle != productHandle)
        .take(first)
        .toList();
  }

  Future<List<Collection>> getCollections({int first = 10}) async {
    final result = await ShopifyGraphQLClient.query(
      QueryOptions(
        document: gql(ShopifyQueries.getCollectionsQuery),
        variables: {'first': first},
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    );

    if (result.hasException) return [];

    final edges =
        (result.data?['collections'] as Map<String, dynamic>?)?['edges']
            as List<dynamic>? ??
        [];
    return edges
        .map((e) => Collection.fromJson(
            (e as Map<String, dynamic>)['node'] as Map<String, dynamic>))
        .toList();
  }
}
