import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/config/app_config.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Başlık
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 60,
                      color: AppColors.primaryLight,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Kariyerini Başlat',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Logonu seç, takım ve oyuncu adını belirle!',
                      style: TextStyle(color: AppColors.textHint, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // 1) Logo seçimi — sadece emoji, isim yok
              const Text(
                'Takımının Logosunu Seç',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    onTap: () => setState(() => _selectedTeamId = team.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(team.primaryColor).withValues(alpha: 0.15)
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Color(team.primaryColor)
                              : AppColors.surfaceLight,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: team.logoAssetPath != null
                            ? ClipOval(
                                child: Image.asset(
                                  team.logoAssetPath!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                team.logoEmoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // 2) Takım adı
              const Text(
                'Takım Adı',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _teamNameController,
                maxLength: 20,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Takım adını gir...',
                  hintStyle: TextStyle(
                    color: AppColors.textHint.withValues(alpha: 0.5),
                  ),
                  counterStyle: const TextStyle(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.cardBackground,
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

              const SizedBox(height: 16),

              // 3) Oyuncu adı
              const Text(
                'Oyuncu Adı',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                maxLength: 20,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'İsmini gir...',
                  hintStyle: TextStyle(
                    color: AppColors.textHint.withValues(alpha: 0.5),
                  ),
                  counterStyle: const TextStyle(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.cardBackground,
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

              const SizedBox(height: 32),

              // Başla butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createAndStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Başla!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
