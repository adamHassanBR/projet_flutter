import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';


import 'detail_jeu.dart';
// ignore: library_prefixes
import 'package:projet_flutter/Backend/SteamAPI_fetch.dart' as steamAPI;
// ignore: library_prefixes
import 'package:projet_flutter/Backend/Game.dart' as createGame;


//Notre class des jeux likés 
class LikelistPage extends StatefulWidget {
  const LikelistPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LikelistPageState createState() => _LikelistPageState();
}


class _LikelistPageState extends State<LikelistPage> {
  //Pour recupérer en data base
  late DatabaseReference _likesRef;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    //O, appelle la data base 
    _likesRef = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('liked_games')
        .child(FirebaseAuth.instance.currentUser!.uid);
  }


//Affichage de nos jeux 
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        backgroundColor: const Color(0xFF1A2025),
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
          children: const [
            Expanded(
              child: Text(
                'Mes likes',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),

    body: StreamBuilder(
      //en fonction de nos Jeux likés 
      stream: _likesRef.onValue,
      builder: (context, snapshot) {
        //Si nos jeux likés sont pas vides 
        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          // On vient récupérer  la liste des IDs de jeux likés
          Map<dynamic, dynamic> likes =
              snapshot.data?.snapshot.value as Map<dynamic, dynamic>;
          List<int> likedGameIds =
              likes.keys.map((key) => int.parse(key.toString())).toList();
          return _buildLikedGamesList(likedGameIds);
          //Si on a pas de jeux likés 
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //On affiche le SVG de base
                SvgPicture.asset(
                  'assets/svg/empty_likes.svg',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 70),
                const Text(
                  //On affiche le texte 
                  "Vous n'avez pas encore liké de contenu.\n\nCliquez sur le coeur pour en rajouter",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          );
        }
      },
    ),
    backgroundColor: const Color(0xFF1A2025),
  );
}
//Fonction pour afficher les juex sous forme de cartes en fonction de leur ID
  FutureBuilder<List<createGame.Game>> _buildLikedGamesList(List<int> likedGameIds) {
  return FutureBuilder<List<createGame.Game>>(
    //On appelle  nos API dans le Back 
    future: steamAPI.fetchGames(likedGameIds),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        //Ici on recupere la data de la snapshot 
        final games = snapshot.data!;
        return ListView.builder(
          //On renvoie un listview builder 
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            //Et on va afficher nos jeux sous forme de carte 
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              //On lui donne du style
              margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 13),
              child: Container(
                height: 115,
                decoration: BoxDecoration(
                  color: const Color(0xFF212B33),
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: NetworkImage(game.imageTersiaire),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.85),
                      BlendMode.srcOver,
                    ),
                  ),
                ),
                //Fin du style
                //on affiche en row
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          //On affiche notre image de jeu
                          child: Image.network(
                            game.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(17),
                        child: Column(
                          //Pour aligner au centre à gauche 
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //notre titre du jeu
                            Text(
                              game.name,
                              style: const TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            //l'editeur du jeu 
                            Text(
                              game.publisher.first,
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              //Pour le prix.
                              children: [
                                //Si le prix n'est pas gratuit 
                                if (game.price != "Gratuit")
                                  const Text(
                                    //on affiche  'prix' avant le prix  
                                    "Prix: ",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline),
                                  ),
                                Text(
                                  //affichage de la valeur du prix 
                                  game.price,
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    //SBouton en savoir plus

                    //si on appuie dessus 
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            //on va dans nos info de jeux
                            pageBuilder: (_, __, ___) => InfoJeu(gameId: game.id.toString()),
                          ),
                        );
                      },
                      //affichage du bouton
                      child: Container(
                        height: double.infinity,
                        width: 115,
                        decoration: const BoxDecoration(
                          color: Color(0xFF626AF6),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "En savoir plus",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      } else if (snapshot.hasError) {
        return Center(
          child: Text('${snapshot.error}'),
        );
      }
      //On affiche un chargement tant qu'on a pas tout laod 
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

}
