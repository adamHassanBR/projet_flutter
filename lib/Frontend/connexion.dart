import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';


class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Connexion> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? _emailError;
  String? _passwordError;
  

  //Fonction pour se connecter 
  Future<void> _signIn() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      //Si on a rien rempli
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _emailError = email.isEmpty ? 'Veuillez entrer votre email' : null;
          _passwordError =
              password.isEmpty ? 'Veuillez entrer votre mot de passe' : null;
        });
        return;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Si l'authentification réussit, aller à la page d'accueil
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    } 
    //On catch les erreurs. 
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _emailError = 'Aucun utilisateur trouvé pour cet email';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _passwordError = 'Mauvais mot de passe';
        });
      } else {
        setState(() {
          _emailError = 'Erreur de connexion: ${e.message}';
        });
      }
    }
  }


    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1a2025),
        fontFamily: 'Google Sans',
        textTheme: const TextTheme(
          // ignore: deprecated_member_use
          bodyText1: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
          // ignore: deprecated_member_use
          bodyText2: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),

        //Style des buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1a2025),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1e262c),
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/ecran_start.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 130.0, 30.0, 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: const Text(
                        'Bienvenue !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Google Sans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(70.0, 20.0, 70.0, 40.0),
                      child: const Text(
                        'Veuillez vous connecter ou créer un nouveau compte pour utiliser l\'application.',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: Colors.white,
                          fontSize: 17.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),



                  // Notre TextField de Connexion
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(
                        fontFamily: 'Google Sans',
                        color: Colors.white,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1e262c),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF1e262c),
                        ),
                      ),
                      errorText: _emailError,
                      errorStyle: const TextStyle(color: Colors.red),
                      
                    ),
                    style: const TextStyle(
                      // Couleur du texte tapé par l'utilisateur
                      color: Colors.white,
                    ),
                  ),
                  // Rajoute un espace
                  const SizedBox(height: 16.0),


                
                  // TextField pour le mot de passe
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle: const TextStyle(
                        fontFamily: 'Google Sans',
                        color: Colors.white,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1e262c),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF1e262c),
                        ),
                      ),
                      errorText: _passwordError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                    style: const TextStyle(
                      // Couleur du texte tapé par l'utilisateur
                      color: Colors.white,
                    ),
                  ),
                  // Rajoute un espace
                  const SizedBox(height: 100.0),

                //BOUTON SE CONNECTER
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(1.0, 20.0, 1.0, 20.0), backgroundColor: const Color(0xFF636AF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text('Se connecter',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 16.0,
                    )
                  ),
                ),
                const SizedBox(height: 20),

                //BOUTON INSCRIPTION
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/inscription');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color(0xFF1a2025), padding: const EdgeInsets.fromLTRB(1.0, 20.0, 1.0, 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: const BorderSide(color: Color(0xFF636AF6), width: 2.0),
                    ),
                  ),
                  child: const Text(
                    "Créer un nouveau compte",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Google Sans',
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
}
}