import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import '../../core/errors/app_exceptions.dart';

// EVENTI
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class RegisterUserEvent extends UserEvent {
  final String email;
  final String password;
  final String name;
  final String surname;
  final DateTime birthdate;

  const RegisterUserEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.surname,
    required this.birthdate,
  });

  @override
  List<Object?> get props => [email, password, name, surname, birthdate];
}

class LoginUserEvent extends UserEvent {
  final String email;
  final String password;

  const LoginUserEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LogoutUserEvent extends UserEvent {
  const LogoutUserEvent();
}

class LoadCurrentUserEvent extends UserEvent {
  const LoadCurrentUserEvent();
}

class UpdateUserProfileEvent extends UserEvent {
  final String? name;
  final String? surname;
  final DateTime? birthdate;
  final String? email;

  const UpdateUserProfileEvent({
    this.name,
    this.surname,
    this.birthdate,
    this.email,
  });

  @override
  List<Object?> get props => [name, surname, birthdate, email];
}

class ChangePasswordEvent extends UserEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ResetPasswordEvent extends UserEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class DeleteAccountEvent extends UserEvent {
  final String password;

  const DeleteAccountEvent({required this.password});

  @override
  List<Object?> get props => [password];
}

class CheckAuthStatusEvent extends UserEvent {
  const CheckAuthStatusEvent();
}

class GoogleSignInEvent extends UserEvent {
  const GoogleSignInEvent();
}

class CompleteBirthdateEvent extends UserEvent {
  final String userId;
  final DateTime birthdate;

  const CompleteBirthdateEvent({
    required this.userId,
    required this.birthdate,
  });

  @override
  List<Object?> get props => [userId, birthdate];
}

// STATI
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserAuthenticated extends UserState {
  final UserModel user;

  const UserAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserUnauthenticated extends UserState {
  const UserUnauthenticated();
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserRegistrationSuccess extends UserState {
  final UserModel user;

  const UserRegistrationSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserLoginSuccess extends UserState {
  final UserModel user;

  const UserLoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserLogoutSuccess extends UserState {
  const UserLogoutSuccess();
}

class UserProfileUpdateSuccess extends UserState {
  final UserModel user;

  const UserProfileUpdateSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class PasswordChangeSuccess extends UserState {
  const PasswordChangeSuccess();
}

class PasswordResetEmailSent extends UserState {
  const PasswordResetEmailSent();
}

class AccountDeleteSuccess extends UserState {
  const AccountDeleteSuccess();
}

class UserRequiresBirthdateState extends UserState {
  final UserModel user;

  const UserRequiresBirthdateState({required this.user});

  @override
  List<Object?> get props => [user];
}

// BLOC
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserController _userController;

  UserBloc({UserController? userController})
      : _userController = userController ?? UserController(),
        super(const UserInitial()) {

    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<CompleteBirthdateEvent>(_onCompleteBirthdate);
    on<LogoutUserEvent>(_onLogoutUser);
    on<LoadCurrentUserEvent>(_onLoadCurrentUser);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);

    // Avvia il controllo dello stato di autenticazione
    add(const CheckAuthStatusEvent());
  }

  Future<void> _onRegisterUser(
      RegisterUserEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      final user = await _userController.registerUser(
        email: event.email,
        password: event.password,
        name: event.name,
        surname: event.surname,
        birthdate: event.birthdate,
      );

      emit(UserRegistrationSuccess(user: user));
      emit(UserAuthenticated(user: user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onLoginUser(
      LoginUserEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      final user = await _userController.loginUser(
        email: event.email,
        password: event.password,
      );

      emit(UserLoginSuccess(user: user));
      emit(UserAuthenticated(user: user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onGoogleSignIn(
      GoogleSignInEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      final user = await _userController.signInWithGoogle();

      // Verifica se il profilo è completo
      if (!user.profileComplete) {
        emit(UserRequiresBirthdateState(user: user));
      } else {
        emit(UserLoginSuccess(user: user));
        emit(UserAuthenticated(user: user));
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onCompleteBirthdate(
      CompleteBirthdateEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      final updatedUser = await _userController.completeBirthdate(
        userId: event.userId,
        birthdate: event.birthdate,
      );

      emit(UserLoginSuccess(user: updatedUser));
      emit(UserAuthenticated(user: updatedUser));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onLogoutUser(
      LogoutUserEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      await _userController.logoutUser();
      emit(const UserLogoutSuccess());
      emit(const UserUnauthenticated());
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentUser(
      LoadCurrentUserEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      final user = await _userController.getCurrentUser();

      if (user != null) {
        emit(UserAuthenticated(user: user));
      } else {
        emit(const UserUnauthenticated());
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfileEvent event,
      Emitter<UserState> emit,
      ) async {
    if (state is! UserAuthenticated) {
      emit(const UserError(message: 'Utente non autenticato'));
      return;
    }

    emit(const UserLoading());

    try {
      final currentUser = (state as UserAuthenticated).user;
      final updatedUser = await _userController.updateUserProfile(
        userId: currentUser.id,
        name: event.name,
        surname: event.surname,
        birthdate: event.birthdate,
        email: event.email,
      );

      emit(UserProfileUpdateSuccess(user: updatedUser));
      emit(UserAuthenticated(user: updatedUser));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onChangePassword(
      ChangePasswordEvent event,
      Emitter<UserState> emit,
      ) async {
    if (state is! UserAuthenticated) {
      emit(const UserError(message: 'Utente non autenticato'));
      return;
    }

    emit(const UserLoading());

    try {
      await _userController.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      emit(const PasswordChangeSuccess());

      // Mantieni lo stato autenticato
      final currentUser = (state as UserAuthenticated).user;
      emit(UserAuthenticated(user: currentUser));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onResetPassword(
      ResetPasswordEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(const UserLoading());

    try {
      await _userController.resetPassword(event.email);
      emit(const PasswordResetEmailSent());

      // Torna allo stato precedente
      if (_userController.isUserAuthenticated) {
        add(const LoadCurrentUserEvent());
      } else {
        emit(const UserUnauthenticated());
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccountEvent event,
      Emitter<UserState> emit,
      ) async {
    if (state is! UserAuthenticated) {
      emit(const UserError(message: 'Utente non autenticato'));
      return;
    }

    emit(const UserLoading());

    try {
      await _userController.deleteAccount(event.password);
      emit(const AccountDeleteSuccess());
      emit(const UserUnauthenticated());
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<UserState> emit,
      ) async {
    try {
      if (_userController.isUserAuthenticated) {
        final user = await _userController.getCurrentUser();
        if (user != null) {
          // ✅ Verifica se il profilo è completo
          if (!user.profileComplete) {
            emit(UserRequiresBirthdateState(user: user));
          } else {
            emit(UserAuthenticated(user: user));
          }
        } else {
          emit(const UserUnauthenticated());
        }
      } else {
        emit(const UserUnauthenticated());
      }
    } catch (e) {
      emit(const UserUnauthenticated());
    }
  }

  // Getter per verificare se l'utente è autenticato
  bool get isAuthenticated => state is UserAuthenticated;

  // Getter per ottenere l'utente corrente
  UserModel? get currentUser {
    if (state is UserAuthenticated) {
      return (state as UserAuthenticated).user;
    }
    return null;
  }
}