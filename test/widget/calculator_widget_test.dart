import 'package:calculator_lite/Backend/custom_focus_events.dart';
import 'package:calculator_lite/UIElements/display_screen.dart';
import 'package:calculator_lite/bottom_nav_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('Calculator Widget & UI Tests', () {
    testWidgets('DisplayScreen renders calculations and formatted numbers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<CustomFocusEvents>(
              create: (_) => CustomFocusEvents(),
              child: const Column(
                children: [
                  DisplayScreen(
                    calculationString: ['1', '2', '+', '3', '4'],
                    mainValue: 46.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify DisplayScreen widget is found
      expect(find.byType(DisplayScreen), findsOneWidget);
    });

    testWidgets('BottomNavClass returns valid NavigationBarItem',
        (WidgetTester tester) async {
      const item = BottomNavClass(
        title: 'Calculator',
        icon: Icons.calculate_outlined,
      );

      final navItem = item.returnNavItems();
      expect(navItem.label, equals('Calculator'));
      expect(navItem.icon, isNotNull);
      expect(navItem.activeIcon, isNotNull);
    });

    test('DisplayScreen formatNumber formats integers and floating values', () {
      expect(DisplayScreen.formatNumber(12345), equals('12345'));
      expect(DisplayScreen.formatNumber(0), equals('0'));
      expect(DisplayScreen.formatNumber(3.1415), contains('3.14'));
    });
  });
}
