import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../core/utils/id_generator.dart';
import 'category_model.dart';
import 'recurrence_model.dart';

class ExpenseModel extends Equatable {
  final String id;
  final double amount;
  final String description;
  final CategoryModel category;
  final DateTime createdAt;
  final DateTime expenseDate;
  final bool isRecurring;
  final RecurrenceSettings? recurrenceSettings;
  final String userId; // Per collegare all'utente che ha creato la spesa

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.expenseDate,
    required this.isRecurring,
    this.recurrenceSettings,
    required this.userId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      expenseDate: (json['expense_date'] as Timestamp).toDate(),
      isRecurring: json['is_recurring'] as bool,
      recurrenceSettings: json['recurrence_settings'] != null
          ? RecurrenceSettings.fromJson(json['recurrence_settings'] as Map<String, dynamic>)
          : null,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category.toJson(),
      'created_at': Timestamp.fromDate(createdAt),
      'expense_date': Timestamp.fromDate(expenseDate),
      'is_recurring': isRecurring,
      'recurrence_settings': recurrenceSettings?.toJson(),
      'user_id': userId,
    };
  }

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? description,
    CategoryModel? category,
    DateTime? createdAt,
    DateTime? expenseDate,
    bool? isRecurring,
    RecurrenceSettings? recurrenceSettings,
    String? userId,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      expenseDate: expenseDate ?? this.expenseDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceSettings: recurrenceSettings ?? this.recurrenceSettings,
      userId: userId ?? this.userId,
    );
  }

  // Getter per formattare l'importo come stringa
  String get formattedAmount {
    return '€ ${amount.toStringAsFixed(2)}';
  }

  // Getter per formattare l'importo con segno negativo (tipico per le spese)
  String get formattedAmountWithSign {
    return '-€ ${amount.toStringAsFixed(2)}';
  }

  // Getter per verificare se la spesa è scaduta (per ricorrenti)
  bool get isExpired {
    if (!isRecurring || recurrenceSettings == null) return false;
    return !recurrenceSettings!.isActive;
  }

  // Getter per ottenere la prossima data di ricorrenza
  DateTime? get nextOccurrence {
    if (!isRecurring || recurrenceSettings == null) return null;
    return recurrenceSettings!.getNextOccurrence(fromDate: expenseDate);
  }

  // Metodo per creare una nuova istanza per la prossima ricorrenza
  ExpenseModel? createNextRecurrence() {
    if (!isRecurring || recurrenceSettings == null || isExpired) {
      return null;
    }

    final nextDate = nextOccurrence;
    if (nextDate == null) return null;

    return copyWith(
      id: _generateId(), // Nuovo ID per la nuova istanza
      expenseDate: nextDate,
      createdAt: DateTime.now(),
    );
  }

  // Metodo privato per generare un nuovo ID
  String _generateId() {
    return IdGenerator.generateExpenseId();
  }

  // Metodo per verificare se la spesa appartiene a un determinato periodo
  bool isInPeriod({required DateTime start, required DateTime end}) {
    return expenseDate.isAfter(start.subtract(const Duration(days: 1))) &&
        expenseDate.isBefore(end.add(const Duration(days: 1)));
  }

  // Metodo per verificare se la spesa appartiene al mese corrente
  bool get isThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return isInPeriod(start: startOfMonth, end: endOfMonth);
  }

  // Metodo per verificare se la spesa appartiene alla settimana corrente
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isInPeriod(
      start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      end: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    );
  }

  // Metodo per verificare se è una spesa importante (basato sul livello di necessità)
  bool get isHighPriority {
    if (!isRecurring || recurrenceSettings == null) return false;
    return recurrenceSettings!.necessityLevel == NecessityLevel.high ||
        recurrenceSettings!.necessityLevel == NecessityLevel.critical;
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    category,
    createdAt,
    expenseDate,
    isRecurring,
    recurrenceSettings,
    userId,
  ];

  @override
  String toString() {
    return 'ExpenseModel(id: $id, amount: $amount, description: $description, '
        'category: ${category.description}, expenseDate: $expenseDate, '
        'isRecurring: $isRecurring)';
  }
}