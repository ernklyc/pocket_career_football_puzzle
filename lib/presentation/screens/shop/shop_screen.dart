import 'package:flutter/material.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/app_bar_parchment.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/coming_soon_widget.dart';

/// Mağaza ekranı — ileride yapılacak.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/league/1.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const AppBarParchment(title: 'Mağaza'),
              const Expanded(
                child: ComingSoonWidget(fullPage: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
