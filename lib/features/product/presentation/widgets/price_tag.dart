import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/product.dart';

class PriceTag extends StatelessWidget {
  final Money price;
  final Money? compareAtPrice;
  final bool large;

  const PriceTag({
    super.key,
    required this.price,
    this.compareAtPrice,
    this.large = false,
  });

  bool get isOnSale =>
      compareAtPrice != null && compareAtPrice!.value > price.value;

  int get discountPercent => CurrencyFormatter.discountPercent(
        compareAtPrice?.value ?? 0,
        price.value,
      );

  @override
  Widget build(BuildContext context) {
    final formattedPrice = CurrencyFormatter.formatShopify(
        price.amount, price.currencyCode);
    final formattedCompare = compareAtPrice != null
        ? CurrencyFormatter.formatShopify(
            compareAtPrice!.amount, compareAtPrice!.currencyCode)
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          formattedPrice,
          style: large
              ? AppTextStyles.priceTag.copyWith(fontSize: 22)
              : AppTextStyles.priceTag,
        ),
        if (isOnSale && formattedCompare != null) ...[
          const SizedBox(width: 8),
          Text(
            formattedCompare,
            style: large
                ? AppTextStyles.priceSale.copyWith(fontSize: 16)
                : AppTextStyles.priceSale,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.saleRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-$discountPercent%',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.saleRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
