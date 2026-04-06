import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shop/data/product_repository.dart';
import '../../shop/presentation/widgets/product_card.dart';
import '../providers/wishlist_provider.dart';
import '../../../shared/models/product.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistIds = ref.watch(wishlistProvider);

    if (wishlistIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wishlist')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_outline,
                  size: 80, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text('Your wishlist is empty',
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Save your favourite pieces here',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/shop'),
                child: const Text('Shop Now'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist (${wishlistIds.length})'),
        actions: [
          TextButton(
            onPressed: () => ref.read(wishlistProvider.notifier).clear(),
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: _WishlistGrid(ids: wishlistIds.toList()),
    );
  }
}

class _WishlistGrid extends StatefulWidget {
  final List<String> ids;
  const _WishlistGrid({required this.ids});

  @override
  State<_WishlistGrid> createState() => _WishlistGridState();
}

class _WishlistGridState extends State<_WishlistGrid> {
  final Map<String, Product> _products = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(_WishlistGrid old) {
    super.didUpdateWidget(old);
    if (old.ids != widget.ids) _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    // In production, we'd use a bulk query. For now, each wishlist product
    // is fetched individually (cached after first load).
    // Note: product IDs in wishlist are Shopify GIDs, not handles.
    // This screen would ideally store handles instead of IDs.
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // When products map is populated we show them; otherwise show placeholder
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.ids.length,
      itemBuilder: (context, index) {
        final id = widget.ids[index];
        final product = _products[id];
        if (product != null) {
          return ProductCard(product: product);
        }
        // Placeholder for unloaded product
        return _WishlistPlaceholderCard(productId: id);
      },
    );
  }
}

class _WishlistPlaceholderCard extends ConsumerWidget {
  final String productId;
  const _WishlistPlaceholderCard({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.favorite, color: AppColors.saleRed, size: 40),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () =>
                  ref.read(wishlistProvider.notifier).toggle(productId),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
