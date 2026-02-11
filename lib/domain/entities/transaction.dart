import 'package:equatable/equatable.dart';

/// İşlem kaynağı.
enum TransactionSource {
  gameplay,
  rewardedAd,
  iapRevenuecat,
  shopPurchase,
  admin,
}

/// Coin işlem kaydı.
class CoinTransaction extends Equatable {
  final String id;
  final DateTime timestamp;
  final int delta;
  final String reason;
  final TransactionSource source;
  final int balanceAfter;

  const CoinTransaction({
    required this.id,
    required this.timestamp,
    required this.delta,
    required this.reason,
    required this.source,
    required this.balanceAfter,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'delta': delta,
        'reason': reason,
        'source': source.name,
        'balanceAfter': balanceAfter,
      };

  factory CoinTransaction.fromJson(Map<String, dynamic> json) =>
      CoinTransaction(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        delta: json['delta'] as int,
        reason: json['reason'] as String,
        source: TransactionSource.values.firstWhere(
          (e) => e.name == json['source'],
          orElse: () => TransactionSource.admin,
        ),
        balanceAfter: json['balanceAfter'] as int,
      );

  @override
  List<Object?> get props => [id];
}
