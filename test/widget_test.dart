// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:sibeh_good_bank/main.dart';

void main() {
  testWidgets('App launches with onboarding screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SibehGoodBankApp());

    // Verify that the onboarding screen is displayed
    expect(find.text('New Age of\nCommercial\nBanking'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
