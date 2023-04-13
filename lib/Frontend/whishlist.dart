import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


import 'detail_jeu.dart';
// ignore: library_prefixes
import 'package:projet_flutter/Backend/SteamAPI_fetch.dart' as steamAPI;
// ignore: library_prefixes
import 'package:projet_flutter/Backend/Game.dart' as createGame;


class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late DatabaseReference _likesRef;

  @override
  void initState() {
    super.initState();
    //permet de lancer la connexion à la data base 
    _likesRef = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('wish_games')
        .child(FirebaseAuth.instance.currentUser!.uid);
  }

@override
//Notre widget d'affichage
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
                'Ma liste de souhaits',
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
      stream: _likesRef.onValue,
      builder: (context, snapshot) {
        //Si on a de la donnée en data base pour les jeux wishlistés 
        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          // Récupérer la liste des IDs de jeux likés
          Map<dynamic, dynamic> likes =
              snapshot.data?.snapshot.value as Map<dynamic, dynamic>;
          List<int> likedGameIds =
              likes.keys.map((key) => int.parse(key.toString())).toList();
          return _buildLikedGamesList(likedGameIds);
        } else {
          //Sinon on va juste afficher le SVG  et le texte
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //affichage du SVG
                SvgPicture.asset(
                  'assets/svg/empty_whishlist.svg',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 70),
                const Text(
                  //Affichage du texte
                  "Vous n'avez pas encore ajouté de contenu.\n\nCliquez sur l'étoile pour en rajouter",
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

//Fonction permettant de construire la liste des jeux à afficher (C'est la meême que dans like)
  FutureBuilder<List<createGame.Game>> _buildLikedGamesList(List<int> likedGameIds) {
  return FutureBuilder<List<createGame.Game>>(
    //On appelle notre fetch des jeux en fonction de leurs IDs pour obtenir certaines de leurs infos 
    future: steamAPI.fetchGames(likedGameIds),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final games = snapshot.data!;
        //on renvoie un listview 
        return ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            //Et on construit chaque jeu sous forme de card 
            return Card(
              //Personalisation de l'affichage
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
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
                //Fin de personnalisation
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          //On affiche l'image principale
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
                            //on affiche le titre du jeu 
                            Text(
                              game.name,
                              style: const TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            //on affiche l'editeur
                            Text(
                              game.publisher.first,
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              //pour afficher le prix 
                              children: [
                                //si le prix n'est pas gratuit
                                if (game.price != "Gratuit")
                                  const Text(
                                    //on vient afficher 'prix' avant d'afficher sa valeur 
                                    "Prix: ",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline),
                                  ),
                                  //on affiche la valeur du prix 
                                Text(
                                  game.price,
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    //Bouton d'affichage des infos du jeu
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            //on appelle les infos du jeux si on clique sur le bouton
                            pageBuilder: (_, __, ___) => InfoJeu(gameId: game.id.toString()),
                          ),
                        );
                      },
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
                              //Affichage du titre du bouton
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
      //Si on a des données à charger, on met un indicateur jusqu'à ce que ce soit fini. 
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}
}

