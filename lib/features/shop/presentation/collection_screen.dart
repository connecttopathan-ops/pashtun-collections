import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../providers/products_provider.dart';
import 'widgets/product_card.dart';
import 'widgets/filter_bottom_sheet.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  final String handle;
  final String title;

  const CollectionScreen({
    super.key,
    required this.handle,
    required this.title,
  });

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(collectionProductsProvider(widget.handle).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openFilter(CollectionProductsState current) async {
    final result =
        await showFilterSheet(context, current.filter);
    if (result != null && mounted) {
      ref
          .read(collectionProductsProvider(widget.handle).notifier)
          .applyFilter(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collectionProductsProvider(widget.handle));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (state.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => _openFilter(state.value!),
            ),
        ],
      ),
      body: state.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ProductGridSkeleton(),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.saleRed),
              const SizedBox(height: 12),
              Text(
                'Failed to load products',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref
                    .invalidate(collectionProductsProvider(widget.handle)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (collectionState) {
          final products = collectionState.filteredProducts;

          if (products.isEmpty && !collectionState.isLoadingMore) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('No products found',
                      style: AppTextStyles.bodyLarge),
                  if (collectionState.filter.selectedSize != null ||
                      collectionState.filter.saleOnly) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref
                          .read(collectionProductsProvider(widget.handle)
                              .notifier)
                          .applyFilter(const FilterOptions()),
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ],
              ),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Active filter chips
              if (collectionState.filter.selectedSize != null ||
                  collectionState.filter.saleOnly)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (collectionState.filter.selectedSize != null)
                          Chip(
                            label: Text(
                                'Size: ${collectionState.filter.selectedSize}'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => ref
                                .read(collectionProductsProvider(widget.handle)
                                    .notifier)
                                .applyFilter(collectionState.filter
                                    .copyWith(clearSize: true)),
                          ),
                        if (collectionState.filter.saleOnly)
                          Chip(
                            label: const Text('Sale Only'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => ref
                                .read(collectionProductsProvider(widget.handle)
                                    .notifier)
                                .applyFilter(collectionState.filter
                                    .copyWith(saleOnly: false)),
                          ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(product: products[index]),
                    childCount: products.length,
                  ),
                ),
              ),
              if (collectionState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}
