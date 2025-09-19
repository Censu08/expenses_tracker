import 'package:flutter/foundation.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';
import '../../core/errors/app_exceptions.dart';

class UserController {
  final UserRepository _userRepository;

  UserController({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  // Registrazione nuovo utente
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String surname,
    required DateTime birthdate,
  }) async {
    try {
      // Validazione input
      _validateRegistrationInput(
        email: email,
        password: password,
        name: name,
        surname: surname,
      );

      // Registra l'utente tramite repository
      final user = await _userRepository.registerUser(
        email: email.trim().toLowerCase(),
        password: password,
        name: name.trim(),
        surname: surname.trim(),
        birthdate: birthdate,
      );

      debugPrint('Utente registrato con successo: ${user.id}');
      return user;
    } catch (e) {
      debugPrint('Errore durante la registrazione: $e');
      rethrow;
    }
  }

  // Login utente
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Validazione input
      _validateLoginInput(email: email, password: password);

      // Effettua il login tramite repository
      final user = await _userRepository.loginUser(
        email: email.trim().toLowerCase(),
        password: password,
      );

      debugPrint('Login effettuato con successo: ${user.id}');
      return user;
    } catch (e) {
      debugPrint('Errore durante il login: $e');
      rethrow;
    }
  }

  // Login/Registrazione con Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final user = await _userRepository.signInWithGoogle();
      debugPrint('Accesso Google effettuato con successo: ${user.id}');
      return user;
    } catch (e) {
      debugPrint('Errore durante l\'accesso Google: $e');
      rethrow;
    }
  }

  // Logout utente
  Future<void> logoutUser() async {
    try {
      await _userRepository.logout();
      debugPrint('Logout effettuato con successo');
    } catch (e) {
      debugPrint('Errore durante il logout: $e');
      rethrow;
    }
  }

  // Recupera utente corrente
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        debugPrint('Utente corrente recuperato: ${user.id}');
      } else {
        debugPrint('Nessun utente autenticato');
      }
      return user;
    } catch (e) {
      debugPrint('Errore nel recupero dell\'utente corrente: $e');
      rethrow;
    }
  }

  // Aggiorna profilo utente
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? surname,
    DateTime? birthdate,
    String? email,
  }) async {
    try {
      // Validazione input se forniti
      if (name != null && name.trim().isEmpty) {
        throw const ValidationException('Il nome non può essere vuoto');
      }
      if (surname != null && surname.trim().isEmpty) {
        throw const ValidationException('Il cognome non può essere vuoto');
      }
      if (email != null && !_isValidEmail(email.trim())) {
        throw const ValidationException('Email non valida');
      }

      final updatedUser = await _userRepository.updateUserProfile(
        userId: userId,
        name: name?.trim(),
        surname: surname?.trim(),
        birthdate: birthdate,
        email: email?.trim().toLowerCase(),
      );

      debugPrint('Profilo aggiornato con successo: $userId');
      return updatedUser;
    } catch (e) {
      debugPrint('Errore nell\'aggiornamento del profilo: $e');
      rethrow;
    }
  }

  // Cambia password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Validazione password
      if (currentPassword.isEmpty) {
        throw const ValidationException('Password attuale richiesta');
      }
      if (!_isValidPassword(newPassword)) {
        throw const ValidationException(
          'La nuova password deve essere di almeno 6 caratteri',
        );
      }
      if (currentPassword == newPassword) {
        throw const ValidationException(
          'La nuova password deve essere diversa da quella attuale',
        );
      }

      await _userRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      debugPrint('Password cambiata con successo');
    } catch (e) {
      debugPrint('Errore nel cambio password: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (!_isValidEmail(email.trim())) {
        throw const ValidationException('Email non valida');
      }

      await _userRepository.resetPassword(email.trim().toLowerCase());
      debugPrint('Email di reset password inviata a: $email');
    } catch (e) {
      debugPrint('Errore nell\'invio email di reset: $e');
      rethrow;
    }
  }

  // Elimina account
  Future<void> deleteAccount(String password) async {
    try {
      if (password.isEmpty) {
        throw const ValidationException('Password richiesta per eliminare l\'account');
      }

      await _userRepository.deleteAccount(password);
      debugPrint('Account eliminato con successo');
    } catch (e) {
      debugPrint('Errore nell\'eliminazione dell\'account: $e');
      rethrow;
    }
  }

  // Verifica se l'utente è autenticato
  bool get isUserAuthenticated => _userRepository.isAuthenticated;

  // Stream dello stato di autenticazione
  Stream<bool> get authStateStream => _userRepository.authStateChanges
      .map((user) => user != null);

  // METODI DI VALIDAZIONE PRIVATI

  void _validateRegistrationInput({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) {
    if (email.trim().isEmpty) {
      throw const ValidationException('Email richiesta');
    }
    if (!_isValidEmail(email.trim())) {
      throw const ValidationException('Email non valida');
    }
    if (password.isEmpty) {
      throw const ValidationException('Password richiesta');
    }
    if (!_isValidPassword(password)) {
      throw const ValidationException('La password deve essere di almeno 6 caratteri');
    }
    if (name.trim().isEmpty) {
      throw const ValidationException('Nome richiesto');
    }
    if (surname.trim().isEmpty) {
      throw const ValidationException('Cognome richiesto');
    }
    if (name.trim().length < 2) {
      throw const ValidationException('Il nome deve essere di almeno 2 caratteri');
    }
    if (surname.trim().length < 2) {
      throw const ValidationException('Il cognome deve essere di almeno 2 caratteri');
    }
  }

  void _validateLoginInput({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty) {
      throw const ValidationException('Email richiesta');
    }
    if (!_isValidEmail(email.trim())) {
      throw const ValidationException('Email non valida');
    }
    if (password.isEmpty) {
      throw const ValidationException('Password richiesta');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }
}