import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/domain/entities/block_collection.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';

/// Blok koleksiyonu ekranı — açılan blok şekillerini gösterir.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final currentLevel = progress.currentLevel;
    final unlockedShapes = BlockCollection.unlockedAt(currentLevel);
    final nextUnlock = BlockCollection.nextUnlock(currentLevel);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/buttons/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              // Üst bar — appbar.png
              Container(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              context.go('/game/main');
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Blok Koleksiyonu',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // İlerleme bilgisi
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/buttons/paper.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.collections_bookmark,
                              color: AppColors.accent,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${unlockedShapes.length} / ${BlockCollection.allShapes.length} Blok Açıldı',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: AppColors.parchmentText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Mevcut level: $currentLevel',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: AppColors.parchmentTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sonraki açılacak blok
                      if (nextUnlock != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/buttons/paper.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_clock,
                                color: AppColors.gold,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Level ${nextUnlock.level}\'de ${nextUnlock.shapes.length} yeni blok açılacak!',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: AppColors.gold,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Blok kartları grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: BlockCollection.allShapes.length,
                        itemBuilder: (context, index) {
                          final shape = BlockCollection.allShapes[index];
                          final isUnlocked = shape.isUnlockedAt(currentLevel);
                          return _BlockCard(
                            shape: shape,
                            isUnlocked: isUnlocked,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  final BlockShape shape;
  final bool isUnlocked;

  const _BlockCard({required this.shape, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/buttons/paper.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: isUnlocked
              ? AppColors.accent.withValues(alpha: 0.35)
              : AppColors.textHint.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Blok görseli
          _BlockVisual(
            width: shape.width,
            height: shape.height,
            isUnlocked: isUnlocked,
          ),
          const SizedBox(height: 10),

          // İsim
          Text(
            shape.nameTr,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isUnlocked ? AppColors.parchmentText : AppColors.textHint,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),

          // Boyut
          Text(
            shape.sizeLabel,
            style: TextStyle(
              color: isUnlocked ? AppColors.textSecondary : AppColors.textHint,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 4),

          // Açılma durumu
          if (isUnlocked)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: AppColors.success, size: 14),
                SizedBox(width: 4),
                Text(
                  'Açık',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, color: AppColors.textHint, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Level ${shape.unlockAtLevel}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Blok boyutunu görsel olarak temsil eden widget.
class _BlockVisual extends StatelessWidget {
  final int width;
  final int height;
  final bool isUnlocked;

  const _BlockVisual({
    required this.width,
    required this.height,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    const cellSize = 22.0;
    final color = isUnlocked ? AppColors.accent : AppColors.textHint;

    return SizedBox(
      width: width * cellSize,
      height: height * cellSize,
      child: Stack(
        children: List.generate(width * height, (i) {
          final row = i ~/ width;
          final col = i % width;
          return Positioned(
            left: col * cellSize,
            top: row * cellSize,
            child: Container(
              width: cellSize - 2,
              height: cellSize - 2,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isUnlocked ? 0.3 : 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: color.withValues(alpha: isUnlocked ? 0.6 : 0.25),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
