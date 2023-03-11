import 'package:flutter/material.dart';
import 'package:projet_flutter/Pages/home/home.dart'; 

void main ()
{
 runApp( const MyApp());
}


///***** widget static ******///
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "game ranking",
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}