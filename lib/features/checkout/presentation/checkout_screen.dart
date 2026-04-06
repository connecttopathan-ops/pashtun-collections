import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/analytics.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/order.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../loyalty/providers/loyalty_provider.dart';
import '../services/razorpay_service.dart';
import 'address_screen.dart';

enum _PaymentMethod { razorpay, stripe, cod }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  ShippingAddress? _address;
  _PaymentMethod _paymentMethod = _PaymentMethod.razorpay;
  bool _isPlacingOrder = false;
  RazorpayService? _razorpayService;

  @override
  void initState() {
    super.initState();
    _detectDefaultPayment();
  }

  void _detectDefaultPayment() {
    final cart = ref.read(cartProvider);
    if (cart.currencyCode == 'INR') {
      _paymentMethod = _PaymentMethod.razorpay;
    } else {
      _paymentMethod = _PaymentMethod.stripe;
    }
  }

  @override
  void dispose() {
    _razorpayService?.dispose();
    super.dispose();
  }

  Future<void> _selectAddress() async {
    final result = await context.push<ShippingAddress>('/checkout/address');
    if (result != null) {
      setState(() => _address = result);
    }
  }

  Future<void> _placeOrder() async {
    if (_address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a delivery address')),
      );
      return;
    }

    final cart = ref.read(cartProvider);
    final auth = ref.read(authProvider);

    setState(() => _isPlacingOrder = true);

    Analytics.checkoutStarted(
      cartValue: cart.total,
      itemCount: cart.totalQuantity,
    );

    try {
      if (_paymentMethod == _PaymentMethod.razorpay) {
        _razorpayService?.dispose();
        _razorpayService = RazorpayService();
        _razorpayService!.onSuccess = (res) => _onPaymentSuccess(res.paymentId ?? '');
        _razorpayService!.onError = (res) {
          setState(() => _isPlacingOrder = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message ?? 'Payment failed')),
          );
        };
        _razorpayService!.openCheckout(
          amount: cart.total,
          orderId: 'PC_${DateTime.now().millisecondsSinceEpoch}',
          customerName:
              '${auth.customerFirstName ?? ''} ${auth.customerLastName ?? ''}'
                  .trim(),
          customerEmail: auth.customerEmail ?? '',
          customerPhone: _address!.phone ?? '',
        );
      } else if (_paymentMethod == _PaymentMethod.cod) {
        // COD: immediately confirm
        await _onPaymentSuccess('COD_${DateTime.now().millisecondsSinceEpoch}');
      } else {
        // Stripe: In production, get clientSecret from your backend
        // For now, show a message
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Stripe checkout requires backend integration for PaymentIntent')),
        );
      }
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _onPaymentSuccess(String paymentId) async {
    final cart = ref.read(cartProvider);
    final orderNumber = '#PC${DateTime.now().millisecondsSinceEpoch % 100000}';
    final pointsEarned = (cart.total / 100).floor() * 10;

    await ref.read(loyaltyProvider.notifier).awardPoints(pointsEarned);
    await ref.read(cartProvider.notifier).clearCart();

    Analytics.orderCompleted(
      orderId: paymentId,
      revenue: cart.total,
      paymentMethod: paymentId.startsWith('COD_') ? 'cod' : 'razorpay',
    );

    if (mounted) {
      context.go(
          '/order-confirmation?orderNumber=${Uri.encodeComponent(orderNumber)}&points=$pointsEarned');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final isINR = cart.currencyCode == 'INR';

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Delivery address section
          Text('Delivery Address', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          _address == null
              ? OutlinedButton.icon(
                  onPressed: _selectAddress,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add Delivery Address'),
                )
              : ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined,
                      color: AppColors.primary),
                  title: Text(
                    '${_address!.firstName} ${_address!.lastName}',
                    style: AppTextStyles.labelLarge,
                  ),
                  subtitle: Text(_address!.formatted,
                      style: AppTextStyles.bodySmall),
                  trailing: TextButton(
                    onPressed: _selectAddress,
                    child: const Text('Change'),
                  ),
                ),
          const SizedBox(height: 24),
          const Divider(),

          // Payment method
          const SizedBox(height: 16),
          Text('Payment Method', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          if (isINR) ...[
            _PaymentOption(
              value: _PaymentMethod.razorpay,
              group: _paymentMethod,
              label: 'Pay Online (UPI / Cards / Wallets)',
              subtitle: 'Secured by Razorpay',
              icon: Icons.payment,
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            _PaymentOption(
              value: _PaymentMethod.cod,
              group: _paymentMethod,
              label: 'Cash on Delivery',
              subtitle: 'Pay when you receive',
              icon: Icons.money,
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
          ] else ...[
            _PaymentOption(
              value: _PaymentMethod.stripe,
              group: _paymentMethod,
              label: 'Pay by Card',
              subtitle: 'Secured by Stripe',
              icon: Icons.credit_card,
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),

          // Order summary
          const SizedBox(height: 16),
          Text('Order Summary', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productTitle} × ${item.quantity}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatShopify(
                        item.lineTotalValue.toString(),
                        item.price.currencyCode),
                    style: AppTextStyles.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.headlineMedium),
              Text(
                CurrencyFormatter.formatShopify(
                    cart.total.toString(), cart.currencyCode),
                style: AppTextStyles.headlineMedium
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPlacingOrder ? null : _placeOrder,
              child: _isPlacingOrder
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Place Order'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final _PaymentMethod value;
  final _PaymentMethod group;
  final String label;
  final String subtitle;
  final IconData icon;
  final ValueChanged<_PaymentMethod?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.group,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == group;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColors.primary.withOpacity(0.04)
              : Colors.white,
        ),
        child: Row(
          children: [
            Radio<_PaymentMethod>(
              value: value,
              groupValue: group,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textHint),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.labelLarge),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
