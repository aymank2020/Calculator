import 'package:flutter_test/flutter_test.dart';
import 'package:fraction_calculator/logic.dart';

void main() {
  Rational fraction(String n, String d) => Rational.parse(n, d);

  test('reduces fractions and normalizes negative denominator', () {
    expect(fraction('6', '-8').toString(), '-3/4');
    expect(fraction('-6', '-8').toString(), '3/4');
    expect(fraction('0', '-25').toString(), '0/1');
  });

  test('all four operations are exact', () {
    final half = fraction('1', '2');
    final third = fraction('1', '3');
    expect(half.calculate(FractionOperation.add, third).toString(), '5/6');
    expect(half.calculate(FractionOperation.subtract, third).toString(), '1/6');
    expect(half.calculate(FractionOperation.multiply, third).toString(), '1/6');
    expect(half.calculate(FractionOperation.divide, third).toString(), '3/2');
    expect(
      third.calculate(FractionOperation.subtract, half).toString(),
      '-1/6',
    );
  });

  test('large integers retain exact precision', () {
    final value = fraction('999999999999999999999999999999', '3');
    expect(value.toString(), '333333333333333333333333333333/1');
    expect(value.decimal(), '333333333333333333333333333333');
  });

  test(
    'decimal long division handles finite repeating and negative values',
    () {
      expect(fraction('-1', '8').decimal(), '-0.125');
      expect(fraction('1', '3').decimal(), '0.333333333333…');
      expect(fraction('7', '2').decimal(), '3.5');
      expect(() => fraction('1', '3').decimal(precision: 0), throwsRangeError);
    },
  );

  test('rejects empty decimal nonfinite and zero denominators', () {
    for (final invalid in ['', '1.5', 'NaN', 'Infinity', '1e2']) {
      expect(() => fraction(invalid, '2'), throwsFormatException);
    }
    expect(() => fraction('1', '0'), throwsFormatException);
    expect(
      () => fraction(
        '1',
        '2',
      ).calculate(FractionOperation.divide, fraction('0', '3')),
      throwsFormatException,
    );
    expect(fraction(' +6 ', ' 9 ').toString(), '2/3');
  });
}
