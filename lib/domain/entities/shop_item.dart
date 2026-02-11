import 'package:equatable/equatable.dart';
import 'package:pocket_career_football_puzzle/core/config/economy_config.dart';

/// Mağaza öğesi entity'si.
class ShopItem extends Equatable {
  final String id;
  final ShopItemType type;
  final int coinPrice;
  final String nameKey;
  final String descriptionKey;
  final bool isOwned;
  final int quantity; // power-up'lar için

  const ShopItem({
    required this.id,
    required this.type,
    required this.coinPrice,
    required this.nameKey,
    required this.descriptionKey,
    this.isOwned = false,
    this.quantity = 0,
  });

  ShopItem copyWith({
    bool? isOwned,
    int? quantity,
  }) {
    return ShopItem(
      id: id,
      type: type,
      coinPrice: coinPrice,
      nameKey: nameKey,
      descriptionKey: descriptionKey,
      isOwned: isOwned ?? this.isOwned,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'coinPrice': coinPrice,
        'nameKey': nameKey,
        'descriptionKey': descriptionKey,
        'isOwned': isOwned,
        'quantity': quantity,
      };

  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
        id: json['id'] as String,
        type: ShopItemType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ShopItemType.cosmetic,
        ),
        coinPrice: json['coinPrice'] as int,
        nameKey: json['nameKey'] as String,
        descriptionKey: json['descriptionKey'] as String,
        isOwned: json['isOwned'] as bool? ?? false,
        quantity: json['quantity'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id];
}
