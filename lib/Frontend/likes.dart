import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LikelistPage extends StatefulWidget {
  @override
  _LikelistPageState createState() => _LikelistPageState();
}

class _LikelistPageState extends State<LikelistPage> {
  late DatabaseReference _likesRef;

  @override
  void initState() {
    super.initState();
    _likesRef = FirebaseDatabase.instance
        .reference()
        .child('liked_games')
        .child(FirebaseAuth.instance.currentUser!.uid);

    print('UID de l\'utilisateur connecté: ${FirebaseAuth.instance.currentUser!.uid},');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Color(0xFF1A2025),
          leading: IconButton(
            icon: SvgPicture.asset(
              //on va load notre SVG
              'assets/svg/close.svg',
              color: Colors.white,
            ),
            //Quand on appuie dessus on revient au menu Home
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            //On affiche notre Texte titre de page
            children: [
              Expanded( 
                child: Text(
                  'Mes likes',
                  textAlign: TextAlign.left,
                  style : TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ), 
            ], 
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _likesRef.onValue,
        builder: (context, snapshot) {
          print('Snapshot: ${snapshot.data}');
          if (snapshot.hasData &&
              snapshot.data?.snapshot.value != null) {
            // Récupérer la liste des IDs de jeux likés
            Map<dynamic, dynamic> likes = snapshot.data?.snapshot.value as Map<dynamic, dynamic>;
            List<String> likedGames = likes.keys.map((key) => key.toString()).toList();
            print('Jeux likés: $likedGames');
            return ListView.builder(
              itemCount: likedGames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(likedGames[index]),
                );
              },
            );
          } else {
            print('Aucun jeu liké trouvé');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/empty_likes.svg',
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 70),
                  Text(
                    "Vous n'avez pas encore liké de contenu.\n\nCliquez sur le coeur pour en rajouter",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            );
          }
        },
      ),
      backgroundColor: Color(0xFF1A2025),
    );
  }
}
