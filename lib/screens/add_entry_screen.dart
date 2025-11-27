import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../providers/app_provider.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({super.key});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.daily;
  PaymentMode _mode = PaymentMode.cash;
  
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cashAmountController = TextEditingController();
  final _onlineAmountController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _cashAmountController.dispose();
    _onlineAmountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final settings = ref.read(settingsProvider);
      double amount = double.parse(_amountController.text);
      
      // Validations
      if (_type == TransactionType.income && _category == TransactionCategory.rent) {
        if (amount < settings.minRentIncome) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rent Income cannot be less than ₹${settings.minRentIncome}')),
          );
          return;
        }
      }
      
      if (_type == TransactionType.expense && _category == TransactionCategory.daily) {
        // Just a warning or strict validation? Requirements said "Minimum default daily expenses = ₹500"
        // Assuming this means we should warn if it's unusually low, or maybe it's a target?
        // Let's treat it as a validation for now based on "Minimum default" phrasing.
        if (amount < settings.minDailyExpense) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Daily Expense is typically at least ₹${settings.minDailyExpense}. Proceeding anyway.')),
          );
          // We allow it but warn
        }
      }

      double? cashAmt;
      double? onlineAmt;

      if (_mode == PaymentMode.both) {
        cashAmt = double.tryParse(_cashAmountController.text);
        onlineAmt = double.tryParse(_onlineAmountController.text);
        
        if (cashAmt == null || onlineAmt == null || (cashAmt + onlineAmt != amount)) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Split amounts must equal total amount')),
          );
          return;
        }
      }

      final transaction = Transaction(
        id: const Uuid().v4(),
        date: _selectedDate,
        type: _type,
        category: _category,
        amount: amount,
        mode: _mode,
        description: _descriptionController.text,
        cashAmount: cashAmt,
        onlineAmount: onlineAmt,
      );

      ref.read(transactionListProvider.notifier).addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type Selector
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.arrow_downward)),
                ButtonSegment(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.arrow_upward)),
              ],
              selected: {_type},
              onSelectionChanged: (Set<TransactionType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                  // Reset category based on type
                  if (_type == TransactionType.income) {
                    _category = TransactionCategory.rent;
                  } else {
                    _category = TransactionCategory.daily;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<TransactionCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: TransactionCategory.values.map((cat) {
                // Filter categories based on type (simplistic logic for now)
                if (_type == TransactionType.income && cat == TransactionCategory.daily) return null; // Daily is usually expense
                // Adjust as needed
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name.toUpperCase()),
                );
              }).whereType<DropdownMenuItem<TransactionCategory>>().toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),

            // Date Picker
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMM d, y').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.grey)),
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter amount';
                if (double.tryParse(val) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Payment Mode
            DropdownButtonFormField<PaymentMode>(
              value: _mode,
              decoration: const InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder()),
              items: PaymentMode.values.map((mode) {
                return DropdownMenuItem(value: mode, child: Text(mode.name.toUpperCase()));
              }).toList(),
              onChanged: (val) => setState(() => _mode = val!),
            ),
            const SizedBox(height: 16),

            // Split Amount Fields (if Both)
            if (_mode == PaymentMode.both) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cashAmountController,
                      decoration: const InputDecoration(labelText: 'Cash Amount', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _onlineAmountController,
                      decoration: const InputDecoration(labelText: 'Online Amount', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _submit,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
