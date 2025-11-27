import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _sheetIdController = TextEditingController();
  final _minRentController = TextEditingController();
  final _minDailyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _sheetIdController.text = settings.googleSheetId ?? '';
    _minRentController.text = settings.minRentIncome.toString();
    _minDailyController.text = settings.minDailyExpense.toString();
  }

  @override
  void dispose() {
    _sheetIdController.dispose();
    _minRentController.dispose();
    _minDailyController.dispose();
    super.dispose();
  }

  void _save() {
    final currentSettings = ref.read(settingsProvider);
    final newSettings = currentSettings.copyWith(
      googleSheetId: _sheetIdController.text.isEmpty ? null : _sheetIdController.text,
      minRentIncome: double.tryParse(_minRentController.text) ?? 600,
      minDailyExpense: double.tryParse(_minDailyController.text) ?? 500,
    );
    
    ref.read(settingsProvider.notifier).updateSettings(newSettings);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Google Sheets Sync', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _sheetIdController,
            decoration: const InputDecoration(
              labelText: 'Spreadsheet ID',
              border: OutlineInputBorder(),
              helperText: 'Enter the ID from your Google Sheet URL',
            ),
          ),
          const SizedBox(height: 24),
          
          const Text('Validation Limits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _minRentController,
            decoration: const InputDecoration(
              labelText: 'Minimum Rent Income (₹)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _minDailyController,
            decoration: const InputDecoration(
              labelText: 'Minimum Daily Expense (₹)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
