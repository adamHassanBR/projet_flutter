import 'package:flutter/material.dart';
import 'package:projet_flutter/Frontend/connexion.dart';
import 'package:projet_flutter/Frontend/signup.dart';
import 'package:projet_flutter/Frontend/detail_jeu.dart';
import 'package:projet_flutter/Frontend/home.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'Frontend/likes.dart';
import 'Frontend/searching.dart';
import 'Frontend/whishlist.dart';


void main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      initialRoute: '/connexion',
      //On initialise nos routes
      routes: {
        '/connexion': (context) => const Connexion(),
        '/recherche' : (context) => const SearchPage(''),
        '/home': (context) => const HomePage(),
        '/inscription': (context) => const Inscription(),
        '/whishlist' : (context) => const WishlistPage(),
        'likes' : (context) => const LikelistPage(),
        '/detail_jeu': (context) {
          final String gameId = ModalRoute.of(context)!.settings.arguments as String;
          return InfoJeu(gameId: gameId);
        },
      },
    );
  }
}
