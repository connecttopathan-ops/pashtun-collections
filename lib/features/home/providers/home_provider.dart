import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/collection.dart';
import '../../../shared/models/product.dart';
import '../../shop/data/product_repository.dart';

// ─── Collections ────────────────────────────────────────────────────────────

final collectionsProvider = FutureProvider<List<Collection>>((ref) async {
  return ProductRepository.instance.getCollections(first: 10);
});

// ─── New Arrivals ────────────────────────────────────────────────────────────

class NewArrivalsState {
  final List<Product> products;
  final bool hasMore;
  final String? cursor;
  final bool isLoadingMore;

  const NewArrivalsState({
    this.products = const [],
    this.hasMore = true,
    this.cursor,
    this.isLoadingMore = false,
  });

  NewArrivalsState copyWith({
    List<Product>? products,
    bool? hasMore,
    String? cursor,
    bool? isLoadingMore,
  }) =>
      NewArrivalsState(
        products: products ?? this.products,
        hasMore: hasMore ?? this.hasMore,
        cursor: cursor ?? this.cursor,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class NewArrivalsNotifier extends AsyncNotifier<NewArrivalsState> {
  static const _handle = 'new-arrivals';
  static const _pageSize = 10;

  @override
  Future<NewArrivalsState> build() async {
    final result = await ProductRepository.instance.getCollectionProducts(
      handle: _handle,
      first: _pageSize,
    );
    return NewArrivalsState(
      products: result.$1,
      hasMore: result.$2,
      cursor: result.$3,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final result = await ProductRepository.instance.getCollectionProducts(
        handle: _handle,
        first: _pageSize,
        after: current.cursor,
      );
      state = AsyncData(current.copyWith(
        products: [...current.products, ...result.$1],
        hasMore: result.$2,
        cursor: result.$3,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final newArrivalsProvider =
    AsyncNotifierProvider<NewArrivalsNotifier, NewArrivalsState>(
        NewArrivalsNotifier.new);

// ─── Flash Sale ──────────────────────────────────────────────────────────────

class FlashSale {
  final String title;
  final String subtitle;
  final DateTime endsAt;
  final String collectionHandle;

  const FlashSale({
    required this.title,
    required this.subtitle,
    required this.endsAt,
    required this.collectionHandle,
  });
}

final flashSaleProvider = Provider<FlashSale?>((ref) {
  // In production, fetch from Shopify metaobjects or a CMS.
  final now = DateTime.now();
  final saleEnd = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
  if (now.isBefore(saleEnd)) {
    return FlashSale(
      title: 'Flash Sale',
      subtitle: 'Up to 40% off on selected suits',
      endsAt: saleEnd,
      collectionHandle: 'flash-sale',
    );
  }
  return null;
});

// ─── Hero Banners ────────────────────────────────────────────────────────────

class HeroBanner {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String ctaRoute;

  const HeroBanner({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.ctaRoute,
  });
}

final heroBannersProvider = Provider<List<HeroBanner>>((ref) {
  // Replace with CMS/Shopify metaobjects data in production.
  return const [
    HeroBanner(
      imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800',
      title: 'New Bridal Collection',
      subtitle: 'Exquisite embroidery, timeless grace',
      ctaLabel: 'Explore Bridal',
      ctaRoute: '/collection/bridal-collection',
    ),
    HeroBanner(
      imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800',
      title: 'Festive Season',
      subtitle: 'Celebrate in luxurious Zari work',
      ctaLabel: 'Shop Festive',
      ctaRoute: '/collection/festive-collection',
    ),
    HeroBanner(
      imageUrl: 'https://images.unsplash.com/photo-1594938298603-d8b0fae75e6c?w=800',
      title: 'Casual Elegance',
      subtitle: 'Effortless style for every day',
      ctaLabel: 'View Collection',
      ctaRoute: '/collection/casual-wear',
    ),
  ];
});
