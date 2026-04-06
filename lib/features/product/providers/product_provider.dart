import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/product.dart';
import '../../shop/providers/products_provider.dart';

// Re-export from shop providers
export '../../shop/providers/products_provider.dart'
    show productProvider, relatedProductsProvider;

// Selected variant state per product handle
final selectedVariantProvider =
    StateProvider.family<ProductVariant?, String>((ref, handle) => null);

// Selected options per product handle
final selectedOptionsProvider =
    StateProvider.family<Map<String, String>, String>(
        (ref, handle) => const {});
