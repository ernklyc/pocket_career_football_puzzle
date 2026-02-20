import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/boot/boot_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/paywall/paywall_coins_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/paywall/paywall_remove_ads_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/career/career_setup_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/main/main_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/profile/profile_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/play/play_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/pause/pause_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/results/score_summary_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/results/new_record_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/shop/shop_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/collection/collection_screen.dart';
import 'package:pocket_career_football_puzzle/presentation/screens/rewards/rewards_screen.dart';

/// GoRouter konfigürasyonu.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/boot',
    debugLogDiagnostics: true,
    routes: [
      // Boot / Splash
      GoRoute(
        path: '/boot',
        pageBuilder: (context, state) =>
            _buildPage(state, const BootScreen(), 'boot'),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _buildPage(state, const OnboardingScreen(), 'onboarding'),
      ),

      // Paywall - Coins
      GoRoute(
        path: '/paywall/coins',
        pageBuilder: (context, state) =>
            _buildPage(state, const PaywallCoinsScreen(), 'paywall_coins'),
      ),

      // Paywall - Remove Ads
      GoRoute(
        path: '/paywall/remove-ads',
        pageBuilder: (context, state) => _buildPage(
          state,
          const PaywallRemoveAdsScreen(),
          'paywall_remove_ads',
        ),
      ),

      // Career Setup (kısa form — ilk açılışta)
      GoRoute(
        path: '/career/setup',
        pageBuilder: (context, state) =>
            _buildPage(state, const CareerSetupScreen(), 'career_setup'),
      ),

      // Ana Ekran
      GoRoute(
        path: '/game/main',
        pageBuilder: (context, state) => _buildPage(
          state,
          const MainScreen(),
          'main',
          transition: _TransitionType.fade,
        ),
      ),

      // Profil (overlay)
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildPage(state, const ProfileScreen(), 'profile'),
      ),

      // Sıralama
      GoRoute(
        path: '/leaderboard',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildPage(state, const LeaderboardScreen(), 'leaderboard'),
      ),

      // Play
      GoRoute(
        path: '/play',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _buildPage(
            state,
            PlayScreen(
              season: extra['season'] as int? ?? 1,
              level: extra['level'] as int? ?? 1,
              isReplay: extra['isReplay'] as bool? ?? false,
            ),
            'play',
            transition: _TransitionType.scale,
          );
        },
      ),

      // Pause
      GoRoute(
        path: '/pause',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildPage(
          state,
          const PauseScreen(),
          'pause',
          transition: _TransitionType.fade,
        ),
      ),

      // Results - Score Summary
      GoRoute(
        path: '/results/score',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildPage(
          state,
          const ScoreSummaryScreen(),
          'results_score',
          transition: _TransitionType.slideUp,
        ),
      ),

      // Results - New Record
      GoRoute(
        path: '/results/new-record',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildPage(
          state,
          const NewRecordScreen(),
          'results_new_record',
          transition: _TransitionType.scale,
        ),
      ),

      // Shop
      GoRoute(
        path: '/shop',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildPage(state, const ShopScreen(), 'shop'),
      ),

      // Collection
      GoRoute(
        path: '/collection',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildPage(state, const CollectionScreen(), 'collection'),
      ),

      // Rewards (Ödüller)
      GoRoute(
        path: '/rewards',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildPage(state, const RewardsScreen(), 'rewards'),
      ),

      // Achievements — Koleksiyon ekranına yönlendir (aynı içerik)
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildPage(state, const CollectionScreen(), 'achievements'),
      ),
    ],
  );

  static Page<dynamic> _buildPage(
    GoRouterState state,
    Widget child,
    String name, {
    _TransitionType transition = _TransitionType.slide,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: name,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transition) {
          case _TransitionType.fade:
            return FadeTransition(opacity: animation, child: child);

          case _TransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );

          case _TransitionType.slideUp:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );

          case _TransitionType.slide:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            );
        }
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

enum _TransitionType { fade, scale, slideUp, slide }
