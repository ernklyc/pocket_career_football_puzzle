import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/app_bar_parchment.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/under_maintenance_widget.dart';

/// Ödüller ekranı — bakımda.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const AppBarParchment(title: 'Ödüller'),
              Expanded(
                child: const UnderMaintenanceWidget(fullPage: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
