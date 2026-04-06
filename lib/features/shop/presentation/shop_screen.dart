import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../home/providers/home_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
      ),
      body: collectionsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ProductGridSkeleton(itemCount: 6),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.saleRed),
              const SizedBox(height: 12),
              Text('Failed to load collections',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(collectionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (collections) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final col = collections[index];
            return GestureDetector(
              onTap: () => context.push(
                '/collection/${col.handle}?title=${Uri.encodeComponent(col.title)}',
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    if (col.image != null)
                      CachedNetworkImage(
                        imageUrl: col.image!.url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.accent),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.accent),
                      )
                    else
                      Container(
                        color: AppColors.accent,
                        child: Center(
                          child: Text(
                            col.title.substring(0, 1),
                            style: AppTextStyles.displayLarge
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                    // Gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                          stops: [0.5, 1.0],
                        ),
                      ),
                    ),
                    // Title
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Text(
                        col.title,
                        style: AppTextStyles.titleLarge
                            .copyWith(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
