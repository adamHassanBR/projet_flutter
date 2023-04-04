import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'detail_jeu.dart';

//Crée notre fetch qui va aller chercher les informations d'un jeu en fonction de son ID (Récupérée avant)
Future<List<Game>> fetchGames(List<int> gameIds) async {
  final List<Game> games = [];

  for (int id in gameIds) {
    //requête API
    final response = await http.get(Uri.parse('https://store.steampowered.com/api/appdetails?appids=$id'));

    if (response.statusCode == 200) {
      //On va aller dans la partie 'Data' de notre jeu
      final Map<String, dynamic>? jsonResponse = json.decode(response.body)[id.toString()]['data'];
      //Pour s'assurer que nos informations ne sont pas null (Au cas ou un jeu ait été retiré ou autre)
      if (jsonResponse != null) {
        //On récupère le nom
        String name = jsonResponse['name'];
        if(name.length > 30) {
          name = name.substring(0, name.lastIndexOf(' '));
        }
        //On récupère l'image
        final String imageUrl = jsonResponse['header_image'];
        //On récupère le créateur 
        final List<dynamic> publisher = jsonResponse['publishers'];
        if(publisher.first.length > 20) {
          publisher.first = publisher.first.substring(0, publisher.first.lastIndexOf(' '));
        }
        final List<dynamic> screenshotsList = jsonResponse['screenshots'];
        final String imageTersiaire = screenshotsList.isNotEmpty ? screenshotsList.last['path_thumbnail'] : '';

        //On va venir se focaliser sur la partie 'Price' de 'Data' pour pouvoir récupérer le jeu
        final Map<String, dynamic>? jsonResponse2 = json.decode(response.body)[id.toString()]['data']['price_overview'];
        
        //On créé notre var Prix
        String price; 
        //Si le jeu n'est pas gratuit (S'il est gratuit price_overview n'existe pas dans le code)
        if (jsonResponse2 != null) {
          //Si le prix du jeu est correctement renseigné 
          if(jsonResponse2['initial_formatted'] != "")
          {
            //On récupère le prix initial (avant réduction)
            price = jsonResponse2['initial_formatted'];
          } else {
            //Sinon on récupère le prix final
            price = jsonResponse2['final_formatted'];
          }
        } else {
          //Sinon on le met gratuit
          price = "Gratuit";
        }

        //On envoie tout dans notre constructeur
        final Game game = Game(id: id, name: name, publisher: publisher, price : price,imageUrl: imageUrl, imageTersiaire : imageTersiaire);
        games.add(game);
      }
    } else {
      //Si ca ne fonctionne pas /!\ PARFOIS IL NARRIVE PAS A FETCH, IL FAUT JUSTE RELOAD l'APPLICATION
      throw Exception('Echec du Fetch des informations des Jeux');
    }
  }
  //On renvoie la liste de nos jeux et de leurs informations
  return games;
}



class Game {
  final int id;
  final String name;
  final String imageUrl;
  final List<dynamic> publisher;
  final String price;
  final String imageTersiaire;

  Game({
    required this.id,
    required this.name,
    required this.publisher,
    required this.price,
    required this.imageUrl,
    required this.imageTersiaire,
  });


}


class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late DatabaseReference _likesRef;

  @override
  void initState() {
    super.initState();
    _likesRef = FirebaseDatabase.instance
        .reference()
        .child('wish_games')
        .child(FirebaseAuth.instance.currentUser!.uid);
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
        print('Snapshot: ${snapshot.data}');
        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          // Récupérer la liste des IDs de jeux likés
          Map<dynamic, dynamic> likes =
              snapshot.data?.snapshot.value as Map<dynamic, dynamic>;
          List<int> likedGameIds =
              likes.keys.map((key) => int.parse(key.toString())).toList();
          return _buildLikedGamesList(likedGameIds);
        } else {
          print('Aucun jeu wishlisté trouvé');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/empty_whishlist.svg',
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 70),
                Text(
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
    backgroundColor: Color(0xFF1A2025),
  );
}

  FutureBuilder<List<Game>> _buildLikedGamesList(List<int> likedGameIds) {
  return FutureBuilder<List<Game>>(
    future: fetchGames(likedGameIds),
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
              margin: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
              child: Container(
                height: 115,
                decoration: BoxDecoration(
                  color: Color(0xFF212B33),
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
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                        padding: EdgeInsets.all(17),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              game.name,
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            SizedBox(height: 2),
                            Text(
                              game.publisher.first,
                              style: TextStyle(fontSize: 13, color: Colors.white),
                            ),
                            SizedBox(height: 9),
                            Row(
                              children: [
                                if (game.price != "Gratuit")
                                  Text(
                                    "Prix: ",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline),
                                  ),
                                Text(
                                  game.price,
                                  style: TextStyle(fontSize: 12, color: Colors.white),
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
                        decoration: BoxDecoration(
                          color: Color(0xFF626AF6),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: Center(
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
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}
}

