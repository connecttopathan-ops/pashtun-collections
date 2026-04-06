// FCMService stub — re-enable firebase_messaging in pubspec + run flutterfire configure

import 'package:flutter/material.dart';
import '../../core/utils/notification_handler.dart';
import 'notification_screen.dart';

enum NotificationType {
  flashSale, restock, orderUpdate, abandonedCart, newArrival, priceDrop,
}

class FCMService {
  final GlobalKey<NavigatorState> navigatorKey;
  FCMService({required this.navigatorKey});

  Future<void> init() async {
    // No-op until firebase_messaging is re-enabled
  }

  Future<String?> getToken() async => null;
}
