import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_calculator/logic.dart';

void main() {
  test('rectangle supports fractional dimensions', () {
    final result = calculateRectangle(2.5, 4);
    expect(result.area, 10);
    expect(result.perimeter, 13);
  });

  test('circle uses radius for area and circumference', () {
    final result = calculateCircle(2);
    expect(result.area, closeTo(4 * math.pi, 1e-12));
    expect(result.perimeter, closeTo(4 * math.pi, 1e-12));
  });

  test('Heron area is independent of side order', () {
    for (final sides in [
      [3.0, 4.0, 5.0],
      [5.0, 3.0, 4.0],
    ]) {
      final result = calculateTriangle(sides[0], sides[1], sides[2]);
      expect(result.area, closeTo(6, 1e-12));
      expect(result.perimeter, 12);
    }
    expect(calculateTriangle(2, 2, 2).area, closeTo(math.sqrt(3), 1e-12));
  });

  test('degenerate and impossible triangles fail', () {
    expect(() => calculateTriangle(1, 2, 3), throwsArgumentError);
    expect(() => calculateTriangle(3, 1, 1), throwsArgumentError);
    expect(calculateTriangle(1, 1, 1.999999).area, greaterThan(0));
  });

  test('non-positive and non-finite dimensions fail in every shape', () {
    for (final invalid in [0.0, -1.0, double.nan, double.infinity]) {
      expect(() => calculateRectangle(invalid, 1), throwsArgumentError);
      expect(() => calculateRectangle(1, invalid), throwsArgumentError);
      expect(() => calculateCircle(invalid), throwsArgumentError);
      expect(() => calculateTriangle(1, invalid, 1), throwsArgumentError);
    }
  });

  test('invalid text is rejected and trimmed decimals are accepted', () {
    expect(parseLength(' 2.5 ', 'Width'), 2.5);
    for (final text in ['', 'abc', 'NaN', 'Infinity', '-2', '0', '1e999']) {
      expect(() => parseLength(text, 'Width'), throwsArgumentError);
    }
  });

  test('overflow and underflow surface a range error', () {
    expect(() => calculateRectangle(1e308, 1e308), throwsArgumentError);
    expect(() => calculateCircle(1e308), throwsArgumentError);
    expect(() => calculateTriangle(1e308, 1e308, 1e308), throwsArgumentError);
    expect(() => calculateRectangle(1e-300, 1e-300), throwsArgumentError);
  });
}
