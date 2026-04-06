import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/cart_item.dart';
import '../../providers/cart_provider.dart';

class CartItemTile extends ConsumerWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(item.lineId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(cartProvider.notifier).removeItem(item.lineId);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.saleRed,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 100,
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.accent),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.accent),
                      )
                    : Container(color: AppColors.accent),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productTitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.variantTitle.isNotEmpty &&
                      item.variantTitle != 'Default Title') ...[
                    const SizedBox(height: 4),
                    Text(
                      item.variantTitle,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                  // Selected options
                  if (item.selectedOptions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: item.selectedOptions
                          .map((o) => Text(
                                '${o.name}: ${o.value}',
                                style: AppTextStyles.bodySmall,
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Price + quantity row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.formatShopify(
                                item.price.amount, item.price.currencyCode),
                            style: AppTextStyles.priceTag.copyWith(fontSize: 15),
                          ),
                          if (item.isOnSale && item.compareAtPrice != null)
                            Text(
                              CurrencyFormatter.formatShopify(
                                  item.compareAtPrice!.amount,
                                  item.compareAtPrice!.currencyCode),
                              style: AppTextStyles.priceSale,
                            ),
                        ],
                      ),
                      // Quantity controls
                      _QuantityControls(item: item),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControls extends ConsumerWidget {
  final CartItem item;
  const _QuantityControls({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            onTap: () => ref
                .read(cartProvider.notifier)
                .updateQuantity(item.lineId, item.quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              item.quantity.toString(),
              style: AppTextStyles.labelLarge,
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: () => ref
                .read(cartProvider.notifier)
                .updateQuantity(item.lineId, item.quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
