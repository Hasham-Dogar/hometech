// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/core/app/main.dart';

void main() {
  testWidgets('App shows Home after splash', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // SplashScreen uses a 2 second Timer to navigate to /home.
    // Advance time and allow animations/navigation to settle.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify HomePage is shown by looking for the header text.
    expect(find.text('Home'), findsOneWidget);
  });
}
