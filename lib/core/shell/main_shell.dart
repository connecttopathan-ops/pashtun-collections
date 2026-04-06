import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../shared/widgets/app_badge.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', path: '/'),
    _TabItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'Shop', path: '/shop'),
    _TabItem(icon: Icons.favorite_outline, activeIcon: Icons.favorite, label: 'Wishlist', path: '/wishlist'),
    _TabItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Orders', path: '/orders'),
    _TabItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].path) &&
          (i == 0 ? location == '/' : true)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartCount = cartState.totalQuantity;
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            final path = _tabs[index].path;
            if (context.canPop()) {
              context.go(path);
            } else {
              context.go(path);
            }
          },
          items: _tabs.asMap().entries.map((entry) {
            final i = entry.key;
            final tab = entry.value;
            final isActive = i == currentIndex;

            Widget iconWidget = Icon(isActive ? tab.activeIcon : tab.icon);

            // Cart badge on Shop tab (index 1)
            if (i == 1 && cartCount > 0) {
              iconWidget = Stack(
                clipBehavior: Clip.none,
                children: [
                  iconWidget,
                  Positioned(
                    top: -4,
                    right: -6,
                    child: CartCountBadge(count: cartCount),
                  ),
                ],
              );
            }

            return BottomNavigationBarItem(
              icon: iconWidget,
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
