import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/transaction_model.dart';
import 'add_entry_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final transactions = ref.watch(transactionListProvider);
    
    // Sort transactions by date descending
    final recentTransactions = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCard(context, stats),
            const SizedBox(height: 24),
            
            // Recent Transactions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full history
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Transactions List
            if (recentTransactions.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No transactions yet'),
              ))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length > 5 ? 5 : recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: transaction.type == TransactionType.income
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        child: Icon(
                          transaction.type == TransactionType.income
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: transaction.type == TransactionType.income
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      title: Text(transaction.category.name.toUpperCase()),
                      subtitle: Text(DateFormat('MMM d, y').format(transaction.date)),
                      trailing: Text(
                        '${transaction.type == TransactionType.income ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: transaction.type == TransactionType.income
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEntryScreen()));
        },
        label: const Text('Add Entry'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Map<String, double> stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.tertiary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${stats['balance']!.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Income', stats['income']!, Icons.arrow_downward, Colors.greenAccent),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildStatItem('Expense', stats['expense']!, Icons.arrow_upward, Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double amount, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
