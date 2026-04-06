import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderNumber;
  final int pointsEarned;

  const OrderConfirmationScreen({
    super.key,
    required this.orderNumber,
    this.pointsEarned = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie checkmark animation
              Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                width: 180,
                height: 180,
                repeat: false,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: 16),

              Text('Order Confirmed!', style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Thank you for your purchase',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Order $orderNumber',
                  style: AppTextStyles.labelLarge,
                ),
              ),
              const SizedBox(height: 24),

              // Points earned banner
              if (pointsEarned > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC8860A), Color(0xFFE8A020)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You earned $pointsEarned loyalty points!',
                              style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Redeem on your next order',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/orders'),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Track Order'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
