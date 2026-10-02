enum IntegerBase {
  binary(2, 'Binary'),
  octal(8, 'Octal'),
  decimal(10, 'Decimal'),
  hexadecimal(16, 'Hexadecimal');

  const IntegerBase(this.radix, this.label);
  final int radix;
  final String label;
}

/// Reads a signed integer with no radix prefix or digit separators.
BigInt parseInteger(String input, IntegerBase base) {
  final text = input.trim();
  if (text.isEmpty) {
    throw const FormatException('Enter an integer.');
  }
  final signed = text.startsWith('-') || text.startsWith('+');
  final digits = signed ? text.substring(1) : text;
  if (digits.isEmpty) {
    throw const FormatException('A sign must be followed by digits.');
  }
  for (final code in digits.toLowerCase().codeUnits) {
    final digit = code >= 48 && code <= 57
        ? code - 48
        : code >= 97 && code <= 102
        ? code - 87
        : -1;
    if (digit < 0 || digit >= base.radix) {
      throw FormatException(
        'Invalid ${base.label.toLowerCase()} digit "${String.fromCharCode(code)}". '
        'Use digits only, without prefixes or separators.',
      );
    }
  }
  final magnitude = BigInt.parse(digits, radix: base.radix);
  return text.startsWith('-') ? -magnitude : magnitude;
}

Map<IntegerBase, String> convertInteger(String input, IntegerBase source) {
  final number = parseInteger(input, source);
  return {
    for (final base in IntegerBase.values)
      base: number.toRadixString(base.radix).toUpperCase(),
  };
}
