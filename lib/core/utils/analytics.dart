import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  Analytics._();

  static final _fa = FirebaseAnalytics.instance;

  static Future<void> track(String eventName, {Map<String, Object>? params}) async {
    await _fa.logEvent(name: eventName, parameters: params);
  }

  static Future<void> productViewed({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    String? category,
  }) async {
    await _fa.logViewItem(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          itemCategory: category,
          price: price,
        ),
      ],
    );
  }

  static Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    required int quantity,
    String? variantId,
    String? variantName,
  }) async {
    await _fa.logAddToCart(
      currency: currency,
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          itemVariant: variantName,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  static Future<void> checkoutStarted({
    required double total,
    required String currency,
    required int itemCount,
  }) async {
    await _fa.logBeginCheckout(
      currency: currency,
      value: total,
    );
    await track('checkout_started', params: {
      'total': total,
      'currency': currency,
      'item_count': itemCount,
    });
  }

  static Future<void> orderCompleted({
    required String orderId,
    required double total,
    required String currency,
    required int itemCount,
  }) async {
    await _fa.logPurchase(
      transactionId: orderId,
      currency: currency,
      value: total,
    );
    await track('order_completed', params: {
      'order_id': orderId,
      'total': total,
      'currency': currency,
      'item_count': itemCount,
    });
  }

  static Future<void> notificationTapped({
    required String notificationType,
    String? notificationId,
  }) async {
    await track('notification_tapped', params: {
      'notification_type': notificationType,
      if (notificationId != null) 'notification_id': notificationId,
    });
  }

  static Future<void> lookbookViewed({String? entryTitle}) async {
    await track('lookbook_viewed', params: {
      if (entryTitle != null) 'entry_title': entryTitle,
    });
  }

  static Future<void> shareTapped({
    required String contentType,
    required String contentId,
  }) async {
    await _fa.logShare(
      contentType: contentType,
      itemId: contentId,
      method: 'system_share',
    );
  }
}
