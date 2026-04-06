import 'product.dart';

class CartItem {
  final String lineId;
  final String variantId;
  final String productId;
  final String productHandle;
  final String productTitle;
  final String variantTitle;
  final int quantity;
  final Money price;
  final Money? compareAtPrice;
  final String? imageUrl;
  final List<SelectedOption> selectedOptions;

  const CartItem({
    required this.lineId,
    required this.variantId,
    required this.productId,
    required this.productHandle,
    required this.productTitle,
    required this.variantTitle,
    required this.quantity,
    required this.price,
    this.compareAtPrice,
    this.imageUrl,
    this.selectedOptions = const [],
  });

  bool get isOnSale =>
      compareAtPrice != null && compareAtPrice!.value > price.value;

  double get lineTotalValue => price.value * quantity;

  CartItem copyWith({
    String? lineId,
    String? variantId,
    String? productId,
    String? productHandle,
    String? productTitle,
    String? variantTitle,
    int? quantity,
    Money? price,
    Money? compareAtPrice,
    String? imageUrl,
    List<SelectedOption>? selectedOptions,
  }) =>
      CartItem(
        lineId: lineId ?? this.lineId,
        variantId: variantId ?? this.variantId,
        productId: productId ?? this.productId,
        productHandle: productHandle ?? this.productHandle,
        productTitle: productTitle ?? this.productTitle,
        variantTitle: variantTitle ?? this.variantTitle,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        compareAtPrice: compareAtPrice ?? this.compareAtPrice,
        imageUrl: imageUrl ?? this.imageUrl,
        selectedOptions: selectedOptions ?? this.selectedOptions,
      );

  factory CartItem.fromLineNode(Map<String, dynamic> node) {
    final merchandise = node['merchandise'] as Map<String, dynamic>;
    final product = merchandise['product'] as Map<String, dynamic>;
    final cost = node['cost'] as Map<String, dynamic>;
    final amountPerQty = cost['amountPerQuantity'] as Map<String, dynamic>;
    final compareAtAmtPerQty =
        cost['compareAtAmountPerQuantity'] as Map<String, dynamic>?;

    // Get image: variant image or first product image
    String? imageUrl;
    if (merchandise['image'] != null) {
      imageUrl = (merchandise['image'] as Map<String, dynamic>)['url'] as String?;
    }
    if (imageUrl == null) {
      final productImages = (product['images'] as Map<String, dynamic>?)?['edges'];
      if (productImages != null && (productImages as List).isNotEmpty) {
        imageUrl = ((productImages[0] as Map<String, dynamic>)['node']
            as Map<String, dynamic>)['url'] as String?;
      }
    }

    return CartItem(
      lineId: node['id'] as String,
      variantId: merchandise['id'] as String,
      productId: product['id'] as String,
      productHandle: product['handle'] as String,
      productTitle: product['title'] as String,
      variantTitle: merchandise['title'] as String,
      quantity: node['quantity'] as int,
      price: Money.fromJson(amountPerQty),
      compareAtPrice: compareAtAmtPerQty != null
          ? Money.fromJson(compareAtAmtPerQty)
          : null,
      imageUrl: imageUrl,
      selectedOptions:
          (merchandise['selectedOptions'] as List<dynamic>? ?? [])
              .map((e) => SelectedOption.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class CartState {
  final String? cartId;
  final String? checkoutUrl;
  final List<CartItem> items;
  final double subtotal;
  final double total;
  final String currencyCode;
  final List<String> appliedDiscountCodes;
  final bool isLoading;
  final String? error;

  const CartState({
    this.cartId,
    this.checkoutUrl,
    this.items = const [],
    this.subtotal = 0.0,
    this.total = 0.0,
    this.currencyCode = 'INR',
    this.appliedDiscountCodes = const [],
    this.isLoading = false,
    this.error,
  });

  const CartState.empty()
      : cartId = null,
        checkoutUrl = null,
        items = const [],
        subtotal = 0.0,
        total = 0.0,
        currencyCode = 'INR',
        appliedDiscountCodes = const [],
        isLoading = false,
        error = null;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    String? cartId,
    String? checkoutUrl,
    List<CartItem>? items,
    double? subtotal,
    double? total,
    String? currencyCode,
    List<String>? appliedDiscountCodes,
    bool? isLoading,
    String? error,
  }) =>
      CartState(
        cartId: cartId ?? this.cartId,
        checkoutUrl: checkoutUrl ?? this.checkoutUrl,
        items: items ?? this.items,
        subtotal: subtotal ?? this.subtotal,
        total: total ?? this.total,
        currencyCode: currencyCode ?? this.currencyCode,
        appliedDiscountCodes: appliedDiscountCodes ?? this.appliedDiscountCodes,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}
