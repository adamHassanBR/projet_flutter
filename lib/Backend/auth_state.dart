part of 'auth_bloc.dart';

abstract class AuthState {}

//On set initial le log 
class AuthInitial extends AuthState {}

//Pour gérer l"tat du log, on veur wait
class AuthLoading extends AuthState {}

//Si on a une reussite pour l'authentification
class AuthSuccess extends AuthState {}

//Si on a une erreur pour le l'autentification
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
