import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/graphql/client.dart';
import '../../../core/graphql/mutations.dart';
import '../../../core/graphql/queries.dart';
import '../../../shared/models/cart_item.dart';

class CartRepository {
  const CartRepository._();
  static const CartRepository instance = CartRepository._();

  Future<CartState> createCart({
    required String variantId,
    required int quantity,
  }) async {
    final result = await ShopifyGraphQLClient.mutate(
      MutationOptions(
        document: gql(ShopifyMutations.cartCreateMutation),
        variables: {
          'input': {
            'lines': [
              {'merchandiseId': variantId, 'quantity': quantity}
            ],
          }
        },
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final cartData = result.data?['cartCreate']?['cart'] as Map<String, dynamic>?;
    if (cartData == null) throw Exception('Failed to create cart');
    return _parseCartState(cartData);
  }

  Future<CartState> addLines({
    required String cartId,
    required String variantId,
    required int quantity,
  }) async {
    final result = await ShopifyGraphQLClient.mutate(
      MutationOptions(
        document: gql(ShopifyMutations.cartLinesAddMutation),
        variables: {
          'cartId': cartId,
          'lines': [
            {'merchandiseId': variantId, 'quantity': quantity}
          ],
        },
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final cartData =
        result.data?['cartLinesAdd']?['cart'] as Map<String, dynamic>?;
    if (cartData == null) throw Exception('Failed to add to cart');
    return _parseCartState(cartData);
  }

  Future<CartState> updateLine({
    required String cartId,
    required String lineId,
    required int quantity,
  }) async {
    final result = await ShopifyGraphQLClient.mutate(
      MutationOptions(
        document: gql(ShopifyMutations.cartLinesUpdateMutation),
        variables: {
          'cartId': cartId,
          'lines': [
            {'id': lineId, 'quantity': quantity}
          ],
        },
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final cartData =
        result.data?['cartLinesUpdate']?['cart'] as Map<String, dynamic>?;
    if (cartData == null) throw Exception('Failed to update cart');
    return _parseCartState(cartData);
  }

  Future<CartState> removeLine({
    required String cartId,
    required String lineId,
  }) async {
    final result = await ShopifyGraphQLClient.mutate(
      MutationOptions(
        document: gql(ShopifyMutations.cartLinesRemoveMutation),
        variables: {
          'cartId': cartId,
          'lineIds': [lineId],
        },
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final cartData =
        result.data?['cartLinesRemove']?['cart'] as Map<String, dynamic>?;
    if (cartData == null) throw Exception('Failed to remove from cart');
    return _parseCartState(cartData);
  }

  Future<CartState> applyCoupon({
    required String cartId,
    required String code,
  }) async {
    final result = await ShopifyGraphQLClient.mutate(
      MutationOptions(
        document: gql(ShopifyMutations.cartDiscountCodesUpdateMutation),
        variables: {
          'cartId': cartId,
          'discountCodes': [code],
        },
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final cartData =
        result.data?['cartDiscountCodesUpdate']?['cart'] as Map<String, dynamic>?;
    if (cartData == null) throw Exception('Failed to apply coupon');
    return fetchCart(cartId: cartId);
  }

  Future<CartState> fetchCart({required String cartId}) async {
    final result = await ShopifyGraphQLClient.query(
      QueryOptions(
        document: gql(ShopifyQueries.cartQuery),
        variables: {'cartId': cartId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final cartData = result.data?['cart'] as Map<String, dynamic>?;
    if (cartData == null) throw Exception('Cart not found');
    return _parseCartState(cartData);
  }

  CartState _parseCartState(Map<String, dynamic> cartData) {
    final lines =
        (cartData['lines'] as Map<String, dynamic>?)?['edges'] as List<dynamic>? ?? [];
    final items = lines
        .map((e) => CartItem.fromLineNode(
            (e as Map<String, dynamic>)['node'] as Map<String, dynamic>))
        .toList();

    final cost = cartData['cost'] as Map<String, dynamic>? ?? {};
    final subtotalData =
        cost['subtotalAmount'] as Map<String, dynamic>? ?? {};
    final totalData = cost['totalAmount'] as Map<String, dynamic>? ?? {};

    final subtotal =
        double.tryParse(subtotalData['amount'] as String? ?? '0') ?? 0;
    final total =
        double.tryParse(totalData['amount'] as String? ?? '0') ?? 0;
    final currencyCode =
        subtotalData['currencyCode'] as String? ?? 'INR';

    final discountCodes = (cartData['discountCodes'] as List<dynamic>? ?? [])
        .where((d) => (d as Map<String, dynamic>)['applicable'] == true)
        .map((d) => (d as Map<String, dynamic>)['code'] as String)
        .toList();

    return CartState(
      cartId: cartData['id'] as String,
      checkoutUrl: cartData['checkoutUrl'] as String?,
      items: items,
      subtotal: subtotal,
      total: total,
      currencyCode: currencyCode,
      appliedDiscountCodes: discountCodes,
    );
  }
}
