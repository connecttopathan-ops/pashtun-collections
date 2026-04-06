import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/api_constants.dart';

class RazorpayService {
  late final Razorpay _razorpay;
  final void Function(PaymentSuccessResponse) onSuccess;
  final void Function(PaymentFailureResponse) onFailure;
  final void Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService({
    required this.onSuccess,
    required this.onFailure,
    this.onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    if (onExternalWallet != null) {
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet!);
    }
  }

  void openCheckout({
    required double amount, // in INR
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String description = 'Pashtun Collections Order',
  }) {
    final options = {
      'key': ApiConstants.razorpayKey,
      'amount': (amount * 100).toInt(), // paise
      'name': 'Pashtun Collections',
      'description': description,
      'order_id': orderId,
      'prefill': {
        'name': customerName,
        'email': customerEmail,
        'contact': customerPhone,
      },
      'theme': {
        'color': '#C8860A',
      },
    };
    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
