import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/constants/api_constants.dart';

class StripeService {
  StripeService._();

  static void init() {
    Stripe.publishableKey = ApiConstants.stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.com.pashtuncollections.app';
    Stripe.instance.applySettings();
  }

  /// Call this after receiving a PaymentIntent clientSecret from your backend.
  static Future<void> presentPaymentSheet({
    required String clientSecret,
    String? customerName,
    String? customerEmail,
    String currency = 'usd',
    int amountInCents = 0,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Pashtun Collections',
        customerId: null,
        style: ThemeMode.light,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFFC8860A),
          ),
        ),
        billingDetails: customerEmail != null || customerName != null
            ? BillingDetails(
                name: customerName,
                email: customerEmail,
              )
            : null,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }
}
