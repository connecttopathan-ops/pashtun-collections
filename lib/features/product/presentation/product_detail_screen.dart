import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/analytics.dart';
import '../../../shared/widgets/whatsapp_button.dart';
import '../../cart/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/product_provider.dart';
import 'widgets/product_gallery.dart';
import 'widgets/size_selector.dart';
import 'widgets/color_swatch.dart';
import 'widgets/price_tag.dart';
import 'widgets/complete_the_look.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String handle;
  const ProductDetailScreen({super.key, required this.handle});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Analytics.productViewed(
        productId: widget.handle,
        title: widget.handle,
        price: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.handle));

    return productAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Product not found')),
          );
        }

        final selectedVariant =
            ref.watch(selectedVariantProvider(widget.handle));
        final selectedOptions =
            ref.watch(selectedOptionsProvider(widget.handle));
        final isWishlisted =
            ref.watch(wishlistProvider).contains(product.id);

        final displayVariant = selectedVariant ?? product.variants.firstOrNull;
        final price = displayVariant?.price ?? product.minPrice;
        final compareAtPrice =
            displayVariant?.compareAtPrice ?? product.compareAtMinPrice;

        // Unavailable sizes
        final unavailableSizes = <String>{};
        for (final opt in product.options) {
          if (opt.name.toLowerCase() == 'size') {
            for (final val in opt.values) {
              final hasAvailable = product.variants.any((v) =>
                  v.selectedOptions
                      .any((o) => o.name == opt.name && o.value == val) &&
                  v.availableForSale);
              if (!hasAvailable) unavailableSizes.add(val);
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(product.title, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? AppColors.saleRed : null,
                ),
                onPressed: () => ref
                    .read(wishlistProvider.notifier)
                    .toggle(product.id),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Analytics.shareTapped(
                      productId: product.id, platform: 'share');
                  Share.share(
                      'Check out ${product.title} on Pashtun Collections!\nhttps://pashtuncollections.myshopify.com/products/${product.handle}');
                },
              ),
            ],
          ),
          floatingActionButton: WhatsappButton(
            message:
                'Hi! I\'m interested in: ${product.title}\nhttps://pashtuncollections.myshopify.com/products/${product.handle}',
          ),
          body: CustomScrollView(
            slivers: [
              // Gallery
              SliverToBoxAdapter(
                child: ProductGallery(images: product.images),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vendor/collection label
                      if (product.vendor != null)
                        Text(
                          product.vendor!.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary, letterSpacing: 1.5),
                        ),
                      const SizedBox(height: 4),
                      // Title
                      Text(product.title, style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 12),
                      // Price
                      if (price != null)
                        PriceTag(
                          price: price,
                          compareAtPrice: compareAtPrice,
                          large: true,
                        ),
                      const SizedBox(height: 20),

                      // Color selector
                      if (product.colorOptions.isNotEmpty) ...[
                        Row(
                          children: [
                            Text('Colour: ',
                                style: AppTextStyles.labelLarge),
                            if (selectedOptions['Color'] != null ||
                                selectedOptions['Colour'] != null)
                              Text(
                                selectedOptions['Color'] ??
                                    selectedOptions['Colour'] ??
                                    '',
                                style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ColorSwatchSelector(
                          colors: product.colorOptions,
                          selected: selectedOptions['Color'] ??
                              selectedOptions['Colour'],
                          onSelected: (color) {
                            final optionName =
                                product.options.any((o) => o.name == 'Color')
                                    ? 'Color'
                                    : 'Colour';
                            final newOptions = {
                              ...selectedOptions,
                              optionName: color
                            };
                            ref
                                .read(selectedOptionsProvider(widget.handle)
                                    .notifier)
                                .state = newOptions;
                            _updateVariant(ref, product, newOptions);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Size selector
                      if (product.sizeOptions.isNotEmpty) ...[
                        Row(
                          children: [
                            Text('Size: ', style: AppTextStyles.labelLarge),
                            if (selectedOptions['Size'] != null)
                              Text(
                                selectedOptions['Size']!,
                                style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizeSelector(
                          sizes: product.sizeOptions,
                          selected: selectedOptions['Size'],
                          unavailableSizes: unavailableSizes,
                          onSelected: (size) {
                            final newOptions = {
                              ...selectedOptions,
                              'Size': size
                            };
                            ref
                                .read(selectedOptionsProvider(widget.handle)
                                    .notifier)
                                .state = newOptions;
                            _updateVariant(ref, product, newOptions);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Description with expand/collapse
                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        Text('Description',
                            style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        AnimatedCrossFade(
                          firstChild: Text(
                            product.description!,
                            style: AppTextStyles.bodyMedium,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(
                            product.description!,
                            style: AppTextStyles.bodyMedium,
                          ),
                          crossFadeState: _descriptionExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                        TextButton(
                          onPressed: () => setState(() =>
                              _descriptionExpanded = !_descriptionExpanded),
                          child: Text(
                            _descriptionExpanded ? 'Show Less' : 'Read More',
                          ),
                        ),
                      ],

                      // Fabric / care details from metafields
                      if (product.metafields['custom.fabric_details'] !=
                              null &&
                          product
                              .metafields['custom.fabric_details']!
                              .isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        Text('Fabric Details',
                            style: AppTextStyles.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          product.metafields['custom.fabric_details']!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Complete the Look
              SliverToBoxAdapter(
                child: CompleteTheLook(
                  productHandle: widget.handle,
                  collectionHandle: product.productType?.toLowerCase() ??
                      'all',
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Sticky add-to-cart bar
          bottomNavigationBar: _AddToCartBar(
            handle: widget.handle,
            product: product,
            selectedVariant: displayVariant,
            selectedOptions: selectedOptions,
          ),
        );
      },
    );
  }

  void _updateVariant(WidgetRef ref, product, Map<String, String> options) {
    // Find matching variant
    final matchedVariant = product.variants.firstWhere(
      (v) => options.entries.every((entry) => v.selectedOptions
          .any((o) => o.name == entry.key && o.value == entry.value)),
      orElse: () => product.variants.first,
    );
    ref.read(selectedVariantProvider(widget.handle).notifier).state =
        matchedVariant;
  }
}

class _AddToCartBar extends ConsumerWidget {
  final String handle;
  final dynamic product;
  final dynamic selectedVariant;
  final Map<String, String> selectedOptions;

  const _AddToCartBar({
    required this.handle,
    required this.product,
    required this.selectedVariant,
    required this.selectedOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final isLoading = cartState.isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
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
      child: Row(
        children: [
          // Cart icon button
          OutlinedButton(
            onPressed: () => context.push('/cart'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(14),
              minimumSize: Size.zero,
            ),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 12),
          // Add to cart button
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (selectedVariant == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please select size and colour')),
                        );
                        return;
                      }
                      await ref.read(cartProvider.notifier).addItem(
                        variantId: selectedVariant.id,
                        quantity: 1,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Added to cart!')),
                        );
                      }
                      Analytics.addToCart(
                        productId: product.id,
                        variantId: selectedVariant.id,
                        price: selectedVariant.price.value,
                        quantity: 1,
                      );
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }
}
