import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum NotificationType { product, order, promotion, lookbook, general }

class NotificationHandler {
  NotificationHandler._();

  static void handleTap(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    switch (type) {
      case 'product':
        if (id != null) {
          context.push('/product/$id');
        }
        break;
      case 'order':
        if (id != null) {
          context.push('/order/$id');
        } else {
          context.push('/orders');
        }
        break;
      case 'promotion':
        final collectionHandle = data['collection'] as String?;
        if (collectionHandle != null) {
          context.push('/collection/$collectionHandle');
        } else {
          context.push('/shop');
        }
        break;
      case 'lookbook':
        context.push('/lookbook');
        break;
      case 'general':
      default:
        context.push('/notifications');
        break;
    }
  }
}
