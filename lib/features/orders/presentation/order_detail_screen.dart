import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/order.dart';
import 'orders_screen.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (orders) {
        Order? order;
        try {
          order = orders.firstWhere((o) => Uri.decodeComponent(orderId) == o.id);
        } catch (_) {}

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Details')),
            body: const Center(child: Text('Order not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Order #${order.orderNumber}'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined,
                        color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.fulfillmentStatus.displayLabel,
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Placed on ${DateFormat('dd MMM yyyy').format(order.processedAt)}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Line items
              Text('Items', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 12),
              ...order.lineItems.map((item) => _LineItemTile(item: item)),
              const SizedBox(height: 20),
              const Divider(),

              // Shipping address
              if (order.shippingAddress != null) ...[
                const SizedBox(height: 16),
                Text('Delivery Address', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.shippingAddress!.formatted,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
              ],

              // Price breakdown
              const SizedBox(height: 16),
              Text('Price Details', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 12),
              if (order.subtotalPrice != null)
                _PriceRow(
                  label: 'Subtotal',
                  value: CurrencyFormatter.formatShopify(
                      order.subtotalPrice!.amount,
                      order.subtotalPrice!.currencyCode),
                ),
              if (order.totalShippingPrice != null) ...[
                const SizedBox(height: 6),
                _PriceRow(
                  label: 'Shipping',
                  value: order.totalShippingPrice!.value == 0
                      ? 'FREE'
                      : CurrencyFormatter.formatShopify(
                          order.totalShippingPrice!.amount,
                          order.totalShippingPrice!.currencyCode),
                ),
              ],
              const Divider(height: 20),
              _PriceRow(
                label: 'Total',
                value: CurrencyFormatter.formatShopify(
                    order.totalPrice.amount,
                    order.totalPrice.currencyCode),
                bold: true,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _LineItemTile extends StatelessWidget {
  final OrderLineItem item;
  const _LineItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!,
                width: 64,
                height: 80,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 64,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image_outlined, color: AppColors.textHint),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.bodyMedium),
                if (item.variantTitle != null &&
                    item.variantTitle != 'Default Title') ...[
                  const SizedBox(height: 2),
                  Text(item.variantTitle!, style: AppTextStyles.bodySmall),
                ],
                const SizedBox(height: 4),
                Text('Qty: ${item.quantity}',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (item.price != null)
            Text(
              CurrencyFormatter.formatShopify(
                  (item.price!.value * item.quantity).toString(),
                  item.price!.currencyCode),
              style: AppTextStyles.labelLarge,
            ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
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
        Text(value, style: style),
      ],
    );
  }
}
