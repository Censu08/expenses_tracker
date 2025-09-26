// File: lib/core/utils/id_generator.dart

import 'dart:math';

class IdGenerator {
  static final Random _random = Random();
  static const String _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  /// Genera un ID univoco simil-UUID v4
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomPart = _generateRandomString(8);
    return '${timestamp}_$randomPart';
  }

  /// Genera un UUID v4 semplificato
  static String generateUuidV4() {
    // Formato: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    // dove x è qualsiasi cifra esadecimale e y è 8, 9, A, o B

    String generateHex(int length) {
      const hexChars = '0123456789abcdef';
      return List.generate(length, (_) => hexChars[_random.nextInt(16)]).join();
    }

    String generateY() {
      const yChars = '89ab';
      return yChars[_random.nextInt(4)];
    }

    return '${generateHex(8)}-${generateHex(4)}-4${generateHex(3)}-${generateY()}${generateHex(3)}-${generateHex(12)}';
  }

  /// Genera una stringa casuale della lunghezza specificata
  static String _generateRandomString(int length) {
    return List.generate(length, (_) => _chars[_random.nextInt(_chars.length)]).join();
  }

  /// Genera un ID per le transazioni con prefisso
  static String generateTransactionId({String prefix = 'txn'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = _generateRandomString(6).toLowerCase();
    return '${prefix}_${timestamp}_$randomPart';
  }

  /// Genera un ID per le categorie con prefisso
  static String generateCategoryId({String prefix = 'cat'}) {
    final randomPart = _generateRandomString(12).toLowerCase();
    return '${prefix}_$randomPart';
  }

  /// Genera un ID per entrate con prefisso
  static String generateIncomeId() {
    return generateTransactionId(prefix: 'inc');
  }

  /// Genera un ID per spese con prefisso
  static String generateExpenseId() {
    return generateTransactionId(prefix: 'exp');
  }
}

/// Extension per aggiungere funzionalità di generazione ID ai modelli
extension ModelIdGenerator on Object {
  /// Genera un nuovo ID per il modello corrente
  String generateModelId() {
    final className = runtimeType.toString().toLowerCase();
    if (className.contains('income')) {
      return IdGenerator.generateIncomeId();
    } else if (className.contains('expense')) {
      return IdGenerator.generateExpenseId();
    } else if (className.contains('category')) {
      return IdGenerator.generateCategoryId();
    }
    return IdGenerator.generateId();
  }
}