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

class LikelistPage extends StatefulWidget {
  const LikelistPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LikelistPageState createState() => _LikelistPageState();
}

class _LikelistPageState extends State<LikelistPage> {
  late DatabaseReference _likesRef;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _likesRef = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('liked_games')
        .child(FirebaseAuth.instance.currentUser!.uid);
  }


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
      stream: _likesRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          // Récupérer la liste des IDs de jeux likés
          Map<dynamic, dynamic> likes =
              snapshot.data?.snapshot.value as Map<dynamic, dynamic>;
          List<int> likedGameIds =
              likes.keys.map((key) => int.parse(key.toString())).toList();
          return _buildLikedGamesList(likedGameIds);
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/empty_likes.svg',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 70),
                const Text(
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

  FutureBuilder<List<createGame.Game>> _buildLikedGamesList(List<int> likedGameIds) {
  return FutureBuilder<List<createGame.Game>>(
    future: steamAPI.fetchGames(likedGameIds),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final games = snapshot.data!;
        return ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return Card(
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
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              game.name,
                              style: const TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              game.publisher.first,
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                if (game.price != "Gratuit")
                                  const Text(
                                    "Prix: ",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline),
                                  ),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

}
