enum PercentageOperation { percentOf, percentChange, originalAmount }

double parseFiniteNumber(String text, String label) {
  final value = double.tryParse(text.trim());
  if (value == null || !value.isFinite) {
    throw ArgumentError('$label must be a finite number.');
  }
  return value;
}

void _validate(double value, String label) {
  if (!value.isFinite) {
    throw ArgumentError('$label must be a finite number.');
  }
}

double _finiteResult(double result) {
  if (!result.isFinite) {
    throw ArgumentError('The result is too large to calculate.');
  }
  return result == 0 ? 0 : result;
}

double percentOf(double percentage, double number) {
  _validate(percentage, 'Percentage');
  _validate(number, 'Number');
  return _finiteResult(number * (percentage / 100));
}

double percentChange(double oldValue, double newValue) {
  _validate(oldValue, 'Old value');
  _validate(newValue, 'New value');
  if (oldValue == 0) {
    throw ArgumentError('Old value cannot be zero for percent change.');
  }
  return _finiteResult(((newValue - oldValue) / oldValue) * 100);
}

double originalAmount(double amount, double percentage) {
  _validate(amount, 'Amount');
  _validate(percentage, 'Percentage');
  if (percentage == 0) {
    throw ArgumentError('Percentage cannot be zero when finding the original.');
  }
  return _finiteResult(amount / (percentage / 100));
}

double calculatePercentage(
  PercentageOperation operation,
  double first,
  double second,
) => switch (operation) {
  PercentageOperation.percentOf => percentOf(first, second),
  PercentageOperation.percentChange => percentChange(first, second),
  PercentageOperation.originalAmount => originalAmount(first, second),
};
