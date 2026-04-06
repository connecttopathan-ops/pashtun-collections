import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app.dart';
import 'features/checkout/services/stripe_service.dart';
import 'features/wishlist/providers/wishlist_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await initWishlistBox();
  // NOTE: Requires google-services.json + GoogleService-Info.plist
  // from Firebase project 'pashtun-collections'. Run: flutterfire configure
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  StripeService.init();
  runApp(const ProviderScope(child: PashtunCollectionsApp()));
}
