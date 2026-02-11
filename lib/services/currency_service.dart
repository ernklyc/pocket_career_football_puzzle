import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';
import 'package:pocket_career_football_puzzle/domain/entities/transaction.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';
import 'package:pocket_career_football_puzzle/core/utils/guards.dart';

/// Coin ekonomisi servisi. Tek kaynak (Single Source of Truth).
class CurrencyService {
  final LocalStorage _storage;
  static const _uuid = Uuid();

  CurrencyService(this._storage);

  int get balance => _storage.coinBalance;

  bool canAfford(int amount) => balance >= amount;

  /// Coin ekle.
  Future<int> addCoins({
    required int amount,
    required String reason,
    required TransactionSource source,
  }) async {
    if (amount <= 0) return balance;

    final newBalance = Guards.clampCoinBalance(balance + amount);
    await _storage.setCoinBalance(newBalance);

    final tx = CoinTransaction(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      delta: amount,
      reason: reason,
      source: source,
      balanceAfter: newBalance,
    );
    await _storage.addTransaction(jsonEncode(tx.toJson()));

    AppLogger.economy('ADD ($reason)', amount, newBalance);
    return newBalance;
  }

  /// Coin harca.
  Future<bool> spendCoins({
    required int amount,
    required String reason,
    required TransactionSource source,
  }) async {
    if (amount <= 0) return false;
    if (!canAfford(amount)) {
      AppLogger.warning('Yetersiz coin: $balance < $amount ($reason)');
      return false;
    }

    final newBalance = Guards.clampCoinBalance(balance - amount);
    await _storage.setCoinBalance(newBalance);

    final tx = CoinTransaction(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      delta: -amount,
      reason: reason,
      source: source,
      balanceAfter: newBalance,
    );
    await _storage.addTransaction(jsonEncode(tx.toJson()));

    AppLogger.economy('SPEND ($reason)', amount, newBalance);
    return true;
  }

  /// İşlem geçmişi.
  List<CoinTransaction> getTransactionHistory() {
    return _storage.transactionLog
        .map((json) => CoinTransaction.fromJson(jsonDecode(json)))
        .toList()
        .reversed
        .toList();
  }
}
