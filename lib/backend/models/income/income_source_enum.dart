// File: lib/backend/models/income_source_enum.dart

import 'package:flutter/material.dart';

/// Enum che rappresenta le diverse fonti di reddito
enum IncomeSource {
  salary,        // Stipendio
  freelance,     // Lavoro autonomo/Freelance
  business,      // Attività imprenditoriale
  investments,   // Investimenti (dividendi, interessi)
  rental,        // Affitti
  pension,       // Pensione
  bonus,         // Bonus/Premi
  sideHustle,    // Secondo lavoro/Side hustle
  gifts,         // Regali/Donazioni
  refunds,       // Rimborsi
  other,         // Altro
}

/// Extension per aggiungere metodi e proprietà all'enum IncomeSource
extension IncomeSourceExtension on IncomeSource {

  /// Nome visualizzato nell'UI
  String get displayName {
    switch (this) {
      case IncomeSource.salary:
        return 'Stipendio';
      case IncomeSource.freelance:
        return 'Freelance';
      case IncomeSource.business:
        return 'Business';
      case IncomeSource.investments:
        return 'Investimenti';
      case IncomeSource.rental:
        return 'Affitti';
      case IncomeSource.pension:
        return 'Pensione';
      case IncomeSource.bonus:
        return 'Bonus';
      case IncomeSource.sideHustle:
        return 'Side Hustle';
      case IncomeSource.gifts:
        return 'Regali';
      case IncomeSource.refunds:
        return 'Rimborsi';
      case IncomeSource.other:
        return 'Altro';
    }
  }

  /// Icona rappresentativa
  IconData get icon {
    switch (this) {
      case IncomeSource.salary:
        return Icons.account_balance_wallet;
      case IncomeSource.freelance:
        return Icons.laptop_mac;
      case IncomeSource.business:
        return Icons.business_center;
      case IncomeSource.investments:
        return Icons.trending_up;
      case IncomeSource.rental:
        return Icons.home;
      case IncomeSource.pension:
        return Icons.elderly;
      case IncomeSource.bonus:
        return Icons.card_giftcard;
      case IncomeSource.sideHustle:
        return Icons.work_outline;
      case IncomeSource.gifts:
        return Icons.redeem;
      case IncomeSource.refunds:
        return Icons.replay;
      case IncomeSource.other:
        return Icons.more_horiz;
    }
  }

  /// Colore associato
  Color get color {
    switch (this) {
      case IncomeSource.salary:
        return Colors.blue;
      case IncomeSource.freelance:
        return Colors.purple;
      case IncomeSource.business:
        return Colors.indigo;
      case IncomeSource.investments:
        return Colors.green;
      case IncomeSource.rental:
        return Colors.teal;
      case IncomeSource.pension:
        return Colors.blueGrey;
      case IncomeSource.bonus:
        return Colors.amber;
      case IncomeSource.sideHustle:
        return Colors.deepOrange;
      case IncomeSource.gifts:
        return Colors.pink;
      case IncomeSource.refunds:
        return Colors.cyan;
      case IncomeSource.other:
        return Colors.grey;
    }
  }

  /// Descrizione dettagliata
  String get description {
    switch (this) {
      case IncomeSource.salary:
        return 'Reddito da lavoro dipendente';
      case IncomeSource.freelance:
        return 'Compensi da lavoro autonomo';
      case IncomeSource.business:
        return 'Ricavi da attività imprenditoriale';
      case IncomeSource.investments:
        return 'Dividendi, interessi, capital gains';
      case IncomeSource.rental:
        return 'Canoni di locazione';
      case IncomeSource.pension:
        return 'Pensione o rendita';
      case IncomeSource.bonus:
        return 'Bonus, incentivi, premi';
      case IncomeSource.sideHustle:
        return 'Secondo lavoro o attività extra';
      case IncomeSource.gifts:
        return 'Regali in denaro o donazioni';
      case IncomeSource.refunds:
        return 'Rimborsi spese o restituzioni';
      case IncomeSource.other:
        return 'Altra tipologia di entrata';
    }
  }

  /// Serializzazione per database (salva il nome dell'enum)
  String toJson() => name;

  /// Deserializzazione da database
  static IncomeSource fromJson(String json) {
    return IncomeSource.values.firstWhere(
          (e) => e.name == json,
      orElse: () => IncomeSource.other,
    );
  }
}

/// Helper class con utility methods per IncomeSource
class IncomeSourceHelper {

  /// Lista di tutti i source disponibili
  static List<IncomeSource> getAllSources() {
    return IncomeSource.values;
  }

  /// Source predefinito (per backward compatibility con dati vecchi)
  static IncomeSource get defaultSource => IncomeSource.other;

  /// Raggruppa sources per tipo (utile per UI avanzate future)
  static Map<String, List<IncomeSource>> getGroupedSources() {
    return {
      'Lavoro': [
        IncomeSource.salary,
        IncomeSource.freelance,
        IncomeSource.business,
        IncomeSource.sideHustle,
      ],
      'Investimenti': [
        IncomeSource.investments,
        IncomeSource.rental,
      ],
      'Altro': [
        IncomeSource.pension,
        IncomeSource.bonus,
        IncomeSource.gifts,
        IncomeSource.refunds,
        IncomeSource.other,
      ],
    };
  }

  /// Ottieni source suggerito basato su categoria (per migration intelligente)
  static IncomeSource suggestSourceFromCategoryId(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'salary':
      case 'stipendio':
        return IncomeSource.salary;
      case 'freelance':
        return IncomeSource.freelance;
      case 'business':
        return IncomeSource.business;
      case 'investments':
      case 'investimenti':
        return IncomeSource.investments;
      case 'rental':
      case 'affitti':
        return IncomeSource.rental;
      case 'bonus':
        return IncomeSource.bonus;
      default:
        return IncomeSource.other;
    }
  }

  /// Statistiche: calcola diversification score (0-100)
  /// Più fonti diverse = score più alto
  static int calculateDiversificationScore(Map<IncomeSource, double> stats) {
    if (stats.isEmpty) return 0;

    final activeSources = stats.keys.length;
    final totalAmount = stats.values.fold(0.0, (sum, amount) => sum + amount);

    if (totalAmount == 0) return 0;

    // Calcola Herfindahl Index (concentrazione)
    double herfindahl = 0;
    for (final amount in stats.values) {
      final share = amount / totalAmount;
      herfindahl += share * share;
    }

    // Converti in score 0-100 (meno concentrato = più diversificato)
    final diversificationIndex = 1 - herfindahl;
    return (diversificationIndex * 100).round();
  }
}