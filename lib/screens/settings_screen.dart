import 'package:flutter/material.dart';

import '../settings.dart' as settings;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: settings.url,
                keyboardType: TextInputType.url,
                onChanged: (txt) => settings.url = txt,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
              TextFormField(
                initialValue: settings.maxRowsPerPage.toString(),
                keyboardType: const TextInputType.numberWithOptions(),
                onChanged: (txt) {
                  final maxRowsPerPage = int.tryParse(txt) ?? 1;
                  settings.maxRowsPerPage = maxRowsPerPage <= 0 ? 1 : maxRowsPerPage;
                },
                decoration: const InputDecoration(labelText: 'Number of rows to show in the result table'),
              ),
              TextFormField(
                initialValue: settings.iterations.toString(),
                keyboardType: const TextInputType.numberWithOptions(),
                onChanged: (txt) {
                  final iterations = int.tryParse(txt) ?? 1;
                  settings.iterations = iterations <= 0 ? 1 : iterations;
                },
                decoration: const InputDecoration(labelText: 'Iterations'),
              ),
              TextFormField(
                initialValue: settings.waitDuration.inMilliseconds.toString(),
                keyboardType: const TextInputType.numberWithOptions(),
                onChanged: (txt) {
                  final waitDuration = int.tryParse(txt) ?? 500;
                  settings.waitDuration = Duration(milliseconds: waitDuration <= 0 ? 500 : waitDuration);
                },
                decoration: const InputDecoration(labelText: 'Delay duration between iterations (ms)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
