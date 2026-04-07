import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  // Hardcoded fallbacks so the app works even if .env is missing/stale
  static const _defaultStoreUrl = '656481.myshopify.com';
  static const _defaultStorefrontToken = '505ce803a316491515ed948ab62392b6';

  static String get storeUrl =>
      dotenv.env['SHOPIFY_STORE_URL'] ?? _defaultStoreUrl;
  static String get storefrontToken =>
      dotenv.env['SHOPIFY_STOREFRONT_TOKEN'] ?? _defaultStorefrontToken;
  static String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get mixpanelToken => dotenv.env['MIXPANEL_TOKEN'] ?? '';

  static const String whatsappNumber = '+919876543210';

  static String get shopifyGraphqlEndpoint =>
      'https://$storeUrl/api/2024-01/graphql.json';

  static const String storefrontAccessTokenHeader =
      'X-Shopify-Storefront-Access-Token';
}
