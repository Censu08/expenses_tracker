import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../category_model.dart';
import '../recurrence_model.dart';
import 'income_source_enum.dart'; // ⬅️ NUOVO IMPORT

class IncomeModel extends Equatable {
  final String id;
  final double amount;
  final String description;
  final DateTime createdAt;
  final DateTime incomeDate;
  final bool isRecurring;
  final RecurrenceSettings? recurrenceSettings;
  final String userId;
  final IncomeSource source; // ⬅️ NUOVO CAMPO

  const IncomeModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.incomeDate,
    required this.isRecurring,
    this.recurrenceSettings,
    required this.userId,
    required this.source, // ⬅️ NUOVO PARAMETRO REQUIRED
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      incomeDate: (json['income_date'] as Timestamp).toDate(),
      isRecurring: json['is_recurring'] as bool,
      recurrenceSettings: json['recurrence_settings'] != null
          ? RecurrenceSettings.fromJson(json['recurrence_settings'] as Map<String, dynamic>)
          : null,
      userId: json['user_id'] as String,
      // ⬅️ NUOVO: Deserializzazione source con fallback per dati vecchi
      source: json['source'] != null
          ? IncomeSourceExtension.fromJson(json['source'] as String)
          : IncomeSource.other, // Default per backward compatibility
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'created_at': Timestamp.fromDate(createdAt),
      'income_date': Timestamp.fromDate(incomeDate),
      'is_recurring': isRecurring,
      'recurrence_settings': recurrenceSettings?.toJson(),
      'user_id': userId,
      'source': source.toJson(), // ⬅️ NUOVO: Serializzazione source
    };
  }

  IncomeModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? createdAt,
    DateTime? incomeDate,
    bool? isRecurring,
    RecurrenceSettings? recurrenceSettings,
    String? userId,
    IncomeSource? source, // ⬅️ NUOVO PARAMETRO
  }) {
    return IncomeModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      incomeDate: incomeDate ?? this.incomeDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceSettings: recurrenceSettings ?? this.recurrenceSettings,
      userId: userId ?? this.userId,
      source: source ?? this.source, // ⬅️ NUOVO
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    createdAt,
    incomeDate,
    isRecurring,
    recurrenceSettings,
    userId,
    source, // ⬅️ AGGIUNTO a props per Equatable
  ];

  // HELPER METHODS

  /// Verifica se la ricorrenza è ancora valida (non scaduta)
  bool get isExpired {
    if (!isRecurring || recurrenceSettings == null) {
      return false;
    }

    final endDate = recurrenceSettings!.endDate;
    if (endDate == null) {
      return false; // Nessuna data di fine = mai scaduto
    }

    return DateTime.now().isAfter(endDate);
  }

  /// Ottieni la prossima data di entrata per le ricorrenze
  DateTime? get nextOccurrence {
    if (!isRecurring || recurrenceSettings == null) {
      return null;
    }

    if (isExpired) {
      return null;
    }

    return recurrenceSettings!.getNextOccurrence(fromDate: incomeDate);
  }

  /// Formatta l'importo con simbolo valuta
  String get formattedAmount {
    return '€${amount.toStringAsFixed(2)}';
  }

  /// Ottieni una descrizione leggibile del source
  String get sourceDisplayName => source.displayName;

  /// Verifica se questa è un'entrata "importante" (stipendio, business, etc)
  bool get isMainIncomeSource {
    return source == IncomeSource.salary ||
        source == IncomeSource.business ||
        source == IncomeSource.freelance;
  }
}