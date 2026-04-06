import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/notification_handler.dart';

const _notifBoxName = 'pashtun_notifications';
const _notifKey = 'notifications_list';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? dataId;
  final DateTime receivedAt;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.dataId,
    required this.receivedAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'dataId': dataId,
        'receivedAt': receivedAt.toIso8601String(),
        'isRead': isRead,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: json['type'] as String? ?? 'general',
        dataId: json['dataId'] as String?,
        receivedAt:
            DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
                DateTime.now(),
        isRead: json['isRead'] as bool? ?? false,
      );
}

Future<void> storeNotification(NotificationItem item) async {
  if (!Hive.isBoxOpen(_notifBoxName)) {
    await Hive.openBox(_notifBoxName);
  }
  final box = Hive.box(_notifBoxName);
  final raw = box.get(_notifKey);
  final List<Map<String, dynamic>> existing = raw != null
      ? (raw as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList()
      : [];
  existing.insert(0, item.toJson());
  // Keep at most 50 notifications
  if (existing.length > 50) existing.removeLast();
  await box.put(_notifKey, existing);
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _items = [];
  bool _loading = true;
  late Box _box;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!Hive.isBoxOpen(_notifBoxName)) {
      await Hive.openBox(_notifBoxName);
    }
    _box = Hive.box(_notifBoxName);
    _refresh();
  }

  void _refresh() {
    final raw = _box.get(_notifKey);
    final items = raw != null
        ? (raw as List<dynamic>)
            .map((e) => NotificationItem.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList()
        : <NotificationItem>[];
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _markRead(int index) async {
    _items[index].isRead = true;
    final jsonList = _items.map((i) => i.toJson()).toList();
    await _box.put(_notifKey, jsonList);
    setState(() {});
  }

  Future<void> _clearAll() async {
    await _box.delete(_notifKey);
    setState(() => _items = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_none_outlined,
                          size: 64, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text('No notifications yet',
                          style: AppTextStyles.bodyLarge),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _NotificationTile(
                      item: item,
                      onTap: () {
                        _markRead(index);
                        NotificationHandler.handleTap(
                          context,
                          {'type': item.type, 'id': item.dataId},
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  IconData get _icon {
    switch (item.type) {
      case 'product':
        return Icons.shopping_bag_outlined;
      case 'order':
        return Icons.receipt_long_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'lookbook':
        return Icons.auto_stories_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('dd MMM, hh:mm a').format(item.receivedAt);
    return ListTile(
      onTap: onTap,
      tileColor: item.isRead ? null : AppColors.primary.withOpacity(0.04),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        item.title,
        style: AppTextStyles.labelLarge.copyWith(
          fontWeight:
              item.isRead ? FontWeight.w500 : FontWeight.w700,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.body, style: AppTextStyles.bodySmall, maxLines: 2),
          const SizedBox(height: 2),
          Text(timeStr,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textHint)),
        ],
      ),
      trailing: item.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
      isThreeLine: true,
    );
  }
}
