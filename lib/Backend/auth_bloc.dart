import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart' show Bloc;
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;

  AuthBloc({required FirebaseAuth auth})
      : _auth = auth,
        super(AuthInitial());

  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is LoginEvent) {
      yield AuthLoading();
      try {
        final email = event.email.trim();
        final password = event.password.trim();

        if (email.isEmpty || password.isEmpty) {
          yield AuthError('Veuillez remplir tous les champs');
        } else {
          await _auth.signInWithEmailAndPassword(
              email: email, password: password);
          yield AuthSuccess();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          yield AuthError('Aucun utilisateur trouvé pour cet email');
        } else if (e.code == 'wrong-password') {
          yield AuthError('Mauvais mot de passe');
        } else {
          yield AuthError('Erreur de connexion: ${e.message}');
        }
      }
    } else if (event is LogoutEvent) {
      await _auth.signOut();
      yield AuthInitial();
    }
  }
}
