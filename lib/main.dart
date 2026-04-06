import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'features/wishlist/providers/wishlist_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await initWishlistBox();

  // Firebase — uncomment after adding google-services.json + GoogleService-Info.plist
  // and running: flutterfire configure
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Stripe — uncomment after adding STRIPE_PUBLISHABLE_KEY to .env
  // StripeService.init();

  runApp(const ProviderScope(child: PashtunCollectionsApp()));
}
