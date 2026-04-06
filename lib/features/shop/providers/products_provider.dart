import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/product.dart';
import '../data/product_repository.dart';

// ─── Filter / Sort ────────────────────────────────────────────────────────────

class FilterOptions {
  final String sortKey;
  final bool reverse;
  final String? selectedSize;
  final bool saleOnly;

  const FilterOptions({
    this.sortKey = 'COLLECTION_DEFAULT',
    this.reverse = false,
    this.selectedSize,
    this.saleOnly = false,
  });

  FilterOptions copyWith({
    String? sortKey,
    bool? reverse,
    String? selectedSize,
    bool? saleOnly,
    bool clearSize = false,
  }) =>
      FilterOptions(
        sortKey: sortKey ?? this.sortKey,
        reverse: reverse ?? this.reverse,
        selectedSize: clearSize ? null : (selectedSize ?? this.selectedSize),
        saleOnly: saleOnly ?? this.saleOnly,
      );
}

// ─── Collection Products State ────────────────────────────────────────────────

class CollectionProductsState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final bool hasMore;
  final String? cursor;
  final bool isLoadingMore;
  final FilterOptions filter;

  const CollectionProductsState({
    this.products = const [],
    this.filteredProducts = const [],
    this.hasMore = true,
    this.cursor,
    this.isLoadingMore = false,
    this.filter = const FilterOptions(),
  });

  CollectionProductsState copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    bool? hasMore,
    String? cursor,
    bool? isLoadingMore,
    FilterOptions? filter,
  }) =>
      CollectionProductsState(
        products: products ?? this.products,
        filteredProducts: filteredProducts ?? this.filteredProducts,
        hasMore: hasMore ?? this.hasMore,
        cursor: cursor ?? this.cursor,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        filter: filter ?? this.filter,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CollectionProductsNotifier
    extends FamilyAsyncNotifier<CollectionProductsState, String> {
  static const _pageSize = 20;

  @override
  Future<CollectionProductsState> build(String handle) async {
    final result = await ProductRepository.instance.getCollectionProducts(
      handle: handle,
      first: _pageSize,
    );
    final state = CollectionProductsState(
      products: result.$1,
      filteredProducts: result.$1,
      hasMore: result.$2,
      cursor: result.$3,
    );
    return state;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final result = await ProductRepository.instance.getCollectionProducts(
        handle: arg,
        first: _pageSize,
        after: current.cursor,
        sortKey: current.filter.sortKey,
        reverse: current.filter.reverse,
      );
      final allProducts = [...current.products, ...result.$1];
      state = AsyncData(current.copyWith(
        products: allProducts,
        filteredProducts: _applyFilter(allProducts, current.filter),
        hasMore: result.$2,
        cursor: result.$3,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> applyFilter(FilterOptions filter) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Re-fetch with new sort if needed
    if (filter.sortKey != current.filter.sortKey ||
        filter.reverse != current.filter.reverse) {
      state = const AsyncLoading();
      try {
        final result = await ProductRepository.instance.getCollectionProducts(
          handle: arg,
          first: _pageSize,
          sortKey: filter.sortKey,
          reverse: filter.reverse,
        );
        state = AsyncData(CollectionProductsState(
          products: result.$1,
          filteredProducts: _applyFilter(result.$1, filter),
          hasMore: result.$2,
          cursor: result.$3,
          filter: filter,
        ));
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    } else {
      state = AsyncData(current.copyWith(
        filter: filter,
        filteredProducts: _applyFilter(current.products, filter),
      ));
    }
  }

  List<Product> _applyFilter(List<Product> products, FilterOptions filter) {
    return products.where((p) {
      if (filter.saleOnly && !p.isOnSale) return false;
      if (filter.selectedSize != null &&
          !p.sizeOptions.contains(filter.selectedSize)) return false;
      return true;
    }).toList();
  }
}

final collectionProductsProvider = AsyncNotifierProviderFamily<
    CollectionProductsNotifier, CollectionProductsState, String>(
  CollectionProductsNotifier.new,
);

// ─── Single Product ───────────────────────────────────────────────────────────

final productProvider =
    FutureProvider.family<Product?, String>((ref, handle) async {
  return ProductRepository.instance.getProductByHandle(handle);
});

// ─── Related Products ─────────────────────────────────────────────────────────

final relatedProductsProvider = FutureProvider.family<List<Product>,
    ({String productHandle, String collectionHandle})>((ref, args) async {
  return ProductRepository.instance.getRelatedProducts(
    productHandle: args.productHandle,
    collectionHandle: args.collectionHandle,
  );
});
