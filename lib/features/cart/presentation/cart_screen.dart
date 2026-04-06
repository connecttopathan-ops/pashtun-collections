import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/cart_provider.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_summary.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();
  bool _couponLoading = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    setState(() => _couponLoading = true);
    await ref.read(cartProvider.notifier).applyCoupon(code);
    setState(() => _couponLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon applied!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Cart${cartState.totalQuantity > 0 ? ' (${cartState.totalQuantity})' : ''}'),
      ),
      body: cartState.isEmpty
          ? _EmptyCartView()
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 160),
                  children: [
                    ...cartState.items.map(
                        (item) => CartItemTile(item: item)),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Coupon field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                hintText: 'Promo / Coupon Code',
                                prefixIcon: Icon(Icons.local_offer_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _couponLoading ? null : _applyCoupon,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                            child: _couponLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Text('Apply'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Active discount codes
                    if (cartState.appliedDiscountCodes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 8,
                          children: cartState.appliedDiscountCodes
                              .map((code) => Chip(
                                    label: Text(code),
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.1),
                                    avatar: const Icon(Icons.check_circle,
                                        color: AppColors.primary, size: 16),
                                  ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CartSummary(cartState: cartState),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

                // Sticky checkout button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        12 + MediaQuery.of(context).padding.bottom),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cartState.isLoading
                            ? null
                            : () => context.push('/checkout'),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Discover our beautiful collections',
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
    );
  }
}
