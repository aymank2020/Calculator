import 'package:flutter/material.dart';
import 'package:offline_foundation/offline_foundation.dart';

import 'logic.dart';

final appDefinition = AppDefinition(
  id: 'fraction_calculator',
  title: 'Fraction Calculator',
  description: 'Calculate and simplify exact fractions offline.',
  icon: Icons.calculate_outlined,
  builder: () => const FractionCalculatorScreen(),
);

class FractionCalculatorScreen extends StatefulWidget {
  const FractionCalculatorScreen({super.key});

  @override
  State<FractionCalculatorScreen> createState() =>
      _FractionCalculatorScreenState();
}

class _FractionCalculatorScreenState extends State<FractionCalculatorScreen> {
  final _firstNumerator = TextEditingController(text: '1');
  final _firstDenominator = TextEditingController(text: '2');
  final _secondNumerator = TextEditingController(text: '1');
  final _secondDenominator = TextEditingController(text: '3');
  FractionOperation _operation = FractionOperation.add;
  Rational? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _firstNumerator.dispose();
    _firstDenominator.dispose();
    _secondNumerator.dispose();
    _secondDenominator.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final first = Rational.parse(
        _firstNumerator.text,
        _firstDenominator.text,
      );
      final second = Rational.parse(
        _secondNumerator.text,
        _secondDenominator.text,
      );
      setState(() {
        _result = first.calculate(_operation, second);
        _error = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _result = null;
        _error = error.message;
      });
    }
  }

  void _invalidate(String _) {
    setState(() {
      _result = null;
      _error = null;
    });
  }

  Widget _fractionFields(
    String label,
    TextEditingController numerator,
    TextEditingController denominator,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Field(
              controller: numerator,
              label: 'Numerator',
              onChanged: _invalidate,
            ),
            const SizedBox(height: 12),
            Field(
              controller: denominator,
              label: 'Denominator',
              onChanged: _invalidate,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FeaturePage(
      title: 'Fraction Calculator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter signed whole numbers. Results are reduced to their simplest form.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final first = _fractionFields(
                'First fraction',
                _firstNumerator,
                _firstDenominator,
              );
              final second = _fractionFields(
                'Second fraction',
                _secondNumerator,
                _secondDenominator,
              );
              if (constraints.maxWidth < 560) {
                return Column(children: [first, second]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: first),
                  const SizedBox(width: 12),
                  Expanded(child: second),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<FractionOperation>(
            initialValue: _operation,
            decoration: const InputDecoration(
              labelText: 'Operation',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: FractionOperation.add,
                child: Text('Add (+)'),
              ),
              DropdownMenuItem(
                value: FractionOperation.subtract,
                child: Text('Subtract (−)'),
              ),
              DropdownMenuItem(
                value: FractionOperation.multiply,
                child: Text('Multiply (×)'),
              ),
              DropdownMenuItem(
                value: FractionOperation.divide,
                child: Text('Divide (÷)'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _operation = value;
                _result = null;
                _error = null;
              });
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            ResultCard(title: 'Simplified fraction', value: _result.toString()),
            ResultCard(title: 'Decimal', value: _result!.decimal()),
            const Text(
              'Decimals show up to 12 places. An ellipsis indicates remaining digits.',
            ),
          ],
        ],
      ),
    );
  }
}
