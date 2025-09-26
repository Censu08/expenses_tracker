import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../core/utils/id_generator.dart';
import 'category_model.dart';
import 'recurrence_model.dart';

class IncomeModel extends Equatable {
  final String id;
  final double amount;
  final String description;
  final CategoryModel category;
  final DateTime createdAt;
  final DateTime incomeDate;
  final bool isRecurring;
  final RecurrenceSettings? recurrenceSettings;
  final String userId; // Per collegare all'utente che ha creato l'entrata

  const IncomeModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.incomeDate,
    required this.isRecurring,
    this.recurrenceSettings,
    required this.userId,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      incomeDate: (json['income_date'] as Timestamp).toDate(),
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
      'income_date': Timestamp.fromDate(incomeDate),
      'is_recurring': isRecurring,
      'recurrence_settings': recurrenceSettings?.toJson(),
      'user_id': userId,
    };
  }

  IncomeModel copyWith({
    String? id,
    double? amount,
    String? description,
    CategoryModel? category,
    DateTime? createdAt,
    DateTime? incomeDate,
    bool? isRecurring,
    RecurrenceSettings? recurrenceSettings,
    String? userId,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      incomeDate: incomeDate ?? this.incomeDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceSettings: recurrenceSettings ?? this.recurrenceSettings,
      userId: userId ?? this.userId,
    );
  }

  // Getter per formattare l'importo come stringa
  String get formattedAmount {
    return '€ ${amount.toStringAsFixed(2)}';
  }

  // Getter per verificare se l'entrata è scaduta (per ricorrenti)
  bool get isExpired {
    if (!isRecurring || recurrenceSettings == null) return false;
    return !recurrenceSettings!.isActive;
  }

  // Getter per ottenere la prossima data di ricorrenza
  DateTime? get nextOccurrence {
    if (!isRecurring || recurrenceSettings == null) return null;
    return recurrenceSettings!.getNextOccurrence(fromDate: incomeDate);
  }

  // Metodo per creare una nuova istanza per la prossima ricorrenza
  IncomeModel? createNextRecurrence() {
    if (!isRecurring || recurrenceSettings == null || isExpired) {
      return null;
    }

    final nextDate = nextOccurrence;
    if (nextDate == null) return null;

    return copyWith(
      id: _generateId(), // Nuovo ID per la nuova istanza
      incomeDate: nextDate,
      createdAt: DateTime.now(),
    );
  }

  // Metodo privato per generare un nuovo ID
  String _generateId() {
    return IdGenerator.generateIncomeId();
  }

  // Metodo per verificare se l'entrata appartiene a un determinato periodo
  bool isInPeriod({required DateTime start, required DateTime end}) {
    return incomeDate.isAfter(start.subtract(const Duration(days: 1))) &&
        incomeDate.isBefore(end.add(const Duration(days: 1)));
  }

  // Metodo per verificare se l'entrata appartiene al mese corrente
  bool get isThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return isInPeriod(start: startOfMonth, end: endOfMonth);
  }

  // Metodo per verificare se l'entrata appartiene alla settimana corrente
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isInPeriod(
      start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      end: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    category,
    createdAt,
    incomeDate,
    isRecurring,
    recurrenceSettings,
    userId,
  ];

  @override
  String toString() {
    return 'IncomeModel(id: $id, amount: $amount, description: $description, '
        'category: ${category.description}, incomeDate: $incomeDate, '
        'isRecurring: $isRecurring)';
  }
}