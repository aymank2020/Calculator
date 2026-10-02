import 'package:flutter/material.dart';
import 'package:offline_foundation/offline_foundation.dart';

import 'logic.dart';

final appDefinition = AppDefinition(
  id: 'percentage_calculator',
  title: 'Percentage Calculator',
  description: 'Calculate percentages, changes, and original amounts offline.',
  icon: Icons.percent,
  builder: () => const PercentageCalculatorScreen(),
);

class PercentageCalculatorScreen extends StatefulWidget {
  const PercentageCalculatorScreen({super.key});

  @override
  State<PercentageCalculatorScreen> createState() =>
      _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState
    extends State<PercentageCalculatorScreen> {
  final _first = TextEditingController(text: '20');
  final _second = TextEditingController(text: '150');
  PercentageOperation _operation = PercentageOperation.percentOf;
  double? _result;
  String? _error;

  String get _firstLabel => switch (_operation) {
    PercentageOperation.percentOf => 'Percentage (%)',
    PercentageOperation.percentChange => 'Old value',
    PercentageOperation.originalAmount => 'Amount (the percentage part)',
  };

  String get _secondLabel => switch (_operation) {
    PercentageOperation.percentOf => 'Number',
    PercentageOperation.percentChange => 'New value',
    PercentageOperation.originalAmount => 'Percentage (%)',
  };

  String get _explanation => switch (_operation) {
    PercentageOperation.percentOf => 'Percentage ÷ 100 × number',
    PercentageOperation.percentChange =>
      '(New value − old value) ÷ old value × 100. The old value must be nonzero; negative old values use their signed base.',
    PercentageOperation.originalAmount =>
      'Amount ÷ (percentage ÷ 100). Example: if 30 is 20%, the original is 150.',
  };

  void _invalidate(String _) {
    setState(() {
      _result = null;
      _error = null;
    });
  }

  void _calculate() {
    try {
      final first = parseFiniteNumber(_first.text, _firstLabel);
      final second = parseFiniteNumber(_second.text, _secondLabel);
      final result = calculatePercentage(_operation, first, second);
      setState(() {
        _result = result;
        _error = null;
      });
    } on ArgumentError catch (error) {
      setState(() {
        _result = null;
        _error = error.message.toString();
      });
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return FeaturePage(
      title: 'Percentage Calculator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<PercentageOperation>(
            initialValue: _operation,
            decoration: const InputDecoration(labelText: 'Operation'),
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: PercentageOperation.percentOf,
                child: Text('Percent of a number'),
              ),
              DropdownMenuItem(
                value: PercentageOperation.percentChange,
                child: Text('Percent change'),
              ),
              DropdownMenuItem(
                value: PercentageOperation.originalAmount,
                child: Text('Find original amount'),
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
          const SizedBox(height: 20),
          Text(_explanation),
          const SizedBox(height: 20),
          Field(
            controller: _first,
            label: _firstLabel,
            numeric: true,
            onChanged: _invalidate,
          ),
          const SizedBox(height: 16),
          Field(
            controller: _second,
            label: _secondLabel,
            numeric: true,
            onChanged: _invalidate,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Calculate'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 20),
            ResultCard(
              title: _operation == PercentageOperation.percentChange
                  ? 'Percent change'
                  : _operation == PercentageOperation.originalAmount
                  ? 'Original amount'
                  : 'Result',
              value:
                  '${result.toStringAsPrecision(12)}${_operation == PercentageOperation.percentChange ? '%' : ''}',
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Accepts decimals, negative numbers, and percentages above 100. Results are rounded to 12 significant digits.',
          ),
        ],
      ),
    );
  }
}
