import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'IN':
        return NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        ).format(amount);
      case 'AE':
        return NumberFormat.currency(
          locale: 'ar_AE',
          symbol: 'AED ',
          decimalDigits: 2,
        ).format(amount);
      case 'GB':
        return NumberFormat.currency(
          locale: 'en_GB',
          symbol: '£',
          decimalDigits: 2,
        ).format(amount);
      case 'US':
      default:
        return NumberFormat.currency(
          locale: 'en_US',
          symbol: '\$',
          decimalDigits: 2,
        ).format(amount);
    }
  }

  static String formatShopify(String amount, String currencyCode) {
    final value = double.tryParse(amount) ?? 0.0;
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        return NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        ).format(value);
      case 'AED':
        return NumberFormat.currency(
          locale: 'en_US',
          symbol: 'AED ',
          decimalDigits: 2,
        ).format(value);
      case 'GBP':
        return NumberFormat.currency(
          locale: 'en_GB',
          symbol: '£',
          decimalDigits: 2,
        ).format(value);
      case 'USD':
      default:
        return NumberFormat.currency(
          locale: 'en_US',
          symbol: '\$',
          decimalDigits: 2,
        ).format(value);
    }
  }

  /// Returns discount percentage as int (0 if no discount).
  static int discountPercent(double original, double sale) {
    if (original <= 0 || sale >= original) return 0;
    return ((1 - sale / original) * 100).round();
  }
}
