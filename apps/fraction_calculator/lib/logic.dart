enum FractionOperation { add, subtract, multiply, divide }

class Rational {
  final BigInt numerator;
  final BigInt denominator;

  factory Rational(BigInt numerator, BigInt denominator) {
    if (denominator == BigInt.zero) {
      throw const FormatException('Denominator cannot be zero.');
    }
    final gcd = numerator.abs().gcd(denominator.abs());
    final sign = denominator.isNegative ? -BigInt.one : BigInt.one;
    return Rational._(numerator ~/ gcd * sign, denominator ~/ gcd * sign);
  }

  const Rational._(this.numerator, this.denominator);

  factory Rational.parse(String numerator, String denominator) {
    BigInt read(String value, String label) {
      if (!RegExp(r'^[+-]?\d+$').hasMatch(value.trim())) {
        throw FormatException('$label must be a whole number.');
      }
      return BigInt.parse(value.trim());
    }

    return Rational(
      read(numerator, 'Numerator'),
      read(denominator, 'Denominator'),
    );
  }

  Rational calculate(FractionOperation operation, Rational other) {
    switch (operation) {
      case FractionOperation.add:
        return Rational(
          numerator * other.denominator + other.numerator * denominator,
          denominator * other.denominator,
        );
      case FractionOperation.subtract:
        return Rational(
          numerator * other.denominator - other.numerator * denominator,
          denominator * other.denominator,
        );
      case FractionOperation.multiply:
        return Rational(
          numerator * other.numerator,
          denominator * other.denominator,
        );
      case FractionOperation.divide:
        if (other.numerator == BigInt.zero) {
          throw const FormatException('Cannot divide by a zero fraction.');
        }
        return Rational(
          numerator * other.denominator,
          denominator * other.numerator,
        );
    }
  }

  /// Long division avoids converting arbitrarily large integers to doubles.
  /// A trailing ellipsis means more digits remain beyond the precision limit.
  String decimal({int precision = 12}) {
    if (precision < 1 || precision > 100) {
      throw RangeError.range(precision, 1, 100, 'precision');
    }
    final absolute = numerator.abs();
    final whole = absolute ~/ denominator;
    var remainder = absolute % denominator;
    final sign = numerator.isNegative ? '-' : '';
    if (remainder == BigInt.zero) return '$sign$whole';
    final digits = StringBuffer();
    for (var i = 0; i < precision && remainder != BigInt.zero; i++) {
      remainder *= BigInt.from(10);
      digits.write(remainder ~/ denominator);
      remainder %= denominator;
    }
    return '$sign$whole.$digits${remainder == BigInt.zero ? '' : '…'}';
  }

  @override
  String toString() => '$numerator/$denominator';
}
