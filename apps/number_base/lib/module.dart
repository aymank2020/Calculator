import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offline_foundation/offline_foundation.dart';

import 'logic.dart';

final appDefinition = AppDefinition(
  id: 'number_base',
  title: 'Number Base',
  description:
      'Convert signed integers between binary, octal, decimal, and hex.',
  icon: Icons.calculate_outlined,
  builder: () => const NumberBaseScreen(),
);

class NumberBaseScreen extends StatefulWidget {
  const NumberBaseScreen({super.key});

  @override
  State<NumberBaseScreen> createState() => _NumberBaseScreenState();
}

class _NumberBaseScreenState extends State<NumberBaseScreen> {
  final _input = TextEditingController(text: '255');
  IntegerBase _source = IntegerBase.decimal;
  Map<IntegerBase, String> _outputs = convertInteger(
    '255',
    IntegerBase.decimal,
  );
  String? _error;

  void _convert() {
    setState(() {
      try {
        _outputs = convertInteger(_input.text, _source);
        _error = null;
      } on FormatException catch (error) {
        _outputs = {};
        _error = error.message;
      }
    });
  }

  Future<void> _copy(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access the clipboard.')),
      );
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeaturePage(
      title: 'Number Base',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Convert integers of any size',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose the input base. An optional + or - sign is supported. '
            'Enter digits without prefixes such as 0x or 0b. '
            'Hexadecimal letters may be uppercase or lowercase.',
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<IntegerBase>(
            initialValue: _source,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Input base'),
            items: [
              for (final base in IntegerBase.values)
                DropdownMenuItem(
                  value: base,
                  child: Text(
                    '${base.label} (base ${base.radix})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (base) {
              if (base == null) return;
              _source = base;
              _convert();
            },
          ),
          const SizedBox(height: 16),
          Field(
            controller: _input,
            label: 'Integer',
            hint: 'For example: -255',
            maxLines: 3,
            onChanged: (_) => _convert(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          for (final base in IntegerBase.values)
            if (_outputs[base] case final String value)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${base.label} · base ${base.radix}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy ${base.label.toLowerCase()}',
                            onPressed: () => _copy(value),
                            icon: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SelectableText(
                          value,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 8),
          const Text(
            'Negative outputs use a leading minus sign, not two’s complement. '
            'Conversions stay on this device.',
          ),
        ],
      ),
    );
  }
}
