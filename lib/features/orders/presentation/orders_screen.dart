import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/graphql/client.dart';
import '../../../core/graphql/queries.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/order.dart';
import '../../auth/providers/auth_provider.dart';

final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isLoggedIn || auth.accessToken == null) return [];

  final result = await ShopifyGraphQLClient.query(
    QueryOptions(
      document: gql(ShopifyQueries.getCustomerOrdersQuery),
      variables: {
        'customerAccessToken': auth.accessToken,
        'first': 20,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );

  if (result.hasException) throw Exception(result.exception.toString());

  final orders = (result.data?['customer']?['orders']?['edges'] as List<dynamic>? ?? [])
      .map((e) => Order.fromJson(
          (e as Map<String, dynamic>)['node'] as Map<String, dynamic>))
      .toList();
  return orders;
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Orders')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 80, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text('Sign in to view orders',
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Track and manage your purchases',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(ordersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.saleRed),
              const SizedBox(height: 12),
              Text('Failed to load orders', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(ordersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 80, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No orders yet', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Shop our collections to place your first order',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/shop'),
                    child: const Text('Shop Now'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _OrderTile(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy').format(order.processedAt);
    final priceStr = CurrencyFormatter.formatShopify(
        order.totalPrice.amount, order.totalPrice.currencyCode);

    return GestureDetector(
      onTap: () => context.push('/order/${Uri.encodeComponent(order.id)}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: AppTextStyles.labelLarge,
                ),
                _StatusChip(status: order.fulfillmentStatus),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: AppTextStyles.bodySmall),
                Text(priceStr, style: AppTextStyles.priceTag.copyWith(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.lineItems.length} item${order.lineItems.length > 1 ? 's' : ''}',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderFulfillmentStatus status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case OrderFulfillmentStatus.fulfilled:
        return const Color(0xFF22C55E);
      case OrderFulfillmentStatus.inProgress:
        return AppColors.primary;
      case OrderFulfillmentStatus.unfulfilled:
      case OrderFulfillmentStatus.pendingFulfillment:
        return const Color(0xFFEAB308);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayLabel,
        style: AppTextStyles.labelSmall.copyWith(color: _color, fontSize: 11),
      ),
    );
  }
}
