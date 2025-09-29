import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum RecurrenceType {
  daily('daily', 'Giornaliera'),
  weekly('weekly', 'Settimanale'),
  monthly('monthly', 'Mensile'),
  yearly('yearly', 'Annuale'),
  custom('custom', 'Personalizzata');

  const RecurrenceType(this.value, this.displayName);

  final String value;
  final String displayName;

  static RecurrenceType fromString(String value) {
    return RecurrenceType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => RecurrenceType.monthly,
    );
  }

  @override
  String toString() => displayName;
}

enum NecessityLevel {
  low('low', 'Bassa', 1),
  medium('medium', 'Media', 2),
  high('high', 'Alta', 3),
  critical('critical', 'Critica', 4);

  const NecessityLevel(this.value, this.displayName, this.priority);

  final String value;
  final String displayName;
  final int priority;

  static NecessityLevel fromString(String value) {
    return NecessityLevel.values.firstWhere(
          (level) => level.value == value,
      orElse: () => NecessityLevel.medium,
    );
  }

  static NecessityLevel fromPriority(int priority) {
    return NecessityLevel.values.firstWhere(
          (level) => level.priority == priority,
      orElse: () => NecessityLevel.medium,
    );
  }

  @override
  String toString() => displayName;
}

class RecurrenceSettings extends Equatable {
  final RecurrenceType type;
  final DateTime startDate;
  final DateTime? endDate;
  final NecessityLevel necessityLevel;
  final int? customIntervalDays; // Per ricorrenze personalizzate

  const RecurrenceSettings({
    required this.type,
    required this.startDate,
    this.endDate,
    required this.necessityLevel,
    this.customIntervalDays,
  });

  factory RecurrenceSettings.fromJson(Map<String, dynamic> json) {
    return RecurrenceSettings(
      type: RecurrenceType.fromString(json['type'] as String),
      startDate: json['start_date'] is Timestamp
          ? (json['start_date'] as Timestamp).toDate()
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? (json['end_date'] is Timestamp
          ? (json['end_date'] as Timestamp).toDate()
          : DateTime.parse(json['end_date'] as String))
          : null,
      necessityLevel: NecessityLevel.fromString(json['necessity_level'] as String),
      customIntervalDays: json['custom_interval_days'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'necessity_level': necessityLevel.value,
      'custom_interval_days': customIntervalDays,
    };
  }

  RecurrenceSettings copyWith({
    RecurrenceType? type,
    DateTime? startDate,
    DateTime? endDate,
    NecessityLevel? necessityLevel,
    int? customIntervalDays,
  }) {
    return RecurrenceSettings(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      necessityLevel: necessityLevel ?? this.necessityLevel,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
    );
  }

  // Metodo per calcolare la prossima data di ricorrenza
  DateTime getNextOccurrence({DateTime? fromDate}) {
    final baseDate = fromDate ?? DateTime.now();

    switch (type) {
      case RecurrenceType.daily:
        return baseDate.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return baseDate.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
      case RecurrenceType.yearly:
        return DateTime(baseDate.year + 1, baseDate.month, baseDate.day);
      case RecurrenceType.custom:
        return baseDate.add(Duration(days: customIntervalDays ?? 30));
    }
  }

  // Metodo per verificare se la ricorrenza è ancora attiva
  bool get isActive {
    if (endDate == null) return true;
    return DateTime.now().isBefore(endDate!);
  }

  @override
  List<Object?> get props => [
    type,
    startDate,
    endDate,
    necessityLevel,
    customIntervalDays,
  ];
}