import 'package:flutter/material.dart';
import 'package:offline_foundation/offline_foundation.dart';

import 'logic.dart';

final appDefinition = AppDefinition(
  id: 'unit_converter',
  title: 'Unit Converter',
  description: 'Convert length, mass, temperature, and volume offline.',
  icon: Icons.swap_horiz,
  builder: () => const UnitConverterScreen(),
);

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final _input = TextEditingController(text: '1');
  ConversionCategory _category = ConversionCategory.length;
  MeasureUnit _from = MeasureUnit.metre;
  MeasureUnit _to = MeasureUnit.foot;
  double? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _recalculate() {
    try {
      _result = convertQuantity(parseQuantity(_input.text), _from, _to);
      _error = null;
    } on FormatException catch (error) {
      _result = null;
      _error = error.message;
    }
  }

  void _selectCategory(ConversionCategory category) {
    setState(() {
      _category = category;
      final units = unitsFor(category);
      _from = units.first;
      _to = units[1];
      _recalculate();
    });
  }

  Widget _unitSelector(String label, MeasureUnit value, bool source) {
    return DropdownButtonFormField<MeasureUnit>(
      key: ValueKey('$label-${value.name}'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: unitsFor(_category)
          .map(
            (unit) => DropdownMenuItem(
              value: unit,
              child: Text('${unit.label} (${unit.symbol})'),
            ),
          )
          .toList(),
      onChanged: (unit) {
        if (unit == null) return;
        setState(() {
          if (source) {
            _from = unit;
          } else {
            _to = unit;
          }
          _recalculate();
        });
      },
    );
  }

  void _swap() {
    setState(() {
      if (_result != null) _input.text = _result.toString();
      final previous = _from;
      _from = _to;
      _to = previous;
      _recalculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FeaturePage(
      title: 'Unit Converter',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Everyday measurements, converted instantly.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<ConversionCategory>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: ConversionCategory.values
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  ),
                )
                .toList(),
            onChanged: (category) {
              if (category != null) _selectCategory(category);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _input,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: InputDecoration(
              labelText: 'Amount in ${_from.symbol}',
              hintText: 'For example, 12.5',
              border: const OutlineInputBorder(),
              errorText: _error,
              errorMaxLines: 3,
            ),
            onChanged: (_) => setState(_recalculate),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final from = _unitSelector('From', _from, true);
              final to = _unitSelector('To', _to, false);
              if (constraints.maxWidth < 540) {
                return Column(children: [from, const SizedBox(height: 12), to]);
              }
              return Row(
                children: [
                  Expanded(child: from),
                  const SizedBox(width: 16),
                  Expanded(child: to),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: OutlinedButton.icon(
              onPressed: _swap,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Swap units and amount'),
            ),
          ),
          const SizedBox(height: 16),
          if (_result != null)
            ResultCard(
              title: 'Converted amount',
              value: '${formatQuantity(_result!)} ${_to.symbol}',
            ),
          const SizedBox(height: 12),
          Text(switch (_category) {
            ConversionCategory.temperature =>
              'Temperature uses an offset as well as a scale. Values below absolute zero are rejected.',
            ConversionCategory.volume =>
              'US measures use customary liquid volumes (1 US cup = 236.5882365 mL). Imperial gallons are labeled separately.',
            ConversionCategory.mass =>
              'Ounces and pounds use avoirdupois mass. One stone is 14 pounds.',
            ConversionCategory.length =>
              'International inches and feet are used. One nautical mile is 1,852 metres.',
          }, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            'Results show up to 12 significant digits. Signed quantities and scientific notation are supported.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
