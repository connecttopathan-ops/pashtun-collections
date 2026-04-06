// StripeService stub — re-enable flutter_stripe in pubspec + add STRIPE_PUBLISHABLE_KEY to .env

class StripeService {
  StripeService._();

  static void init() {
    // No-op until flutter_stripe is re-enabled
  }

  static Future<void> presentPaymentSheet({
    required String clientSecret,
    required String customerEmail,
  }) async {
    throw UnimplementedError('Stripe not configured yet.');
  }
}
