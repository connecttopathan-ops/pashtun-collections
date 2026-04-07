import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  // Store credentials — hardcoded so local .env cannot override with stale values
  static const String storeUrl = '656481.myshopify.com';
  static const String storefrontToken = '505ce803a316491515ed948ab62392b6';

  // Payment keys — still read from .env (added when keys are available)
  static String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get mixpanelToken => dotenv.env['MIXPANEL_TOKEN'] ?? '';

  static const String whatsappNumber = '+919876543210';

  static const String shopifyGraphqlEndpoint =
      'https://$storeUrl/api/2024-01/graphql.json';

  static const String storefrontAccessTokenHeader =
      'X-Shopify-Storefront-Access-Token';
}
