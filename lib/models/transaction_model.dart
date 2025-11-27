import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
enum TransactionCategory {
  @HiveField(0)
  rent,
  @HiveField(1)
  daily,
  @HiveField(2)
  other,
}

@HiveType(typeId: 2)
enum PaymentMode {
  @HiveField(0)
  cash,
  @HiveField(1)
  online,
  @HiveField(2)
  both,
}

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final TransactionCategory category;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final PaymentMode mode;

  @HiveField(6)
  final String description;

  @HiveField(7)
  final bool isSynced;

  @HiveField(8)
  final double? cashAmount; // For split payments

  @HiveField(9)
  final double? onlineAmount; // For split payments

  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    required this.mode,
    required this.description,
    this.isSynced = false,
    this.cashAmount,
    this.onlineAmount,
  });
}
