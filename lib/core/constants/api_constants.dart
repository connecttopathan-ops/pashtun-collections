import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get storeUrl => dotenv.env['SHOPIFY_STORE_URL'] ?? '';
  static String get storefrontToken => dotenv.env['SHOPIFY_STOREFRONT_TOKEN'] ?? '';
  static String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get mixpanelToken => dotenv.env['MIXPANEL_TOKEN'] ?? '';

  static const String whatsappNumber = '+923001234567';

  static String get shopifyGraphqlEndpoint =>
      'https://$storeUrl/api/2024-01/graphql.json';

  static String get storefrontAccessTokenHeader =>
      'X-Shopify-Storefront-Access-Token';
}
