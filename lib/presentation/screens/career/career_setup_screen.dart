import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/theme/layout_constants.dart';
import 'package:pocket_career_football_puzzle/core/config/app_config.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/pressable_scale.dart';

/// İlk açılışta gösterilen kısa kariyer oluşturma formu.
class CareerSetupScreen extends ConsumerStatefulWidget {
  const CareerSetupScreen({super.key});

  @override
  ConsumerState<CareerSetupScreen> createState() => _CareerSetupScreenState();
}

class _CareerSetupScreenState extends ConsumerState<CareerSetupScreen> {
  final _nameController = TextEditingController();
  final _teamNameController = TextEditingController();
  String _selectedTeamId = AppConfig.availableTeams.first.id;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _createAndStart() async {
    final name = _nameController.text.trim();
    final teamName = _teamNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir isim girin')));
      return;
    }
    if (teamName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen takım adı girin')));
      return;
    }

    setState(() => _isCreating = true);

    try {
      await ref
          .read(careersProvider.notifier)
          .createCareer(
            playerName: name,
            playerAge: 20,
            position: 'Futbolcu',
            teamId: _selectedTeamId,
            teamName: teamName,
          );
      ref.invalidate(activeCareerProvider);

      if (mounted) {
        context.go('/game/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final paddingV = (size.height * 0.028).clamp(20.0, 32.0);
    final titleFontSize = (size.width * 0.058).clamp(20.0, 26.0);

    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/league/1.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: HomeLayout.screenHorizontalPadding,
                vertical: paddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Başlık — paper kart
                  _PaperCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Kariyerini Başlat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.titleFontFamily,
                            color: AppColors.parchmentText,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Logonu seç, takım ve oyuncu adını belirle!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.parchmentTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 1) Takım logosu — paper kart
                  _PaperCard(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Takımının Logosunu Seç',
                          style: TextStyle(
                            fontFamily: AppTheme.titleFontFamily,
                            color: AppColors.parchmentText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: AppConfig.availableTeams.length,
                          itemBuilder: (_, i) {
                            final team = AppConfig.availableTeams[i];
                            final isSelected = team.id == _selectedTeamId;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedTeamId = team.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Color(team.primaryColor)
                                          .withValues(alpha: 0.2)
                                      : AppColors.parchmentFillDark,
                                  border: Border.all(
                                    color: isSelected
                                        ? Color(team.primaryColor)
                                        : AppColors.parchmentBorder
                                            .withValues(alpha: 0.5),
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: team.logoAssetPath != null
                                      ? ClipOval(
                                          child: Image.asset(
                                            team.logoAssetPath!,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Text(
                                          team.logoEmoji,
                                          style: TextStyle(
                                            fontFamily: AppTheme.titleFontFamily,
                                            fontSize: 24,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2) Takım adı — paper kart
                  _PaperCard(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Takım Adı',
                          style: TextStyle(
                            fontFamily: AppTheme.titleFontFamily,
                            color: AppColors.parchmentText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _teamNameController,
                          maxLength: 20,
                          style: const TextStyle(
                            color: AppColors.parchmentText,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Takım adını gir...',
                            hintStyle: TextStyle(
                              color: AppColors.parchmentTextSecondary
                                  .withValues(alpha: 0.8),
                            ),
                            counterStyle: TextStyle(
                              color: AppColors.parchmentTextSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.parchmentFill
                                .withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3) Oyuncu adı — paper kart
                  _PaperCard(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Oyuncu Adı',
                          style: TextStyle(
                            fontFamily: AppTheme.titleFontFamily,
                            color: AppColors.parchmentText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          maxLength: 20,
                          style: const TextStyle(
                            color: AppColors.parchmentText,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'İsmini gir...',
                            hintStyle: TextStyle(
                              color: AppColors.parchmentTextSecondary
                                  .withValues(alpha: 0.8),
                            ),
                            counterStyle: TextStyle(
                              color: AppColors.parchmentTextSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.parchmentFill
                                .withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Başla butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: PressableScale(
                      onTap: _isCreating ? null : _createAndStart,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/buttons/play_button_v2.png',
                            ),
                            fit: BoxFit.fill,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isCreating
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'BAŞLA!',
                                  style: TextStyle(
                                    fontFamily: AppTheme.titleFontFamily,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.fieldGreenDark,
                                    letterSpacing: 0.5,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.white,
                                        offset: Offset(1, 1),
                                        blurRadius: 0,
                                      ),
                                      Shadow(
                                        color: Colors.white70,
                                        offset: Offset(0, 1),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _PaperCard({
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/buttons/paper.png'),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
