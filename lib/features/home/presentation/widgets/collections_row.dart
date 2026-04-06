import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../providers/home_provider.dart';

class CollectionsRow extends ConsumerWidget {
  const CollectionsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return collectionsAsync.when(
      loading: () => SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => const CollectionChipSkeleton(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (collections) => SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: collections.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final col = collections[index];
            return GestureDetector(
              onTap: () => context.push(
                '/collection/${col.handle}',
                extra: col.title,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3), width: 2),
                    ),
                    child: ClipOval(
                      child: col.image != null
                          ? CachedNetworkImage(
                              imageUrl: col.image!.url,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: AppColors.accent),
                              errorWidget: (_, __, ___) => Container(
                                  color: AppColors.accent,
                                  child: const Icon(Icons.image_outlined,
                                      color: AppColors.textHint)),
                            )
                          : Container(
                              color: AppColors.accent,
                              child: Center(
                                child: Text(
                                  col.title.substring(0, 1).toUpperCase(),
                                  style: AppTextStyles.headlineMedium.copyWith(
                                      color: AppColors.primary),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 72,
                    child: Text(
                      col.title,
                      style: AppTextStyles.labelSmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
