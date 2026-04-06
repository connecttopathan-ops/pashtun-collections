// RazorpayService stub — re-enable razorpay_flutter in pubspec + add RAZORPAY_KEY to .env

class PaymentSuccessResponse {
  final String? orderId;
  final String? paymentId;
  const PaymentSuccessResponse({this.orderId, this.paymentId});
}

class PaymentFailureResponse {
  final String? message;
  const PaymentFailureResponse({this.message});
}

typedef PaymentSuccessCallback = void Function(PaymentSuccessResponse response);
typedef PaymentErrorCallback   = void Function(PaymentFailureResponse response);

class RazorpayService {
  PaymentSuccessCallback? onSuccess;
  PaymentErrorCallback?   onError;

  void openCheckout({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) {
    onError?.call(const PaymentFailureResponse(message: 'Razorpay not configured yet.'));
  }

  void dispose() {}
}
