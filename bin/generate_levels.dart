// ignore_for_file: avoid_print
// ============================================================
// LEVEL ÜRETİM SCRIPTİ
// ============================================================
// Bu script geliştirme sırasında çalıştırılır.
// 100 leveli config'e göre deterministik üretir ve
// assets/levels.json dosyasına kaydeder.
//
// Kullanım:
//   dart run bin/generate_levels.dart
//
// Çıktı:
//   assets/levels.json (~75-100KB)
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:pocket_career_football_puzzle/game/level_generator.dart';
import 'package:pocket_career_football_puzzle/game/level_configs.dart';

void main() {
  print('');
  print('═══════════════════════════════════════════════');
  print('  POCKET CAREER — Level Üretim Scripti');
  print('═══════════════════════════════════════════════');
  print('');

  final totalLevels = allLevelConfigs.length;
  print('Toplam $totalLevels level üretilecek...');
  print('');

  final stopwatch = Stopwatch()..start();
  final levels = <Map<String, dynamic>>[];
  int fallbackCount = 0;

  for (int i = 1; i <= totalLevels; i++) {
    final config = allLevelConfigs[i - 1];
    final levelStopwatch = Stopwatch()..start();

    final level = LevelGenerator.generate(levelNumber: i);
    levelStopwatch.stop();

    // Fallback mu kontrol et
    final isFallback = level.optimalMoves == 3 && level.maxMoves == 5 &&
        level.initialBlocks.length == 3;
    if (isFallback) fallbackCount++;

    // Konsol çıktısı
    final status = isFallback ? '⚠️  FALLBACK' : '✅';
    final grid = '${config.gridSize}x${config.gridSize}';
    final blocks = '${level.initialBlocks.length - 1} blok';
    final optimal = 'optimal:${level.optimalMoves}';
    final max = 'max:${level.maxMoves}';
    final time = '${levelStopwatch.elapsedMilliseconds}ms';

    print('  L${i.toString().padLeft(3, '0')}  $grid  $blocks  $optimal  $max  $time  $status');

    levels.add(level.toJson());
  }

  stopwatch.stop();

  // JSON yaz
  final jsonString = const JsonEncoder.withIndent('  ').convert(levels);

  final outputDir = Directory('assets');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final outputFile = File('assets/levels.json');
  outputFile.writeAsStringSync(jsonString);

  final fileSizeKB = (outputFile.lengthSync() / 1024).toStringAsFixed(1);

  print('');
  print('═══════════════════════════════════════════════');
  print('  Sonuç:');
  print('    Toplam level: $totalLevels');
  print('    Fallback level: $fallbackCount');
  print('    Süre: ${stopwatch.elapsedMilliseconds}ms');
  print('    Dosya: assets/levels.json ($fileSizeKB KB)');
  print('═══════════════════════════════════════════════');
  print('');

  if (fallbackCount > 0) {
    print('⚠️  $fallbackCount level fallback kullandı.');
    print('    Bu levellerin config parametrelerini gözden geçirin.');
    print('');
  }

  print('✅ Tamamlandı! assets/levels.json güncellendi.');
  print('   Uygulamayı yeniden build edin.');
  print('');
}
