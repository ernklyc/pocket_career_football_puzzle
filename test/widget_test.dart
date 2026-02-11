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

    // Boot ekranının yüklendiğini kontrol et
    expect(find.text('POCKET CAREER'), findsOneWidget);
  });
}
