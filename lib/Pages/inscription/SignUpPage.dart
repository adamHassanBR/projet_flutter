import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _email, _password, _tempPassword;

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
      backgroundColor: Color(0xFF1a2025),
      
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50.0, 100.0, 50.0, 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               Container
                 (
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text
                  (
                    'Inscription !',
                    style: const TextStyle
                    (
                      color: Colors.white,
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Container
                (
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Text
                  (
                    'Veuillez saisir ces différentes informations, afin que vos listes soient sauvegardées.',
                    style: const TextStyle
                    (
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration
                (
                  labelText: "Email",
                  labelStyle: TextStyle
                  (
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Color(0xFF1e262c),
                  border: OutlineInputBorder(
                  ),
                  focusedBorder: OutlineInputBorder
                  (
                    
                    borderSide: BorderSide
                    (
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder
                  (
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                validator: (input) =>
                    !input!.contains('@') ? 'Entrez une adresse email valide' : null,
                onSaved: (input) => _email = input!,
              ),
              SizedBox(height: 16.0),

              TextFormField(
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  labelStyle: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Color(0xFF1e262c),
                  border: OutlineInputBorder(
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value==null || value.isEmpty){
                    return 'Veuillez renseigner un mot de passe';
                  }
                  else if (value!.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  else {
                    _tempPassword= value;
                    return null;
                  }
                },
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 16.0),

              TextFormField(
                decoration: InputDecoration(
                  labelText: "Confirmez le mot de passe",
                  labelStyle: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Color(0xFF1e262c),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                obscureText: true,
                validator: (input) {
                  if (input != _tempPassword) {
                    return "Les mots de passe ne correspondent pas";
                  }
                  return null;
                },
              ),

              
              const SizedBox(height: 100.0),
              ElevatedButton
              (
                onPressed: _submit,
                  style: ElevatedButton.styleFrom
                  (
                    padding: const EdgeInsets.fromLTRB(122.5, 20.0, 122.5, 20.0),
                    primary: Color(0xFF636AF6),
                    shape: RoundedRectangleBorder
                    (
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                child: Text (
                  "S'inscrire",
                   style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                  ),
              ),
               SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/connexion');
                },
                style: ElevatedButton.styleFrom
                (
                  padding: const EdgeInsets.fromLTRB(110.0, 20.0, 110.0, 20.0),
                  primary: Color(0xFF1a2025),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder
                  (
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Color(0xFF636AF6), width: 2.0),
                  ),
                ),
                child: Text(
                  "Se connecter",
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

}