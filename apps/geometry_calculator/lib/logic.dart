import 'dart:math' as math;

class GeometryResult {
  final double area;
  final double perimeter;

  const GeometryResult({required this.area, required this.perimeter});
}

double parseLength(String text, String label) {
  final value = double.tryParse(text.trim());
  if (value == null || !value.isFinite || value <= 0) {
    throw ArgumentError('$label must be a finite number greater than zero.');
  }
  return value;
}

void _validate(double value, String label) {
  if (!value.isFinite || value <= 0) {
    throw ArgumentError('$label must be a finite number greater than zero.');
  }
}

GeometryResult _result(double area, double perimeter) {
  if (!area.isFinite || !perimeter.isFinite || area <= 0) {
    throw ArgumentError(
      'These dimensions exceed the supported numerical range.',
    );
  }
  return GeometryResult(area: area, perimeter: perimeter);
}

GeometryResult calculateRectangle(double width, double height) {
  _validate(width, 'Width');
  _validate(height, 'Height');
  return _result(width * height, 2 * width + 2 * height);
}

GeometryResult calculateCircle(double radius) {
  _validate(radius, 'Radius');
  return _result(math.pi * radius * radius, 2 * math.pi * radius);
}

GeometryResult calculateTriangle(double a, double b, double c) {
  _validate(a, 'Side A');
  _validate(b, 'Side B');
  _validate(c, 'Side C');
  final sides = [a, b, c]..sort();
  final small = sides[0];
  final middle = sides[1];
  final large = sides[2];
  if (small <= large - middle) {
    throw ArgumentError(
      'The two shorter sides must sum to more than the longest side.',
    );
  }
  // Scaled, rearranged Heron formula avoids cancellation near degeneracy
  // and prevents the intermediate product from overflowing unnecessarily.
  final x = small / large;
  final y = middle / large;
  final gap = (large - middle) / large;
  final product = (1 + (y + x)) * (x - gap) * (x + gap) * (1 + (y - x));
  final area = (math.sqrt(product) / 4 * large) * large;
  return _result(area, small + middle + large);
}
