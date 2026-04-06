import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _boxName = 'pashtun_wishlist';
const _wishlistKey = 'wishlist_ids';

Future<void> initWishlistBox() async {
  if (!Hive.isBoxOpen(_boxName)) {
    await Hive.openBox(_boxName);
  }
}

class WishlistNotifier extends Notifier<Set<String>> {
  Box<dynamic> get _box => Hive.box(_boxName);

  @override
  Set<String> build() {
    final stored = _box.get(_wishlistKey);
    if (stored is List) {
      return Set<String>.from(stored.cast<String>());
    }
    return {};
  }

  void toggle(String productId) {
    final current = Set<String>.from(state);
    if (current.contains(productId)) {
      current.remove(productId);
    } else {
      current.add(productId);
    }
    _persist(current);
    state = current;
  }

  bool isWishlisted(String productId) => state.contains(productId);

  void _persist(Set<String> ids) {
    _box.put(_wishlistKey, ids.toList());
  }

  void clear() {
    _box.delete(_wishlistKey);
    state = {};
  }
}

final wishlistProvider =
    NotifierProvider<WishlistNotifier, Set<String>>(WishlistNotifier.new);
