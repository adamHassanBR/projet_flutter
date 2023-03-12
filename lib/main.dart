import 'package:flutter/material.dart';
import 'package:projet_flutter/Pages/connexion/LoginPage.dart';
import 'package:projet_flutter/Pages/home/home.dart'; 
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}




///***** widget static ******///
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "game ranking",
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}