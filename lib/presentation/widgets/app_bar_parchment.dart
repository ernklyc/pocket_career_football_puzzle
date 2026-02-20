import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';

/// Ortak AppBar — close butonu + başlık.
class AppBarParchment extends StatelessWidget {
  final String title;

  const AppBarParchment({
    super.key,
    required this.title,
  });

  void _onDismiss(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.go('/game/main');
    }
  }

  Widget _buildTitleChip() {
    return SizedBox(
      height: 44,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: AppTheme.titleFontFamily,
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(
                color: Colors.black54,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/buttons/appbar.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SizedBox(
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildTitleChip(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                  onPressed: () => _onDismiss(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
