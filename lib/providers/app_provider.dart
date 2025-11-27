
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../models/settings_model.dart';
import '../services/hive_service.dart';


final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(HiveService.getSettings());

  Future<void> updateSettings(AppSettings newSettings) async {
    await HiveService.saveSettings(newSettings);
    state = newSettings;
  }
}

final transactionListProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super(HiveService.getAllTransactions());

  Future<void> addTransaction(Transaction transaction) async {
    await HiveService.addTransaction(transaction);
    state = [...state, transaction];
    
    // Attempt sync
    // In a real app, we'd have a background queue
    try {
      // await SheetsService.syncTransaction(transaction); 
      // Uncomment when credentials are set
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    await HiveService.deleteTransaction(id);
    state = state.where((t) => t.id != id).toList();
  }
  
  List<Transaction> getTransactionsForMonth(DateTime month, int startDay, int endDay) {
    // Calculate start and end dates for the custom month
    // Example: If month is Nov 2023 (passed as e.g. Nov 1), startDay is 28, endDay is 27
    // Cycle: Oct 28 to Nov 27
    
    // We assume 'month' represents the target billing month.
    // The cycle for "Month X" starts in "Month X-1" on startDay and ends in "Month X" on endDay.
    
    DateTime targetMonthEnd = DateTime(month.year, month.month, endDay);
    DateTime targetMonthStart = DateTime(month.year, month.month - 1, startDay);
    
    return state.where((t) {
      return t.date.isAfter(targetMonthStart.subtract(const Duration(seconds: 1))) && 
             t.date.isBefore(targetMonthEnd.add(const Duration(days: 1))); // Inclusive
    }).toList();
  }
}

final dashboardStatsProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionListProvider);
  double totalIncome = 0;
  double totalExpense = 0;
  
  for (var t in transactions) {
    if (t.type == TransactionType.income) {
      totalIncome += t.amount;
    } else {
      totalExpense += t.amount;
    }
  }
  
  return {
    'income': totalIncome,
    'expense': totalExpense,
    'balance': totalIncome - totalExpense,
  };
});
