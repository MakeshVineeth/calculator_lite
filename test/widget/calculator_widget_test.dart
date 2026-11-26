import 'package:calculator_lite/Backend/custom_focus_events.dart';
import 'package:calculator_lite/UIElements/about_page.dart';
import 'package:calculator_lite/UIElements/display_screen.dart';
import 'package:calculator_lite/bottom_nav_class.dart';
import 'package:calculator_lite/calculator_tab.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    testWidgets('DisplayScreen handles long input and long output with scrollbars',
        (WidgetTester tester) async {
      final longCalculation = List.generate(50, (i) => '${i % 10}');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<CustomFocusEvents>(
              create: (_) => CustomFocusEvents(),
              child: Column(
                children: [
                  DisplayScreen(
                    calculationString: longCalculation,
                    mainValue: 123456789012345.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(DisplayScreen), findsOneWidget);
      expect(find.byType(RawScrollbar), findsNWidgets(2));
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

    testWidgets('AboutPage renders dynamically without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AboutPage(),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AboutPage), findsOneWidget);
      expect(find.text('Calculator Lite'), findsOneWidget);
    });

    testWidgets(
        'CalculatorTab keypad decimal button evaluates 622·22×30000 without Invalid Input',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorTab(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttons = [
        '6',
        '2',
        '2',
        FixedValues.decimalChar,
        '2',
        '2',
        FixedValues.multiplyChar,
        '3',
        '0',
        '0',
        '0',
        '0',
      ];
      for (var i = 0; i < buttons.length; i++) {
        await tester.tap(find.widgetWithText(ElevatedButton, buttons[i]));
        for (var attempt = 0; attempt < 20; attempt++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)),
          );
          await tester.pump();
          final current =
              tester.widget<DisplayScreen>(find.byType(DisplayScreen));
          if (current.calculationString.join().length == i + 1) {
            break;
          }
        }
      }

      for (var attempt = 0; attempt < 20; attempt++) {
        final current =
            tester.widget<DisplayScreen>(find.byType(DisplayScreen));
        if ((current.mainValue - 18666600.0).abs() < 0.0001) {
          break;
        }
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 25)),
        );
        await tester.pump();
      }

      final display = tester.widget<DisplayScreen>(find.byType(DisplayScreen));
      expect(
        display.calculationString.join(),
        equals('622.22${FixedValues.multiplyChar}30000'),
      );
      expect(display.mainValue, closeTo(18666600.0, 0.0001));
      expect(find.text('Invalid Input'), findsNothing);

      await tester.pump(const Duration(seconds: 7));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
