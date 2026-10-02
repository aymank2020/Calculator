import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_hub/main.dart';

void main() {
  testWidgets('catalog opens calculator and displays result or input error', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorHub());
    await tester.tap(find.text('Percentages'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate'));
    await tester.pump();
    expect(find.text('30.0000000000'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'NaN');
    await tester.pump();
    expect(find.text('30.0000000000'), findsNothing);
    await tester.tap(find.text('Calculate'));
    await tester.pump();
    expect(find.textContaining('finite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 1280.0]) {
    testWidgets('all five tools are reachable and return at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const CalculatorHub());
      for (final name in [
        'Percentages',
        'Fractions',
        'Geometry',
        'Number bases',
        'Unit conversion',
      ]) {
        await tester.ensureVisible(find.text(name));
        await tester.tap(find.text(name));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Calculator Hub'), findsOneWidget);
      }
    });
  }
}
