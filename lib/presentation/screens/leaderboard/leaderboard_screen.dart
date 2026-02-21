import 'package:flutter/material.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/app_bar_parchment.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/coming_soon_widget.dart';

/// Sıralama ekranı — ileride yapılacak.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

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
              const AppBarParchment(title: 'Sıralama'),
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
