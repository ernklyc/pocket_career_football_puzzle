import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_career_football_puzzle/core/config/progression_schema.dart';
import 'package:pocket_career_football_puzzle/game/level_configs.dart';

void main() {
  group('ProgressionSchema', () {
    test('levelCount equals allLevelConfigs.length', () {
      expect(ProgressionSchema.levelCount, allLevelConfigs.length);
    });

    test('chapterRange(0) returns (1, 10)', () {
      final (start, end) = ProgressionSchema.chapterRange(0);
      expect(start, 1);
      expect(end, 10);
    });

    test('chapterRange(9) returns (91, 100)', () {
      final (start, end) = ProgressionSchema.chapterRange(9);
      expect(start, 91);
      expect(end, 100);
    });

    test('blockFirstAppearance (2,1) = 1', () {
      expect(ProgressionSchema.blockFirstAppearance(2, 1), 1);
    });

    test('blockFirstAppearance (1,2) = 1', () {
      expect(ProgressionSchema.blockFirstAppearance(1, 2), 1);
    });

    test('blockFirstAppearance (1,1) = 11', () {
      expect(ProgressionSchema.blockFirstAppearance(1, 1), 11);
    });

    test('blockFirstAppearance (3,1) = 21', () {
      expect(ProgressionSchema.blockFirstAppearance(3, 1), 21);
    });

    test('blockFirstAppearance (1,3) = 21', () {
      expect(ProgressionSchema.blockFirstAppearance(1, 3), 21);
    });

    test('blockFirstAppearance (2,2) = 41', () {
      expect(ProgressionSchema.blockFirstAppearance(2, 2), 41);
    });

    test('shapesInLevelsUpTo(20) contains 1x1, not 1x3', () {
      final shapes = ProgressionSchema.shapesInLevelsUpTo(20);
      expect(shapes.contains((1, 1)), isTrue);
      expect(shapes.contains((3, 1)), isFalse);
    });

    test('shapesInLevelsUpTo(21) contains 1x3', () {
      final shapes = ProgressionSchema.shapesInLevelsUpTo(21);
      expect(shapes.contains((3, 1)), isTrue);
    });
  });
}
