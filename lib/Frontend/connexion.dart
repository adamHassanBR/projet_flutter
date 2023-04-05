import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Connexion extends StatefulWidget 
{
  const Connexion({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Connexion> 
{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String _errorMessage = '';

  //Fonction pour se connecter 
  Future<void> _signIn() async 
  {
    try 
    {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      //Si on a rien rempli
      if (email.isEmpty || password.isEmpty) 
      {
        setState(() 
        {
          _errorMessage = 'Veuillez remplir tous les champs';
        });
        return;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Si l'authentification réussit, aller à la page d'accueil
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    } 
    //On catch les erreurs. 
    on FirebaseAuthException catch (e) 
    {
      if (e.code == 'user-not-found') 
      {
        setState(() 
        {
          _errorMessage = 'Aucun utilisateur trouvé pour cet email';
        });
      } else if (e.code == 'wrong-password') {
        setState(() 
        {
          _errorMessage = 'Mauvais mot de passe';
        });
      } else {
        setState(() 
        {
          _errorMessage = 'Erreur de connexion: ${e.message}';
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



                    //Notre TextField de Connexion
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
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
                            color: Color(0xFF1e262c),
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        //Couleur du texte tapé par l'utilisateur
                        color: Colors.white,
                      ),
                      //Valider si toutes les conditions sont bien remplies.
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        return null;
                      },
                ),
                //Rajoute un espace
                const SizedBox(height: 16.0),

                //TextField pour le password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
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
                        color: Color(0xFF1e262c),
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    //Couleur du texte tapé par l'utilisateur
                    color: Colors.white,
                  ),
                  //On vérrifie qu'il y a bien un mot de passe.
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                //Rajoute un espace
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

                //Si il y a un message d'erreur
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0.0, right: 0.0, top: 15.0, bottom: 0.0),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
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