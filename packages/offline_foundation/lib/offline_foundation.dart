library;

import 'package:flutter/material.dart';

class AppDefinition {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Widget Function() builder;
  const AppDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });
}

ThemeData offlineTheme(Brightness brightness) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff23675f),
    brightness: brightness,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
  cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(vertical: 8)),
);

void runOfflineApp(AppDefinition definition) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: definition.title,
      debugShowCheckedModeBanner: false,
      theme: offlineTheme(Brightness.light),
      darkTheme: offlineTheme(Brightness.dark),
      home: definition.builder(),
    ),
  );
}

class FeaturePage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  const FeaturePage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool numeric;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  const Field({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.numeric = false,
    this.maxLines = 1,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
      maxLines: maxLines,
      onChanged: onChanged,
    ),
  );
}

class ResultCard extends StatelessWidget {
  final String title;
  final String value;
  const ResultCard({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SelectableText(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    ),
  );
}
