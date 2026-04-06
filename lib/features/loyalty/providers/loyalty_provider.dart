import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pointsKey = 'loyalty_points';

class LoyaltyReward {
  final String id;
  final String title;
  final int pointsCost;
  final String discountCode;

  const LoyaltyReward({
    required this.id,
    required this.title,
    required this.pointsCost,
    required this.discountCode,
  });
}

class LoyaltyState {
  final int points;
  final List<LoyaltyReward> availableRewards;
  final bool isLoading;

  const LoyaltyState({
    this.points = 0,
    this.availableRewards = const [],
    this.isLoading = false,
  });

  static const _nextRewardThreshold = 500;

  int get progressToNextReward =>
      _nextRewardThreshold > 0 ? (points % _nextRewardThreshold) : 0;

  int get pointsToNextReward =>
      _nextRewardThreshold - progressToNextReward;

  LoyaltyState copyWith({
    int? points,
    List<LoyaltyReward>? availableRewards,
    bool? isLoading,
  }) =>
      LoyaltyState(
        points: points ?? this.points,
        availableRewards: availableRewards ?? this.availableRewards,
        isLoading: isLoading ?? this.isLoading,
      );
}

class LoyaltyNotifier extends Notifier<LoyaltyState> {
  static const _rewardTiers = [
    LoyaltyReward(
      id: 'r1',
      title: '5% Off Your Next Order',
      pointsCost: 200,
      discountCode: 'LOYALTY5',
    ),
    LoyaltyReward(
      id: 'r2',
      title: '10% Off Your Next Order',
      pointsCost: 500,
      discountCode: 'LOYALTY10',
    ),
    LoyaltyReward(
      id: 'r3',
      title: 'Free Shipping',
      pointsCost: 300,
      discountCode: 'FREESHIP',
    ),
    LoyaltyReward(
      id: 'r4',
      title: '15% Off — Premium Reward',
      pointsCost: 1000,
      discountCode: 'LOYAL15',
    ),
  ];

  @override
  LoyaltyState build() {
    _loadPoints();
    return const LoyaltyState(availableRewards: _rewardTiers);
  }

  Future<void> _loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final pts = prefs.getInt(_pointsKey) ?? 0;
    state = state.copyWith(points: pts);
  }

  Future<void> fetchPoints() async {
    state = state.copyWith(isLoading: true);
    // In production, fetch from Shopify customer metafields or a loyalty backend
    await _loadPoints();
    state = state.copyWith(isLoading: false);
  }

  Future<void> awardPoints(int amount) async {
    final newPoints = state.points + amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, newPoints);
    state = state.copyWith(points: newPoints);
  }

  Future<void> redeemPoints(LoyaltyReward reward) async {
    if (state.points < reward.pointsCost) return;
    final newPoints = state.points - reward.pointsCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, newPoints);
    state = state.copyWith(points: newPoints);
    // In production, create a discount code via Shopify Admin API from your backend
  }
}

final loyaltyProvider =
    NotifierProvider<LoyaltyNotifier, LoyaltyState>(LoyaltyNotifier.new);
