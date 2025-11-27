import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/settings_model.dart';

class HiveService {
  static const String _transactionBoxName = 'transactions';
  static const String _settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionCategoryAdapter());
    Hive.registerAdapter(PaymentModeAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    await Hive.openBox<Transaction>(_transactionBoxName);
    await Hive.openBox<AppSettings>(_settingsBoxName);
  }

  static Box<Transaction> get transactionBox => Hive.box<Transaction>(_transactionBoxName);
  static Box<AppSettings> get settingsBox => Hive.box<AppSettings>(_settingsBoxName);

  // Transactions
  static Future<void> addTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await transaction.save();
  }

  static Future<void> deleteTransaction(String id) async {
    await transactionBox.delete(id);
  }

  static List<Transaction> getAllTransactions() {
    return transactionBox.values.toList();
  }

  // Settings
  static AppSettings getSettings() {
    if (settingsBox.isEmpty) {
      return AppSettings();
    }
    return settingsBox.getAt(0)!;
  }

  static Future<void> saveSettings(AppSettings settings) async {
    if (settingsBox.isEmpty) {
      await settingsBox.add(settings);
    } else {
      await settingsBox.putAt(0, settings);
    }
  }
}
