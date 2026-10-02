import 'package:flutter/material.dart';
import 'package:offline_foundation/offline_foundation.dart';

import 'logic.dart';

final appDefinition = AppDefinition(
  id: 'geometry_calculator',
  title: 'Geometry Calculator',
  description: 'Area and perimeter for rectangles, circles, and triangles.',
  icon: Icons.square_foot,
  builder: () => const GeometryCalculator(),
);

enum _Shape { rectangle, circle, triangle }

class GeometryCalculator extends StatefulWidget {
  const GeometryCalculator({super.key});

  @override
  State<GeometryCalculator> createState() => _GeometryCalculatorState();
}

class _GeometryCalculatorState extends State<GeometryCalculator> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  final _third = TextEditingController();
  _Shape _shape = _Shape.rectangle;
  GeometryResult? _result;
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    _third.dispose();
    super.dispose();
  }

  void _invalidate(String _) {
    if (_result != null || _error != null) {
      setState(() {
        _result = null;
        _error = null;
      });
    }
  }

  void _calculate() {
    try {
      final GeometryResult result;
      switch (_shape) {
        case _Shape.rectangle:
          result = calculateRectangle(
            parseLength(_first.text, 'Width'),
            parseLength(_second.text, 'Height'),
          );
        case _Shape.circle:
          result = calculateCircle(parseLength(_first.text, 'Radius'));
        case _Shape.triangle:
          result = calculateTriangle(
            parseLength(_first.text, 'Side A'),
            parseLength(_second.text, 'Side B'),
            parseLength(_third.text, 'Side C'),
          );
      }
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

  String _number(double value) => value.toStringAsPrecision(10);

  @override
  Widget build(BuildContext context) {
    final firstLabel = switch (_shape) {
      _Shape.rectangle => 'Width',
      _Shape.circle => 'Radius',
      _Shape.triangle => 'Side A',
    };
    final formula = switch (_shape) {
      _Shape.rectangle =>
        'Area = width × height\nPerimeter = 2 × (width + height)',
      _Shape.circle => 'Area = π × radius²\nCircumference = 2 × π × radius',
      _Shape.triangle =>
        's = (a + b + c) ÷ 2\nArea = √(s × (s − a) × (s − b) × (s − c))\nPerimeter = a + b + c',
    };
    return FeaturePage(
      title: 'Geometry Calculator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Measure a shape',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Use the same unit for every length. Results show square units for area and units for perimeter.',
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<_Shape>(
            initialValue: _shape,
            decoration: const InputDecoration(labelText: 'Shape'),
            items: const [
              DropdownMenuItem(
                value: _Shape.rectangle,
                child: Text('Rectangle'),
              ),
              DropdownMenuItem(value: _Shape.circle, child: Text('Circle')),
              DropdownMenuItem(value: _Shape.triangle, child: Text('Triangle')),
            ],
            onChanged: (shape) {
              if (shape == null) return;
              setState(() {
                _shape = shape;
                _result = null;
                _error = null;
                _first.clear();
                _second.clear();
                _third.clear();
              });
            },
          ),
          const SizedBox(height: 12),
          Field(
            controller: _first,
            label: firstLabel,
            numeric: true,
            onChanged: _invalidate,
          ),
          if (_shape != _Shape.circle)
            Field(
              controller: _second,
              label: _shape == _Shape.rectangle ? 'Height' : 'Side B',
              numeric: true,
              onChanged: _invalidate,
            ),
          if (_shape == _Shape.triangle)
            Field(
              controller: _third,
              label: 'Side C',
              numeric: true,
              onChanged: _invalidate,
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Calculate'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            ResultCard(
              title: 'Area',
              value: '${_number(_result!.area)} square units',
            ),
            ResultCard(
              title: _shape == _Shape.circle ? 'Circumference' : 'Perimeter',
              value: '${_number(_result!.perimeter)} units',
            ),
          ],
          const SizedBox(height: 24),
          Text('Formula', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(formula),
          if (_shape == _Shape.triangle) ...[
            const SizedBox(height: 8),
            const Text(
              'Each side must be shorter than the sum of the other two. A flat triangle has no area and is rejected.',
            ),
          ],
        ],
      ),
    );
  }
}
