import 'package:gsheets/gsheets.dart';
import '../models/transaction_model.dart';

class SheetsService {
  // Placeholder for credentials - in a real app, these should be securely stored or input by the user
  // For this implementation, we'll assume the user provides credentials via settings or a file
  static GSheets? _gsheets;
  static Worksheet? _worksheet;

  static Future<void> init(String credentialsJson, String spreadsheetId) async {
    try {
      _gsheets = GSheets(credentialsJson);
      final spreadsheet = await _gsheets!.spreadsheet(spreadsheetId);
      _worksheet = spreadsheet.worksheetByTitle('Transactions');
      
      if (_worksheet == null) {
        _worksheet = await spreadsheet.addWorksheet('Transactions');
        // Add headers
        await _worksheet!.values.insertRow(1, [
          'ID',
          'Date',
          'Type',
          'Category',
          'Amount',
          'Mode',
          'Description',
          'Cash Amount',
          'Online Amount'
        ]);
      }
    } catch (e) {
      print('Error initializing Sheets: $e');
      rethrow;
    }
  }

  static Future<void> syncTransaction(Transaction transaction) async {
    if (_worksheet == null) return;

    try {
      // Check if row exists (by ID) - simplistic approach
      // In a robust app, we'd need a better way to map IDs to rows
      // For now, we'll just append new transactions
      
      await _worksheet!.values.appendRow([
        transaction.id,
        transaction.date.toIso8601String(),
        transaction.type.toString(),
        transaction.category.toString(),
        transaction.amount,
        transaction.mode.toString(),
        transaction.description,
        transaction.cashAmount ?? 0,
        transaction.onlineAmount ?? 0,
      ]);
    } catch (e) {
      print('Error syncing transaction: $e');
      rethrow;
    }
  }
}
