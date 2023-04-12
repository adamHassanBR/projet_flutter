part of 'auth_bloc.dart';

//La classe qui permet de gérer 'evenement de login 
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  //On a besoin de l'email et du pw 
  final String email;
  final String password;

  //et on souhaite logger notre user avec les logs et le pw
  LoginEvent({required this.email, required this.password});
}

class LogoutEvent extends AuthEvent {}

