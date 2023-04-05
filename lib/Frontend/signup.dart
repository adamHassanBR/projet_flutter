import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';


class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<Inscription> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final logger = Logger();
  bool isAlreadyExist = false;


  //Création des Variables String pour stocker les valeurs des TextFields
  late String _email, _password, _tempPassword;

  //Fonction lorsqu'on appuye sur le bouton "S'inscrire"
  void _submit() async {
    //Si le form est valide
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //On try catch des erreurs 
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);

        // Envoi d'un email de vérification à l'utilisateur créé
        await userCredential.user!.sendEmailVerification();

        // Redirection vers la page de connexion
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/connexion');

        //Catch des erreurs
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          logger.e('Le mot de passe est trop faible.');
        } else if (e.code == 'email-already-in-use') {
          isAlreadyExist = true;
          logger.e('Cet email est déjà utilisé.');
        }
      } catch (e) {
        logger.e(e.toString());
      }
    }
  }

  //Front de l'appli
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a2025),
      
      //Notre Visuel
      body: Stack(
      children: [
        // Ajout de l'image en arrière-plan
        Positioned.fill(
          child: Opacity(
            opacity: 1,
            child: Image.asset('assets/img/ecran_start.png', fit: BoxFit.cover),
          ),
        ),
        
        Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 130.0, 30.0, 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               Container
                 (
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: const Text
                  (
                    'Inscription',
                    style: TextStyle
                    (
                      color: Colors.white,
                      fontSize: 40.0,
                      fontFamily: 'Google Sans',
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Container
                (
                   padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 40.0),
                  child: const Text
                  (
                    'Veuillez saisir ces différentes informations, afin que vos listes soient sauvegardées.',
                    style: TextStyle
                    (
                      color: Colors.white,
                      fontSize: 17.0,
                      fontFamily: 'Google Sans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),


              ///Text Form pour le Nom d'utilisateur
               TextFormField(
                // ignore: prefer_const_constructors
                decoration: InputDecoration
                (
                  labelText: "Nom d'utilisateur",
                  labelStyle: const TextStyle
                  (
                    //Pour le label 'Email'
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1e262c),
                  border: const OutlineInputBorder(
                  ),
                  focusedBorder: const OutlineInputBorder
                  (
                    borderSide: BorderSide
                    (
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  // ignore: prefer_const_constructors
                  enabledBorder: OutlineInputBorder
                  (
                    // ignore: prefer_const_constructors
                    borderSide: BorderSide(
                      color: const Color(0xFF1e262c),
                    ),
                  ),
                ),
                style: const TextStyle
                  (
                    //Couleur du texte tapé par l'utilisateur
                    color: Colors.white,
                  ),
              ),
              //On rajoute de l'espace
              const SizedBox(height: 16.0),


              //TextField pour accueillir l'EMAIL
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                // ignore: prefer_const_constructors
                decoration: InputDecoration
                (
                  labelText: "E-Mail",
                  labelStyle: const TextStyle
                  (
                    //Pour le label 'Email'
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1e262c),
                  border: const OutlineInputBorder(
                  ),
                  focusedBorder: const OutlineInputBorder
                  (
                    borderSide: BorderSide
                    (
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  // ignore: prefer_const_constructors
                  enabledBorder: OutlineInputBorder
                  (
                    // ignore: prefer_const_constructors
                    borderSide: BorderSide(
                      color: const Color(0xFF1e262c),
                    ),
                  ),
                ),
                style: const TextStyle
                  (
                    //Couleur du texte tapé par l'utilisateur
                    color: Colors.white,
                  ),
                  //On ne créé pas le compte tant que ce n'est pas bon. 
                validator: (input) {
                  if (!input!.contains('@')) {
                    return 'Entrez une adresse email valide';
                  } else if (isAlreadyExist) {
                    isAlreadyExist = false;
                    return 'Adresse email déjà existant';
                  } else {
                    return null;
                  }
                },
                //Quand on va save, on va sauvegarder l'email
                onSaved: (input) => _email = input!,
              ),
              //On rajoute de l'espace
              const SizedBox(height: 16.0),



              //TextField pour le Mot de passe de l'utilisateur
              TextFormField(
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  labelStyle: const TextStyle(
                    //Pour le label Password
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1e262c),
                  border: const OutlineInputBorder(
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  // ignore: prefer_const_constructors
                  enabledBorder: OutlineInputBorder(
                    // ignore: prefer_const_constructors
                    borderSide: BorderSide(
                      color: const Color(0xFF1e262c),
                    ),
                  ),
                ),
                obscureText: true,
                style: const TextStyle
                  (
                    //Couleur du texte tapé par l'utilisateur
                    color: Colors.white,
                  ),
                  //Si le password n'est pas comme on le souhaite, alors message d'erreurs + On bloque l'inscription
                validator: (value) {
                  if (value==null || value.isEmpty){
                    return 'Veuillez renseigner un mot de passe';
                  }
                  else if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  else {
                    _tempPassword= value;
                    return null;
                  }
                },
                //Quand on s'inscrit, on sauvgarde la valeur du password
                onSaved: (value) => _password = value!,
              ),
              //On rajoute de l'espace
              const SizedBox(height: 16.0),



              //TextField pour la vérification du mot de passe de l'utilisateur. 
              TextFormField(
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  labelText: "Confirmez le mot de passe",
                  labelStyle: const TextStyle(
                    //Pour le Label Confirmation de Mot de passe
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
                  // ignore: prefer_const_constructors
                  enabledBorder: OutlineInputBorder(
                    // ignore: prefer_const_constructors
                    borderSide: BorderSide(
                      color: const Color(0xFF1e262c),
                    ),
                  ),
                ),
                obscureText: true,
                style: const TextStyle
                  (
                    //Couleur du texte tapé par l'utilisateur
                    color: Colors.white,
                  ),
                  //On va vérifier si les deux mots de passes sont les mêmes. Si NON, on bloque la création
                validator: (input) {
                  if (input != _tempPassword) {
                    return "Les mots de passe ne correspondent pas";
                  }
                  return null;
                },
                //ICI on n'enregistre rien si on s'inscrit
              ),
              //On rajoute de l'espace
              const SizedBox(height: 90.0),



              //BOUTON INSCRIPTION
              ElevatedButton
              (
                onPressed: _submit,
                  style: ElevatedButton.styleFrom
                  (
                    padding: const EdgeInsets.fromLTRB(145.5, 20.0, 145.5, 20.0), backgroundColor: const Color(0xFF636AF6),
                    shape: RoundedRectangleBorder
                    (
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                child: const Text (
                  "S'inscrire",
                   style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                  ),
              ),
              //On rajoute de l'espace
              const SizedBox(height: 20),


              //BOUTON CONNEXION
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/connexion');
                },
                style: ElevatedButton.styleFrom
                (
                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF1a2025), padding: const EdgeInsets.fromLTRB(130.5, 20.0, 130.5, 20.0),
                  shape: RoundedRectangleBorder
                  (
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(color: Color(0xFF636AF6), width: 2.0),
                  ),
                ),
                child: const Text(
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
      ],
    ),
    );
  }

}