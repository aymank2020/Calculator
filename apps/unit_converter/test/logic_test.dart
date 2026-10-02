import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/logic.dart';

void main() {
  test('international and nautical length factors', () {
    expect(
      convertQuantity(1, MeasureUnit.mile, MeasureUnit.foot),
      closeTo(5280, 1e-9),
    );
    expect(
      convertQuantity(1, MeasureUnit.nauticalMile, MeasureUnit.metre),
      1852,
    );
    expect(
      convertQuantity(-2, MeasureUnit.metre, MeasureUnit.centimetre),
      -200,
    );
  });

  test('avoirdupois mass and metric tonnes', () {
    expect(
      convertQuantity(1, MeasureUnit.pound, MeasureUnit.gram),
      closeTo(453.59237, 1e-9),
    );
    expect(
      convertQuantity(1, MeasureUnit.stone, MeasureUnit.pound),
      closeTo(14, 1e-12),
    );
    expect(convertQuantity(2, MeasureUnit.tonne, MeasureUnit.kilogram), 2000);
  });

  test('temperature offsets and fixed point', () {
    expect(
      convertQuantity(0, MeasureUnit.celsius, MeasureUnit.fahrenheit),
      closeTo(32, 1e-10),
    );
    expect(
      convertQuantity(212, MeasureUnit.fahrenheit, MeasureUnit.celsius),
      closeTo(100, 1e-10),
    );
    expect(
      convertQuantity(-40, MeasureUnit.celsius, MeasureUnit.fahrenheit),
      closeTo(-40, 1e-10),
    );
    expect(
      convertQuantity(-273.15, MeasureUnit.celsius, MeasureUnit.kelvin),
      0,
    );
    expect(
      convertQuantity(-459.67, MeasureUnit.fahrenheit, MeasureUnit.kelvin),
      closeTo(0, 1e-10),
    );
  });

  test('rejects temperatures even just below absolute zero', () {
    for (final entry in {
      MeasureUnit.celsius: -273.150000001,
      MeasureUnit.fahrenheit: -459.670000001,
      MeasureUnit.kelvin: -1e-15,
    }.entries) {
      expect(
        () => convertQuantity(entry.value, entry.key, MeasureUnit.kelvin),
        throwsFormatException,
      );
    }
  });

  test('US and imperial volumes are distinct', () {
    expect(
      convertQuantity(1, MeasureUnit.gallon, MeasureUnit.litre),
      3.785411784,
    );
    expect(
      convertQuantity(1, MeasureUnit.imperialGallon, MeasureUnit.litre),
      4.54609,
    );
    expect(
      convertQuantity(1, MeasureUnit.cup, MeasureUnit.fluidOunce),
      closeTo(8, 1e-12),
    );
    expect(
      convertQuantity(1, MeasureUnit.tablespoon, MeasureUnit.teaspoon),
      closeTo(3, 1e-12),
    );
  });

  test('category lists cannot mix incompatible dimensions', () {
    for (final category in ConversionCategory.values) {
      expect(unitsFor(category).length, greaterThanOrEqualTo(3));
      expect(
        unitsFor(category).every((unit) => unit.category == category),
        isTrue,
      );
    }
    expect(
      () => convertQuantity(1, MeasureUnit.metre, MeasureUnit.kilogram),
      throwsFormatException,
    );
  });

  test(
    'parsing accepts scientific notation and rejects invalid/non-finite input',
    () {
      expect(parseQuantity(' 1.5e3 '), 1500);
      for (final input in [
        '',
        'abc',
        '1,000',
        'NaN',
        'Infinity',
        '-Infinity',
        '1e999',
      ]) {
        expect(() => parseQuantity(input), throwsFormatException);
      }
      expect(
        () => convertQuantity(double.nan, MeasureUnit.metre, MeasureUnit.foot),
        throwsFormatException,
      );
      expect(
        () => convertQuantity(
          double.infinity,
          MeasureUnit.metre,
          MeasureUnit.foot,
        ),
        throwsFormatException,
      );
      expect(
        () => convertQuantity(
          1e308,
          MeasureUnit.kilometre,
          MeasureUnit.millimetre,
        ),
        throwsFormatException,
      );
    },
  );

  test('compatible conversions round trip across every unit', () {
    for (final category in ConversionCategory.values) {
      final units = unitsFor(category);
      for (final from in units) {
        for (final to in units) {
          final result = convertQuantity(123.456, from, to);
          expect(convertQuantity(result, to, from), closeTo(123.456, 1e-8));
        }
      }
    }
  });

  test('formatting trims fractional zeros and preserves very small values', () {
    expect(formatQuantity(10), '10');
    expect(formatQuantity(1.25), '1.25');
    expect(formatQuantity(-0.0), '0');
    expect(double.parse(formatQuantity(1e-20)), 1e-20);
    expect(() => formatQuantity(double.infinity), throwsFormatException);
  });
}
