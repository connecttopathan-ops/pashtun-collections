import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../providers/home_provider.dart';
import '../../../shop/presentation/widgets/product_card.dart';

class NewArrivalsGrid extends ConsumerStatefulWidget {
  const NewArrivalsGrid({super.key});

  @override
  ConsumerState<NewArrivalsGrid> createState() => _NewArrivalsGridState();
}

class _NewArrivalsGridState extends ConsumerState<NewArrivalsGrid> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(newArrivalsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newArrivalsProvider);

    return state.when(
      loading: () => const ProductGridSkeleton(),
      error: (e, _) => Center(
        child: Text('Could not load products: $e'),
      ),
      data: (arrivalsState) {
        final products = arrivalsState.products;
        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  ProductCard(product: products[index]),
            ),
            if (arrivalsState.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            if (arrivalsState.hasMore && !arrivalsState.isLoadingMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: OutlinedButton(
                  onPressed: () =>
                      ref.read(newArrivalsProvider.notifier).loadMore(),
                  child: const Text('Load More'),
                ),
              ),
          ],
        );
      },
    );
  }
}
