import 'package:flutter/material.dart';

import 'package:projet_flutter/Backend/database_connexion.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

//la classe de conexion
class _LoginPageState extends State<Connexion> {

  //On veut un form 
  final _formKey = GlobalKey<FormState>();
  //Permet de controler si l'email et le password sont bien 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //Pour la connexion databse avec le back
  final Database _auth = Database();

  //Pour gérer les erreurs des textfields 
  String? _emailError;
  String? _passwordError;
  

  //Fonction pour se connecter 
  Future<void> _signIn() async {
    //On va assigner les controleurs
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    //Si on a rien rempli
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        //On affiche les erreurs 
        _emailError = email.isEmpty ? 'Veuillez entrer votre email' : null;
        _passwordError =
            password.isEmpty ? 'Veuillez entrer votre mot de passe' : null;
      });
      return;
    }

    try {
      await _auth.signIn(email, password);
      // Si l'authentification réussit, aller à la page d'accueil
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      //On affiche les erreurs.
      setState(() {
        _emailError = error.toString();
      });
    }
  }


  //Widget d'affichage 
    @override
  Widget build(BuildContext context) {
    //affichage d'un material APP
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1a2025),
        //police google 
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

        //Pour le Style des buttons
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
              //On veut que le fond d'ecran ait une image particulière 
              image: AssetImage('assets/img/ecran_start.png'),
              fit: BoxFit.cover,
            ),
          ),
          //On ajoute du padding 
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 130.0, 30.0, 50.0),
              //pour notre form avec les textfields 
              child: Form(
                key: _formKey,
                //On ajoute du style 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      //texte principal
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
                      //Ajout de padding
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
                    //on assigne son controleur 
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      //Email 
                      labelText: "Email",
                      labelStyle: const TextStyle(
                        fontFamily: 'Google Sans',
                        color: Colors.white,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1e262c),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF1e262c),
                        ),
                      ),
                      //Gestion des erreurs 
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
                    //on assigne son controleur 
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
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF1e262c),
                        ),
                      ),
                      //gEstion des eerreurs 
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
                  //on appelle signin pour la connexion 
                  onPressed: _signIn,
                  //Affichage du bouton se connecter 
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
                  //on veiut aller au menu inscription 
                  onPressed: () {
                    Navigator.pushNamed(context, '/inscription');
                  },
                  //Affichage du boutton pur aller au menu d'inscription
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