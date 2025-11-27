import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  @HiveField(0)
  final int monthStartDate; // Day of month (e.g., 28)

  @HiveField(1)
  final int monthEndDate; // Day of month (e.g., 27)

  @HiveField(2)
  final String? googleSheetId;

  @HiveField(3)
  final double minRentIncome;

  @HiveField(4)
  final double minDailyExpense;

  @HiveField(5)
  final bool isDarkMode;

  AppSettings({
    this.monthStartDate = 1,
    this.monthEndDate = 31,
    this.googleSheetId,
    this.minRentIncome = 600.0,
    this.minDailyExpense = 500.0,
    this.isDarkMode = false,
  });
  
  AppSettings copyWith({
    int? monthStartDate,
    int? monthEndDate,
    String? googleSheetId,
    double? minRentIncome,
    double? minDailyExpense,
    bool? isDarkMode,
  }) {
    return AppSettings(
      monthStartDate: monthStartDate ?? this.monthStartDate,
      monthEndDate: monthEndDate ?? this.monthEndDate,
      googleSheetId: googleSheetId ?? this.googleSheetId,
      minRentIncome: minRentIncome ?? this.minRentIncome,
      minDailyExpense: minDailyExpense ?? this.minDailyExpense,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
