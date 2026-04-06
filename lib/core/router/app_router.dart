import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shell/main_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/shop/presentation/shop_screen.dart';
import '../../features/shop/presentation/collection_screen.dart';
import '../../features/product/presentation/product_detail_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/address_screen.dart';
import '../../features/checkout/presentation/order_confirmation_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/lookbook/presentation/lookbook_screen.dart';
import '../../features/notifications/notification_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final protectedRoutes = ['/orders', '/checkout', '/checkout/address'];
      final isProtected = protectedRoutes.any((r) => state.matchedLocation.startsWith(r));

      if (isProtected && !isLoggedIn) {
        return '/login?redirect=${state.matchedLocation}';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) => const NoTransitionPage(child: ShopScreen()),
          ),
          GoRoute(
            path: '/wishlist',
            pageBuilder: (context, state) => const NoTransitionPage(child: WishlistScreen()),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) => const NoTransitionPage(child: OrdersScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: _ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/product/:handle',
        builder: (context, state) => ProductDetailScreen(
          handle: state.pathParameters['handle']!,
        ),
      ),
      GoRoute(
        path: '/collection/:handle',
        builder: (context, state) => CollectionScreen(
          handle: state.pathParameters['handle']!,
          title: state.uri.queryParameters['title'] ?? 'Collection',
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
        routes: [
          GoRoute(
            path: 'address',
            builder: (context, state) => const AddressScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) => OrderConfirmationScreen(
          orderNumber: state.uri.queryParameters['orderNumber'] ?? '#0000',
          pointsEarned: int.tryParse(state.uri.queryParameters['points'] ?? '0') ?? 0,
        ),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) => OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/lookbook',
        builder: (context, state) => const LookbookScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          redirectPath: state.uri.queryParameters['redirect'],
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
  );
});

// Placeholder profile screen (in-app)
class _ProfileScreen extends ConsumerWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: auth.isLoggedIn
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Hello, ${auth.customerFirstName ?? 'Customer'}',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    child: const Text('Sign Out'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sign in to view your profile'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Create Account'),
                  ),
                ],
              ),
      ),
    );
  }
}
