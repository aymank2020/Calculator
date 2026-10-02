enum ConversionCategory {
  length('Length'),
  mass('Mass'),
  temperature('Temperature'),
  volume('Volume');

  const ConversionCategory(this.label);
  final String label;
}

/// Factors convert to metres, kilograms, kelvin, or litres respectively.
enum MeasureUnit {
  millimetre(ConversionCategory.length, 'Millimetres', 'mm', 0.001),
  centimetre(ConversionCategory.length, 'Centimetres', 'cm', 0.01),
  metre(ConversionCategory.length, 'Metres', 'm', 1),
  kilometre(ConversionCategory.length, 'Kilometres', 'km', 1000),
  inch(ConversionCategory.length, 'Inches', 'in', 0.0254),
  foot(ConversionCategory.length, 'Feet', 'ft', 0.3048),
  yard(ConversionCategory.length, 'Yards', 'yd', 0.9144),
  mile(ConversionCategory.length, 'Miles', 'mi', 1609.344),
  nauticalMile(ConversionCategory.length, 'Nautical miles', 'nmi', 1852),
  milligram(ConversionCategory.mass, 'Milligrams', 'mg', 0.000001),
  gram(ConversionCategory.mass, 'Grams', 'g', 0.001),
  kilogram(ConversionCategory.mass, 'Kilograms', 'kg', 1),
  tonne(ConversionCategory.mass, 'Metric tonnes', 't', 1000),
  ounce(ConversionCategory.mass, 'Ounces', 'oz', 0.028349523125),
  pound(ConversionCategory.mass, 'Pounds', 'lb', 0.45359237),
  stone(ConversionCategory.mass, 'Stones', 'st', 6.35029318),
  celsius(ConversionCategory.temperature, 'Celsius', '°C', 1, 273.15),
  fahrenheit(
    ConversionCategory.temperature,
    'Fahrenheit',
    '°F',
    5 / 9,
    459.67 * 5 / 9,
  ),
  kelvin(ConversionCategory.temperature, 'Kelvin', 'K', 1),
  millilitre(ConversionCategory.volume, 'Millilitres', 'mL', 0.001),
  litre(ConversionCategory.volume, 'Litres', 'L', 1),
  cubicMetre(ConversionCategory.volume, 'Cubic metres', 'm³', 1000),
  teaspoon(
    ConversionCategory.volume,
    'US teaspoons',
    'US tsp',
    0.00492892159375,
  ),
  tablespoon(
    ConversionCategory.volume,
    'US tablespoons',
    'US tbsp',
    0.01478676478125,
  ),
  fluidOunce(
    ConversionCategory.volume,
    'US fluid ounces',
    'US fl oz',
    0.0295735295625,
  ),
  cup(ConversionCategory.volume, 'US cups', 'US cup', 0.2365882365),
  pint(ConversionCategory.volume, 'US liquid pints', 'US pt', 0.473176473),
  quart(ConversionCategory.volume, 'US liquid quarts', 'US qt', 0.946352946),
  gallon(ConversionCategory.volume, 'US liquid gallons', 'US gal', 3.785411784),
  imperialGallon(
    ConversionCategory.volume,
    'Imperial gallons',
    'imp gal',
    4.54609,
  );

  const MeasureUnit(
    this.category,
    this.label,
    this.symbol,
    this.factor, [
    this.offset = 0,
  ]);
  final ConversionCategory category;
  final String label;
  final String symbol;
  final double factor;
  final double offset;
}

List<MeasureUnit> unitsFor(ConversionCategory category) =>
    MeasureUnit.values.where((unit) => unit.category == category).toList();

double parseQuantity(String input) {
  final value = double.tryParse(input.trim());
  if (value == null || !value.isFinite) {
    throw const FormatException('Enter a finite number, such as 12.5 or -40.');
  }
  return value;
}

double convertQuantity(double value, MeasureUnit from, MeasureUnit to) {
  if (!value.isFinite) {
    throw const FormatException('The input must be a finite number.');
  }
  if (from.category != to.category) {
    throw const FormatException('Choose units from the same category.');
  }
  // Check in the source unit before arithmetic so very small negative kelvin
  // values and values just below absolute zero are never silently accepted.
  if (from.category == ConversionCategory.temperature) {
    final minimum = switch (from) {
      MeasureUnit.celsius => -273.15,
      MeasureUnit.fahrenheit => -459.67,
      _ => 0.0,
    };
    if (value < minimum) {
      throw const FormatException('Temperature cannot be below absolute zero.');
    }
  }
  var base = value * from.factor + from.offset;
  if (from.category == ConversionCategory.temperature && base < 0) {
    base = 0; // Floating point residue at exactly absolute zero.
  }
  final result = (base - to.offset) / to.factor;
  if (!base.isFinite || !result.isFinite) {
    throw const FormatException(
      'This conversion exceeds the supported number range.',
    );
  }
  return result == 0 ? 0 : result;
}

String formatQuantity(double value) {
  if (!value.isFinite) {
    throw const FormatException('Cannot display a non-finite result.');
  }
  if (value == 0) return '0';
  final text = value.toStringAsPrecision(12);
  final parts = text.split('e');
  final mantissa = parts.first.contains('.')
      ? parts.first
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '')
      : parts.first;
  return parts.length == 1 ? mantissa : '${mantissa}e${parts.last}';
}
