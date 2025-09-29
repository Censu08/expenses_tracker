import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  late final GoogleSignIn _googleSignIn;

  UserRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    // AGGIUNGI QUESTO BLOCCO NEL COSTRUTTORE
    final clientId = dotenv.env['GOOGLE_CLIENT_ID'];

    if (clientId == null || clientId.isEmpty) {
      throw Exception(
          'GOOGLE_CLIENT_ID non trovato nel file .env. '
              'Assicurati di aver creato il file .env e di aver aggiunto la chiave GOOGLE_CLIENT_ID'
      );
    }

    _googleSignIn = GoogleSignIn(
      clientId: clientId,
      scopes: [
        'email',
        'profile',
      ],
    );
  }

  // Registrazione nuovo utente
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String surname,
    required DateTime birthdate,
  }) async {
    try {
      // 1. Crea account Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Errore durante la creazione dell\'account');
      }

      // 2. Crea il modello utente
      final now = DateTime.now();
      final userModel = UserModel(
        id: credential.user!.uid,
        name: name,
        surname: surname,
        birthdate: birthdate,
        email: email,
        createdAt: now,
        active: true,
        lastModified: now,
      );

      // 3. Salva i dati utente in Firestore
      await _saveUserToDatabase(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Errore durante la registrazione: $e');
    }
  }

  // Login utente
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Autentica con Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Errore durante il login');
      }

      // 2. Recupera i dati utente dal database
      final userModel = await getUserById(credential.user!.uid);

      if (userModel == null) {
        throw Exception('Dati utente non trovati');
      }

      if (!userModel.active) {
        throw Exception('Account disattivato');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Errore durante il login: $e');
    }
  }

  // Login con Google SSO
  Future<UserModel> signInWithGoogle() async {
    try {
      // 1. Avvia il flusso di autenticazione Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Accesso Google annullato');
      }

      // 2. Ottieni i dettagli di autenticazione
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Crea le credenziali Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Accedi a Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Errore durante l\'autenticazione con Google');
      }

      final firebaseUser = userCredential.user!;

      // 5. Verifica se l'utente esiste già nel database
      UserModel? existingUser = await getUserById(firebaseUser.uid);

      if (existingUser != null) {
        // Utente esistente - aggiorna last modified
        final updatedUser = existingUser.copyWith(
          lastModified: DateTime.now(),
        );
        await _updateUserInDatabase(updatedUser);
        return updatedUser;
      } else {
        // Nuovo utente - crea il profilo INCOMPLETO
        final names = (firebaseUser.displayName ?? '').split(' ');
        final firstName = names.isNotEmpty ? names.first : '';
        final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

        final now = DateTime.now();
        final newUser = UserModel(
          id: firebaseUser.uid,
          name: firstName.isNotEmpty ? firstName : 'Nome',
          surname: lastName.isNotEmpty ? lastName : 'Cognome',
          birthdate: null,  // NON impostare la data di nascita
          email: firebaseUser.email ?? '',
          createdAt: now,
          active: true,
          lastModified: now,
          profileComplete: false,  // Profilo NON completo
        );

        await _saveUserToDatabase(newUser);
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Errore durante l\'accesso con Google: $e');
    }
  }

  // Logout utente
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Errore durante il logout: $e');
    }
  }

  // Recupera utente corrente
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      return await getUserById(currentUser.uid);
    } catch (e) {
      throw Exception('Errore nel recupero dell\'utente corrente: $e');
    }
  }

  // Recupera utente per ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Errore nel recupero dell\'utente: $e');
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
      final currentUser = await getUserById(userId);
      if (currentUser == null) {
        throw Exception('Utente non trovato');
      }

      // Aggiorna email in Firebase Auth se necessario
      if (email != null && email != currentUser.email) {
        await _auth.currentUser?.verifyBeforeUpdateEmail(email);
      }

      // Crea il modello aggiornato
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        surname: surname ?? currentUser.surname,
        birthdate: birthdate ?? currentUser.birthdate,
        email: email ?? currentUser.email,
        lastModified: DateTime.now(),
      );

      // Aggiorna nel database
      await _updateUserInDatabase(updatedUser);

      return updatedUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Errore nell\'aggiornamento del profilo: $e');
    }
  }

  // Cambia password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Nessun utente autenticato');
      }

      // Riautentica l'utente
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Cambia la password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Errore nel cambio password: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Errore nell\'invio email di reset: $e');
    }
  }

  // Elimina account
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Nessun utente autenticato');
      }

      // Riautentica l'utente
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Elimina dal database
      await _deleteUserFromDatabase(user.uid);

      // Elimina da Firebase Auth
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Errore nell\'eliminazione dell\'account: $e');
    }
  }

  // Completa il profilo dopo Google Sign-In
  Future<UserModel> completeBirthdate({
    required String userId,
    required DateTime birthdate,
  }) async {
    try {
      final currentUser = await getUserById(userId);
      if (currentUser == null) {
        throw Exception('Utente non trovato');
      }

      final updatedUser = currentUser.copyWith(
        birthdate: birthdate,
        profileComplete: true,
        lastModified: DateTime.now(),
      );

      await _updateUserInDatabase(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Errore nel completamento del profilo: $e');
    }
  }

  // Verifica se l'utente è autenticato
  bool get isAuthenticated => _auth.currentUser != null;

  // Stream dello stato di autenticazione
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // METODI PRIVATI

  Future<void> _saveUserToDatabase(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Errore nel salvataggio dell\'utente nel database: $e');
    }
  }

  Future<void> _updateUserInDatabase(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Errore nell\'aggiornamento dell\'utente nel database: $e');
    }
  }

  Future<void> _deleteUserFromDatabase(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Errore nell\'eliminazione dell\'utente dal database: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La password è troppo debole';
      case 'email-already-in-use':
        return 'Email già registrata';
      case 'invalid-email':
        return 'Email non valida';
      case 'user-not-found':
        return 'Utente non trovato';
      case 'wrong-password':
        return 'Password errata';
      case 'user-disabled':
        return 'Account disabilitato';
      case 'too-many-requests':
        return 'Troppi tentativi. Riprova più tardi';
      case 'requires-recent-login':
        return 'Operazione sensibile. Effettua nuovamente il login';
      default:
        return 'Errore di autenticazione: ${e.message}';
    }
  }
}