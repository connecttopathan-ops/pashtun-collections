import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../shared/widgets/app_badge.dart';
import 'widgets/hero_banner.dart';
import 'widgets/flash_sale_banner.dart';
import 'widgets/collections_row.dart';
import 'widgets/new_arrivals_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).totalQuantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PASHTUN COLLECTIONS',
          style: AppTextStyles.titleLarge.copyWith(
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/shop'),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: CartCountBadge(count: cartCount),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(cartProvider);
        },
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HeroBannerCarousel()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverToBoxAdapter(child: FlashSaleBanner()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Collections section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Shop by Collection',
                        style: AppTextStyles.headlineMedium),
                    TextButton(
                      onPressed: () => context.go('/shop'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: CollectionsRow()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // New Arrivals section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Arrivals', style: AppTextStyles.headlineMedium),
                    TextButton(
                      onPressed: () => context.push(
                          '/collection/new-arrivals?title=New+Arrivals'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: const SliverToBoxAdapter(child: NewArrivalsGrid()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Lookbook teaser
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => context.push('/lookbook'),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A1A), Color(0xFFC8860A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('THE LOOKBOOK',
                            style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary, letterSpacing: 3)),
                        const SizedBox(height: 8),
                        Text(
                          'Style inspiration for\nevery occasion',
                          style: AppTextStyles.headlineLarge
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Explore Now',
                              style: AppTextStyles.labelLarge
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
