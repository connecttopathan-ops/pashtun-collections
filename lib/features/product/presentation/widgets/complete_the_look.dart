import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../shop/presentation/widgets/product_card.dart';
import '../../providers/product_provider.dart';

class CompleteTheLook extends ConsumerWidget {
  final String productHandle;
  final String collectionHandle;

  const CompleteTheLook({
    super.key,
    required this.productHandle,
    required this.collectionHandle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(relatedProductsProvider((
      productHandle: productHandle,
      collectionHandle: collectionHandle,
    )));

    return relatedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Complete the Look',
                  style: AppTextStyles.headlineMedium),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 160,
                  child: ProductCard(product: products[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
