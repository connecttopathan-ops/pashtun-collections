import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/product.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../wishlist/providers/wishlist_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(wishlistProvider).contains(product.id);
    final imageUrl = product.featuredImage?.url;
    final price = product.minPrice;
    final compareAt = product.compareAtMinPrice;

    return GestureDetector(
      onTap: () => context.push('/product/${product.handle}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.accent),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.accent,
                            child: const Icon(Icons.image_outlined,
                                color: AppColors.textHint, size: 40),
                          ),
                        )
                      : Container(
                          color: AppColors.accent,
                          child: const Icon(Icons.image_outlined,
                              color: AppColors.textHint, size: 40),
                        ),
                  // Sale badge
                  if (product.isOnSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SaleBadge(percent: product.discountPercent),
                    ),
                  // Out of stock overlay
                  if (!product.availableForSale)
                    Container(
                      color: Colors.black45,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SOLD OUT',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  // Wishlist button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(wishlistProvider.notifier)
                          .toggle(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? AppColors.saleRed : AppColors.textHint,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            product.title,
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Price
          if (price != null)
            Row(
              children: [
                Text(
                  CurrencyFormatter.formatShopify(
                      price.amount, price.currencyCode),
                  style: AppTextStyles.priceTag.copyWith(fontSize: 14),
                ),
                if (compareAt != null && compareAt.value > price.value) ...[
                  const SizedBox(width: 6),
                  Text(
                    CurrencyFormatter.formatShopify(
                        compareAt.amount, compareAt.currencyCode),
                    style: AppTextStyles.priceSale.copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
