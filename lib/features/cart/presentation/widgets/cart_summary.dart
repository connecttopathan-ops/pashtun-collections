import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/cart_item.dart';

class CartSummary extends StatelessWidget {
  final CartState cartState;

  const CartSummary({super.key, required this.cartState});

  static const _freeShippingThresholdINR = 999.0;

  bool get _isFreeShipping =>
      cartState.currencyCode == 'INR' &&
      cartState.subtotal >= _freeShippingThresholdINR;

  double get _shippingCost {
    if (_isFreeShipping) return 0.0;
    if (cartState.currencyCode == 'INR') return 99.0;
    if (cartState.currencyCode == 'USD') return 9.99;
    if (cartState.currencyCode == 'GBP') return 6.99;
    if (cartState.currencyCode == 'AED') return 29.0;
    return 0.0;
  }

  double get _discount => (cartState.subtotal + _shippingCost) - cartState.total;

  @override
  Widget build(BuildContext context) {
    final cc = cartState.currencyCode;
    final subtotalFormatted =
        CurrencyFormatter.formatShopify(cartState.subtotal.toString(), cc);
    final shippingFormatted =
        _shippingCost == 0 ? 'FREE' : CurrencyFormatter.formatShopify(_shippingCost.toString(), cc);
    final totalFormatted =
        CurrencyFormatter.formatShopify(cartState.total.toString(), cc);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: subtotalFormatted),
          if (_discount > 0.01) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Discount',
              value:
                  '- ${CurrencyFormatter.formatShopify(_discount.toString(), cc)}',
              valueColor: AppColors.saleRed,
            ),
          ],
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Shipping',
            value: shippingFormatted,
            valueColor:
                _isFreeShipping ? const Color(0xFF22C55E) : null,
          ),
          const Divider(height: 20),
          _SummaryRow(
            label: 'Total',
            value: totalFormatted,
            bold: true,
          ),
          if (cartState.currencyCode == 'INR' && !_isFreeShipping) ...[
            const SizedBox(height: 8),
            Text(
              'Add ₹${(_freeShippingThresholdINR - cartState.subtotal).ceil()} more for FREE delivery',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.labelLarge.copyWith(fontSize: 16)
        : AppTextStyles.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
