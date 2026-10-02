import 'package:flutter_test/flutter_test.dart';
import 'package:percentage_calculator/logic.dart';

void main() {
  group('percent of a number', () {
    test('supports decimal, zero, negative, and over-100 percentages', () {
      expect(percentOf(20, 150), 30);
      expect(percentOf(12.5, 80), 10);
      expect(percentOf(0, 150), 0);
      expect(percentOf(100, 0), 0);
      expect(percentOf(-20, 150), -30);
      expect(percentOf(150, 80), 120);
    });
  });

  group('percent change', () {
    test('calculates increase, decrease, unchanged and signed bases', () {
      expect(percentChange(100, 125), 25);
      expect(percentChange(100, 75), -25);
      expect(percentChange(100, 100), 0);
      expect(percentChange(100, 0), -100);
      expect(percentChange(-100, -50), -50);
    });
    test('rejects zero denominator, including negative zero', () {
      expect(() => percentChange(0, 10), throwsArgumentError);
      expect(() => percentChange(-0.0, 0), throwsArgumentError);
    });
  });

  group('original amount', () {
    test('reverses decimal, negative and over-100 percentages', () {
      expect(originalAmount(30, 20), 150);
      expect(originalAmount(10, 12.5), 80);
      expect(originalAmount(-30, 20), -150);
      expect(originalAmount(120, 150), 80);
      expect(originalAmount(0, 20), 0);
    });
    test('rejects zero percentage even with zero amount', () {
      expect(() => originalAmount(30, 0), throwsArgumentError);
      expect(() => originalAmount(0, -0.0), throwsArgumentError);
    });
  });

  test('rejects every non-finite operand in all operations', () {
    for (final operation in PercentageOperation.values) {
      for (final invalid in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          () => calculatePercentage(operation, invalid, 20),
          throwsArgumentError,
        );
        expect(
          () => calculatePercentage(operation, 20, invalid),
          throwsArgumentError,
        );
      }
    }
  });

  test('rejects overflowing results', () {
    expect(() => percentOf(200, 1.7e308), throwsArgumentError);
    expect(() => percentChange(1e-300, 1e300), throwsArgumentError);
    expect(() => originalAmount(1e308, 0.01), throwsArgumentError);
  });

  test(
    'parsing accepts finite scientific notation and rejects invalid text',
    () {
      expect(parseFiniteNumber(' 1.25e2 ', 'Number'), 125);
      for (final invalid in [
        '',
        'abc',
        'NaN',
        'Infinity',
        '-Infinity',
        '1e999',
      ]) {
        expect(() => parseFiniteNumber(invalid, 'Number'), throwsArgumentError);
      }
    },
  );

  test('operation selector dispatches each formula', () {
    expect(calculatePercentage(PercentageOperation.percentOf, 20, 150), 30);
    expect(
      calculatePercentage(PercentageOperation.percentChange, 100, 125),
      25,
    );
    expect(
      calculatePercentage(PercentageOperation.originalAmount, 30, 20),
      150,
    );
  });
}
