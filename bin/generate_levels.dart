// ignore_for_file: avoid_print
// ============================================================
// LEVEL ÜRETİM SCRIPTİ — v2
// ============================================================
// Kullanım:
//   dart run bin/generate_levels.dart           → 100 level üretir
//   dart run bin/generate_levels.dart 150       → 150 level üretir
//   dart run bin/generate_levels.dart 200       → 200 level üretir
//
// Çıktı: assets/levels.json
// Not: değişiklik sonrası uygulamayı yeniden build edin.
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:pocket_career_football_puzzle/game/level_generator.dart';
import 'package:pocket_career_football_puzzle/game/level_configs.dart';

void main(List<String> args) {
  final totalLevels = args.isNotEmpty
      ? (int.tryParse(args[0]) ?? allLevelConfigs.length)
      : allLevelConfigs.length;

  print('');
  print('═══════════════════════════════════════════════════════════');
  print('   POCKET CAREER — Level Üretim Scripti v2');
  print('   Sawtooth difficulty eğrisi | Sınırsız level desteği');
  print('═══════════════════════════════════════════════════════════');
  print('   Üretilecek: $totalLevels level');
  print('');

  final stopwatch = Stopwatch()..start();
  final levels = <Map<String, dynamic>>[];
  int fallbackCount = 0;
  int totalDS = 0;
  int minDS = 9999;
  int maxDS = 0;

  // Header
  print('  L#   Grid    Blok  Opt  Max  DS   Tier         Süre    Durum');
  print('  ─────────────────────────────────────────────────────────────');

  for (int i = 1; i <= totalLevels; i++) {
    final levelStopwatch = Stopwatch()..start();
    final level = LevelGenerator.generate(levelNumber: i);
    levelStopwatch.stop();

    // Fallback kontrol
    final isFallback =
        level.optimalMoves == 3 &&
        level.maxMoves == 5 &&
        level.initialBlocks.length == 3;
    if (isFallback) fallbackCount++;

    // Config'den DS hesapla (statik configler için)
    int ds = 0;
    if (i <= allLevelConfigs.length) {
      final cfg = allLevelConfigs[i - 1];
      ds = cfg.difficultyScore;
    } else {
      ds =
          level.optimalMoves * 10 +
          (level.initialBlocks.length - 1) * 5 -
          (level.maxMoves - level.optimalMoves) * 3;
    }
    totalDS += ds;
    if (ds < minDS) minDS = ds;
    if (ds > maxDS) maxDS = ds;

    final status = isFallback ? '⚠ FALLBACK' : '✓';
    final grid = '${level.gridRows}x${level.gridCols}';
    final blocks = '${level.initialBlocks.length - 1}';
    final optStr = level.optimalMoves.toString().padLeft(3);
    final maxStr = level.maxMoves.toString().padLeft(3);
    final dsStr = ds.toString().padLeft(4);
    final tier = (level.difficultyTier ?? '?').padRight(12);
    final timeStr = '${levelStopwatch.elapsedMilliseconds}ms'.padLeft(5);
    final num = i.toString().padLeft(3);

    print(
      '  L$num  $grid  $blocks blok  $optStr  $maxStr  $dsStr  $tier  $timeStr  $status',
    );
    levels.add(level.toJson());
  }

  stopwatch.stop();

  // JSON yaz
  final jsonString = const JsonEncoder.withIndent('  ').convert(levels);
  final outputDir = Directory('assets');
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

  final outputFile = File('assets/levels.json');
  outputFile.writeAsStringSync(jsonString);
  final fileSizeKB = (outputFile.lengthSync() / 1024).toStringAsFixed(1);

  print('');
  print('═══════════════════════════════════════════════════════════');
  print('  📊 İstatistikler:');
  print('     Toplam level   : $totalLevels');
  print('     Fallback       : $fallbackCount');
  print('     Süre           : ${stopwatch.elapsedMilliseconds}ms');
  print('     DS Aralığı     : $minDS – $maxDS');
  print('     DS Ortalama    : ${(totalDS / totalLevels).toStringAsFixed(1)}');
  print('     JSON boyutu    : $fileSizeKB KB');
  print('─────────────────────────────────────────────────────────');
  print('  📁 assets/levels.json güncellendi.');
  print('═══════════════════════════════════════════════════════════');
  print('');

  if (fallbackCount > 0) {
    print('⚠  $fallbackCount level fallback kullandı.');
    print(
      '   Config parametrelerini gözden geçirin (optimalMin çok yüksek olabilir).',
    );
    print('');
  }

  print('✅ Tamamlandı! Uygulamayı yeniden build edin.');
  print('');
}
