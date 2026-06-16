import 'package:flutter_test/flutter_test.dart';

import 'package:open_player/main.dart';

void main() {
  testWidgets('Violet app starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VioletApp());

    // Verify the app has a bottom navigation with Library.
    expect(find.text('Library'), findsWidgets);

    // Verify Settings tab exists.
    expect(find.text('Settings'), findsOneWidget);
  });
}
