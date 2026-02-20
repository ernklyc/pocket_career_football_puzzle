import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_career_football_puzzle/app.dart';

void main() {
  testWidgets('App starts without crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PocketCareerApp(),
      ),
    );

    // Uygulama crash olmadan açıldığını kontrol et
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
