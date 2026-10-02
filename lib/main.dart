import 'package:flutter/material.dart';
import 'package:offline_foundation/offline_foundation.dart';
import 'package:percentage_calculator/module.dart';
import 'package:fraction_calculator/module.dart';
import 'package:geometry_calculator/module.dart';
import 'package:number_base/module.dart';
import 'package:unit_converter/module.dart';

void main() => runApp(const CalculatorHub());

class CalculatorHub extends StatelessWidget {
  const CalculatorHub({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Calculator Hub',
    debugShowCheckedModeBanner: false,
    theme: offlineTheme(Brightness.light),
    darkTheme: offlineTheme(Brightness.dark),
    home: const ToolCatalog(),
  );
}

class ToolCatalog extends StatelessWidget {
  const ToolCatalog({super.key});
  @override
  Widget build(BuildContext context) {
    final tools =
        <({String title, String description, IconData icon, Widget page})>[
          (
            title: 'Percentages',
            description: 'Of, change and reverse percentage',
            icon: Icons.percent,
            page: const PercentageCalculatorScreen(),
          ),
          (
            title: 'Fractions',
            description: 'Exact fraction arithmetic',
            icon: Icons.calculate_outlined,
            page: const FractionCalculatorScreen(),
          ),
          (
            title: 'Geometry',
            description: 'Areas and volumes with positive dimensions',
            icon: Icons.category_outlined,
            page: const GeometryCalculator(),
          ),
          (
            title: 'Number bases',
            description: 'Integers in bases 2 through 36',
            icon: Icons.numbers,
            page: const NumberBaseScreen(),
          ),
          (
            title: 'Unit conversion',
            description: 'Length, mass, temperature and volume',
            icon: Icons.straighten,
            page: const UnitConverterScreen(),
          ),
        ];
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator Hub')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Choose a tool. All calculations work offline.'),
                const SizedBox(height: 16),
                for (final tool in tools)
                  Card(
                    child: ListTile(
                      leading: Icon(tool.icon),
                      title: Text(tool.title),
                      subtitle: Text(tool.description),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => tool.page),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
