import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/analytics.dart';

class LookbookPiece {
  final String productHandle;
  final String label;
  final double topPercent;
  final double leftPercent;

  const LookbookPiece({
    required this.productHandle,
    required this.label,
    required this.topPercent,
    required this.leftPercent,
  });
}

class LookbookEntry {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<LookbookPiece> pieces;

  const LookbookEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.pieces,
  });
}

// In production, fetch from Shopify metaobjects or CMS
final lookbookProvider = Provider<List<LookbookEntry>>((ref) {
  return const [
    LookbookEntry(
      id: 'look-1',
      title: 'The Bridal Edit',
      subtitle: 'Timeless elegance for the modern bride',
      imageUrl:
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800',
      pieces: [
        LookbookPiece(
          productHandle: 'bridal-lehenga-red',
          label: 'Bridal Lehenga',
          topPercent: 0.3,
          leftPercent: 0.4,
        ),
        LookbookPiece(
          productHandle: 'dupatta-gold',
          label: 'Gold Dupatta',
          topPercent: 0.15,
          leftPercent: 0.6,
        ),
      ],
    ),
    LookbookEntry(
      id: 'look-2',
      title: 'Festive Glow',
      subtitle: 'Celebrate the season in luxury zari',
      imageUrl:
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800',
      pieces: [
        LookbookPiece(
          productHandle: 'anarkali-festive',
          label: 'Festive Anarkali',
          topPercent: 0.35,
          leftPercent: 0.5,
        ),
      ],
    ),
    LookbookEntry(
      id: 'look-3',
      title: 'Casual Chic',
      subtitle: 'Effortless Pakistani style for every day',
      imageUrl:
          'https://images.unsplash.com/photo-1594938298603-d8b0fae75e6c?w=800',
      pieces: [
        LookbookPiece(
          productHandle: 'casual-kurta-blue',
          label: 'Cotton Kurta',
          topPercent: 0.4,
          leftPercent: 0.3,
        ),
      ],
    ),
  ];
});

class LookbookScreen extends ConsumerStatefulWidget {
  const LookbookScreen({super.key});

  @override
  ConsumerState<LookbookScreen> createState() => _LookbookScreenState();
}

class _LookbookScreenState extends ConsumerState<LookbookScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _showPieces = false;

  @override
  void initState() {
    super.initState();
    Analytics.lookbookViewed('Lookbook');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(lookbookProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          'LOOKBOOK',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              final entry = entries[_currentIndex];
              Analytics.shareTapped(
                  productId: entry.id, platform: 'share');
              Share.share(
                'Check out the ${entry.title} lookbook by Pashtun Collections!');
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: entries.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _showPieces = false;
          });
          Analytics.lookbookViewed(entries[index].title);
        },
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _LookbookPage(
            entry: entry,
            showPieces: _currentIndex == index && _showPieces,
            onTogglePieces: () =>
                setState(() => _showPieces = !_showPieces),
          );
        },
      ),
    );
  }
}

class _LookbookPage extends StatelessWidget {
  final LookbookEntry entry;
  final bool showPieces;
  final VoidCallback onTogglePieces;

  const _LookbookPage({
    required this.entry,
    required this.showPieces,
    required this.onTogglePieces,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.network(
          entry.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.accent),
        ),

        // Gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
              stops: [0.5, 1.0],
            ),
          ),
        ),

        // Hotspot dots
        if (showPieces)
          LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: entry.pieces.map((piece) {
                return Positioned(
                  top: constraints.maxHeight * piece.topPercent,
                  left: constraints.maxWidth * piece.leftPercent,
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/product/${piece.productHandle}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_circle_outline,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(piece.label,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

        // Bottom info + draggable sheet trigger
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: AppTextStyles.displayMedium
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.subtitle,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onTogglePieces,
                      icon: Icon(showPieces
                          ? Icons.visibility_off_outlined
                          : Icons.add_circle_outline),
                      label: Text(
                          showPieces ? 'Hide Items' : 'Shop This Look'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
