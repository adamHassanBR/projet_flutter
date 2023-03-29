import 'package:flutter/material.dart';
import 'package:projet_flutter/Pages/connexion/LoginPage.dart';
import 'package:projet_flutter/Pages/inscription/SignUpPage.dart';
import 'package:projet_flutter/Pages/detail_jeu/detail_jeu.dart';
import 'package:projet_flutter/Pages/home/home.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'Pages/recherche/searching.dart';
import 'firebase_options.dart';


void main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}




///***** widget static ******///
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "game ranking",
      debugShowCheckedModeBanner: false,
      //On appelle le menu connexion en premier
      initialRoute: '/home',
      //On initialise nos routes
      routes: {
        '/connexion': (context) => LoginPage(),
        '/recherche' : (context) => SearchPage(''),
        '/home': (context) => HomePage(),
        '/inscription': (context) => SignUpPage(),
        '/detail_jeu': (context) {
          final String gameId = ModalRoute.of(context)!.settings.arguments as String;
          return InfoJeu(gameId: gameId);
        },
      },
    );
  }
}
