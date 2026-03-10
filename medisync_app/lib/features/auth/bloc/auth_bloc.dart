import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/i_auth_service.dart';
import '../models/auth_user.dart';
import '../models/login_request.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class AuthEvent {}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final LoginRequest request;
  AuthLoginEvent(this.request);
}

class AuthLogoutEvent extends AuthEvent {}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class AuthState {}

class AuthLoadingState extends AuthState {}

class AuthUnauthenticatedState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final AuthUser user;
  UserRole get role => user.role;
  AuthAuthenticatedState(this.user);
}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthService _authService;

  AuthBloc({required IAuthService authService})
    : _authService = authService,
      super(AuthLoadingState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await _authService.checkSession();
      if (user != null) {
        emit(AuthAuthenticatedState(user));
      } else {
        emit(AuthUnauthenticatedState());
      }
    } catch (_) {
      emit(AuthUnauthenticatedState());
    }
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await _authService.login(event.request);
      emit(AuthAuthenticatedState(user));
    } on Exception catch (e) {
      emit(AuthErrorState(_mapError(e)));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    await _authService.logout();
    emit(AuthUnauthenticatedState());
  }

  String _mapError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('invalid')) {
      return 'Invalid credentials. Please check your details and try again.';
    }
    if (msg.contains('404')) {
      return 'Hospital ID not found. Please verify your organisation ID.';
    }
    if (msg.contains('connection') || msg.contains('socket')) {
      return 'No internet connection. Please check your network and retry.';
    }
    return 'Something went wrong. Please try again later.';
  }
}
