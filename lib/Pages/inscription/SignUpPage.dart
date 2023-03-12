import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _email, _password;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);

        // Envoi d'un email de vérification à l'utilisateur créé
        await userCredential.user!.sendEmailVerification();

        // Redirection vers la page de connexion
        Navigator.pushReplacementNamed(context, '/connexion');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('Le mot de passe est trop faible.');
        } else if (e.code == 'email-already-in-use') {
          print('Cet email est déjà utilisé.');
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inscription"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email"),
                validator: (input) => !input!.contains('@') ? 'Entrez une adresse email valide' : null,
                onSaved: (input) => _email = input!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
                validator: (input) => input!.length < 6 ? 'Le mot de passe doit contenir au moins 6 caractères' : null,
                onSaved: (input) => _password = input!,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submit,
                child: Text("S'inscrire"),
              ),
              TextButton(
  onPressed: () {
    Navigator.pushNamed(context, '/connexion');
  },
  child: Text("Ce connecter"),
),





            ],
          ),
        ),
      ),
    );
  }
}
