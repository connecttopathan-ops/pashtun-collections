import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/models/cart_item.dart';
import '../data/cart_repository.dart';

const _storage = FlutterSecureStorage();
const _cartIdKey = 'shopify_cart_id';

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    _initCart();
    return const CartState.empty();
  }

  Future<void> _initCart() async {
    final cartId = await _storage.read(key: _cartIdKey);
    if (cartId == null) return;
    try {
      final cartState = await CartRepository.instance.fetchCart(cartId: cartId);
      state = cartState;
    } catch (_) {
      // Cart may have expired; clear stored id
      await _storage.delete(key: _cartIdKey);
    }
  }

  Future<void> addItem({
    required String variantId,
    required int quantity,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      CartState newState;
      if (state.cartId == null) {
        newState = await CartRepository.instance.createCart(
          variantId: variantId,
          quantity: quantity,
        );
        await _storage.write(key: _cartIdKey, value: newState.cartId);
      } else {
        newState = await CartRepository.instance.addLines(
          cartId: state.cartId!,
          variantId: variantId,
          quantity: quantity,
        );
      }
      state = newState.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeItem(String lineId) async {
    if (state.cartId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final newState = await CartRepository.instance.removeLine(
        cartId: state.cartId!,
        lineId: lineId,
      );
      state = newState.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateQuantity(String lineId, int quantity) async {
    if (state.cartId == null) return;
    if (quantity <= 0) {
      await removeItem(lineId);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final newState = await CartRepository.instance.updateLine(
        cartId: state.cartId!,
        lineId: lineId,
        quantity: quantity,
      );
      state = newState.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> applyCoupon(String code) async {
    if (state.cartId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final newState = await CartRepository.instance.applyCoupon(
        cartId: state.cartId!,
        code: code,
      );
      state = newState.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clearCart() async {
    await _storage.delete(key: _cartIdKey);
    state = const CartState.empty();
  }

  Future<void> refreshCart() async {
    if (state.cartId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final newState = await CartRepository.instance.fetchCart(cartId: state.cartId!);
      state = newState.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
