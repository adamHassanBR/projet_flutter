import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: unused_import
import 'package:projet_flutter/Backend/database_connexion.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<Inscription> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Database _register = Database();


  //Permet de voir si on a modifier notre texte pour supprimer notre erreur SVG
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final logger = Logger();
  bool isAlreadyExist = false;

  //Boolens pour controler l'etat de notre erreur 
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  bool _pseudoError = false;
  bool _emailError = false;



  //Boolean pour controler l'etat de notre affichage de SVG
  bool _showPasswordErrorIcon = false;
  bool _showConfirmPasswordErrorIcon = false;
  bool _showPseudoErrorIcon = false;
  bool _showEmailErrorIcon = false;



  //Création des Variables String pour stocker les valeurs des TextFields
  late String _email, _password, _tempPassword='';

  @override
void initState() {
  super.initState();
  //Permet de voir dès qu'on a un changement avec un Adlistener
  _passwordController.addListener(_updatePasswordError);
  _confirmPasswordController.addListener(_updateConfirmPasswordError);
  _pseudoController.addListener(_updatePseudoError);
  _emailController.addListener(_updateEmailError);
}

@override
void dispose() {
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  _pseudoController.dispose();
  _emailController.dispose();
  super.dispose();
}

//Pour changer le state de mon controleur d'erreur d'email
void _updateEmailError() {
  if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
    if (!_emailError) {
      setState(() {
        _emailError = true;
      });
    }
  } else if (_emailError) {
    setState(() {
      _emailError = false;
    });
  }
}

//Pour changer le state de mon controleur de mot de passe
void _updatePasswordError() {
  if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
    if (!_passwordError) {
      setState(() {
        _passwordError = true;
      });
    }
  } else if (_passwordError) {
    setState(() {
      _passwordError = false;
    });
  }
}

//Pour changer le state de mon controleur d'erreur de confirmation de mot de passe
void _updateConfirmPasswordError() {
  if (_confirmPasswordController.text.isEmpty ||
      _confirmPasswordController.text != _passwordController.text) {
    if (!_confirmPasswordError) {
      setState(() {
        _confirmPasswordError = true;
      });
    }
  } else if (_confirmPasswordError) {
    setState(() {
      _confirmPasswordError = false;
    });
  }
}

//Pour changer le state de mon controleur d'erreur de Pseudo
void _updatePseudoError() {
  if (_pseudoController.text.isEmpty) {
    if (!_pseudoError) {
      setState(() {
        _pseudoError = true;
      });
    }
  } else if (_pseudoError) {
    setState(() {
      _pseudoError = false;
    });
  }
}



    //Fonction lorsqu'on appuye sur le bouton "S'inscrire"
  void _submit() async {
    //Si le form est valide
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Appeler signUp() depuis l'instance de Backend
        await _register.signUp(_email, _password);

        //On connecte l'utilisateur
        await _auth.signInWithEmailAndPassword(email: _email, password: _password);

        // Redirection vers la page de connexion
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      } catch (error) {
        if (error.toString().contains('Le mot de passe est trop faible.')) {
          // Gérer l'erreur 'Le mot de passe est trop faible.'
          logger.e('Le mot de passe est trop faible.');
        } else if (error.toString().contains('Cet email est déjà utilisé.')) {
          // Gérer l'erreur 'Cet email est déjà utilisé.'
          isAlreadyExist = true;
          logger.e('Cet email est déjà utilisé.');
        } else {
          // Gérer les autres erreurs
          logger.e(error.toString());
        }
      }
    } else {
      // On met à jour l'état des icônes d'avertissement si on ne remplit pas les conditions nécessaires à leur apparition.
      setState(() {
        _showPseudoErrorIcon = _pseudoController.text.isEmpty;
        _showEmailErrorIcon = _emailController.text.isEmpty || !_emailController.text.contains('@');
        _showPasswordErrorIcon = _passwordController.text.isEmpty || _passwordController.text.length < 6;
        _showConfirmPasswordErrorIcon = _confirmPasswordController.text.isEmpty || _confirmPasswordController.text != _passwordController.text;
      });
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
                controller: _pseudoController,
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
                  suffixIcon: _showPseudoErrorIcon
                 ? SizedBox(
                      width: 18,
                      height: 18,
                      child: Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset('assets/svg/warning.svg', width: 24, height: 24),
                      ),
                    )
                  : null,
                ),
                style: const TextStyle
                  (
                    //Couleur du texte tapé par l'utilisateur
                    color: Colors.white,
                  ),
                validator: (input) {
                  if (input==null || input.isEmpty){
                    return "Veuillez renseigner un nom d'utilisateur";
                  }
                  return null;
                },
                  
              ),
              
              //On rajoute de l'espace
              const SizedBox(height: 16.0),


              //TextField pour accueillir l'EMAIL
              TextFormField(
                controller: _emailController,
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
                  suffixIcon: _showEmailErrorIcon
                 ? SizedBox(
                      width: 18,
                      height: 18,
                      child: Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset('assets/svg/warning.svg', width: 24, height: 24),
                      ),
                    )
                  : null,
                ),
                style: const TextStyle
                  (
                    //Couleur du texte tapé par l'utilisateur
                    color: Colors.white,
                  ),
                  //On ne créé pas le compte tant que ce n'est pas bon. 
                 validator: (input) {
                  if (input==null || input.isEmpty){
                    return 'Veuillez renseigner une adresse e-mail';
                  }
                  else if (!input.contains('@')) {
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
                controller: _passwordController,
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
                 suffixIcon: _showPasswordErrorIcon
                 ? SizedBox(
                      width: 18,
                      height: 18,
                      child: Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset('assets/svg/warning.svg', width: 24, height: 24),
                      ),
                    )
                  : null,
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
                controller: _confirmPasswordController,
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
                  suffixIcon: _showConfirmPasswordErrorIcon
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset('assets/svg/warning.svg', width: 24, height: 24),
                      ),
                    )
                  : null,
                ),
                obscureText: true,
                style: const TextStyle
                  (
                    //Couleur du texte tapé par l'utilisateur
                    color: Colors.white,
                  ),
                  //On va vérifier si les deux mots de passes sont les mêmes. Si NON, on bloque la création
                validator: (input) {
                  if (input==null || input.isEmpty) {
                    return "Veuillez renseigner la confirmation de mot de passe";
                  } else if (input != _tempPassword ) {
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