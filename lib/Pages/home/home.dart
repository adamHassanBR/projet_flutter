import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

//permet de venir récupérer les IDs du top 100 des jeux sur Steam et les renvoient sous forme de tableau de int
Future<List<int>> fetchGameIds() async {
  //Requête API 
  final response = await http.get(Uri.parse('https://api.steampowered.com/ISteamChartsService/GetMostPlayedGames/v1/'));
  
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<dynamic> ranks = jsonResponse['response']['ranks'];
    final List<int> ids = ranks.map((rank) => rank['appid'] as int).toList();
    return ids;
  } else {
    throw Exception('Echec du Fetch les Ids des Jeux');
  }
}

//Créé notre classe Game qui va contenir 1 jeu et ses informations. 
class Game {
  final int id;
  final String name;
  final String imageUrl;
  final List<dynamic> publisher;
  final String price;

  Game({required this.id, required this.name, required this.publisher, required this.price,required this.imageUrl});
}

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
        final String name = jsonResponse['name'];
        //On récupère l'image
        final String imageUrl = jsonResponse['header_image'];
        //On récupère le créateur 
        final List<dynamic> publisher = jsonResponse['publishers'];
        
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
        final Game game = Game(id: id, name: name, publisher: publisher, price : price,imageUrl: imageUrl);
        games.add(game);
      }
    } else {
      //Si ca ne fonctionne pas
      throw Exception('Echec du Fetch des informations des Jeux');
    }
  }
  //On renvoie la liste de nos jeux et de leurs informations
  return games;
}

//Class principale 
class HomePage extends StatefulWidget {
  @override
  _GameListPageState createState() => _GameListPageState();
}

//On va créer notre Game list qui extend Home page
class _GameListPageState extends State<HomePage> {
  late Future<List<Game>> _futureGames;

//Initialisation
  @override
  void initState() {
    super.initState();
    _futureGames = _loadGames();
  }

//On va venir charger les Ids des jeux, puis leurs informations 
  Future<List<Game>> _loadGames() async {
    final gameIds = await fetchGameIds();
    final games = await fetchGames(gameIds);
    return games;
  }

//Affichage des jeux
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Les meilleures ventes'),
      ),
      body: FutureBuilder<List<Game>>(
        future: _futureGames,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                //On vient créer une carte pour notre jeu
                return    Card(
                  child: ListTile(
                  //On affiche en premier l'image
                  leading: Image.network(game.imageUrl),
                  //puis le titre
                  title: Text(game.name),
                  //Pour les sous tritres on veut le créateur et le prix, donc on va créer une colonne
                  subtitle: Column(
                    //Et on veut qu'elle soit alignée avec le début 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //On créé nos subtitles
                    children: [
                      Text(game.publisher.first),
                      //On veut afficher ' Prix = xxx€ ' seulement si le jeu n'est pas gratuit
                      Row (
                        children : [
                          //Si le prix n'est pas gratuit 
                          if(game.price != "Gratuit")
                            Text("Prix: "),
                          //Et dans tous les cas 
                          Text(game.price),
                        ],
                      )
                    ],
                  ),
                  // subtitle:  Text(game.publisher.first),
                  trailing: Icon(Icons.more_vert),
                  isThreeLine: true,
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
            //L'indicateur de Progrssion 
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           decoration: InputDecoration(
//             hintText: "Rechercher un jeu",
//             hintStyle: TextStyle(color: Colors.white),
//             prefixIcon: Icon(Icons.search),
//             filled: true,
//             fillColor: Color(0xFF1e262c),
//             border: InputBorder.none,
//           ),
//         ),
//         backgroundColor: Color(0xFF1e262c),
//         elevation: 0.0,
//       ),
//       backgroundColor: Color(0xFF1e262c),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(
//                 top: 20.0,
//                 left: 20.0,
//                 bottom: 10.0,
//               ),
//               child: Text(
//                 "Jeux les plus joués",
//                 style: TextStyle(
//                   fontFamily: 'Google Sans',
//                   color: Colors.white,
//                   fontSize: 20.0,
//                 ),
//               ),
//             ),
//             _buildMostPlayedGame(),
//             Padding(
//               padding: const EdgeInsets.only(
//                 top: 20.0,
//                 left: 20.0,
//                 bottom: 10.0,
//               ),
//               child: Text(
//                 "Tous les jeux",
//                 style: TextStyle(
//                   fontFamily: 'Google Sans',
//                   color: Colors.white,
//                   fontSize: 20.0,
//                 ),
//               ),
//             ),
//             _buildAllGames(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMostPlayedGame() {
//     return Container(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         children: [
//           // TODO: Add game image
//           SizedBox(height: 10.0),
//           Text(
//             "Titre du jeu",
//             style: TextStyle(
//               fontFamily: 'Google Sans',
//               color: Colors.white,
//               fontSize: 18.0,
//             ),
//           ),
//           SizedBox(height: 10.0),
//           Text(
//             "Courte description du jeu",
//             style: TextStyle(
//               fontFamily: 'Google Sans',
//               color: Colors.white.withOpacity(0.5),
//               fontSize: 14.0,
//             ),
//           ),
//           SizedBox(height: 20.0),
//           ElevatedButton(
//             onPressed: () {},
//             child: Text(
//               "En savoir plus",
//               style: TextStyle(
//                 fontFamily: 'Google Sans',
//                 color: Colors.white,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               primary: Color(0xFF636AF6),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//             ),
//           ),
//         ],
//       ),
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: NetworkImage(
//               "https://cdn.cloudflare.steamstatic.com/steam/apps/570/header.jpg?t=1628649045"),
//           fit: BoxFit.cover,
//         ),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//     );
//   }

//   Widget _buildAllGames() 
//   {
//     return Column
//     (
//       children: 
//       [
//         _buildGame("Nom du jeu 1", "\$9.99"),
//         Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
//         _buildGame("Nom du jeu 2", "\$19.99"),
//         Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
//         _buildGame("Nom du jeu 3", "\$29.99"),
//         Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
//         _buildGame("Nom du jeu 4", "\$39.99"),
//         Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
//         _buildGame("Nom du jeu 5", "\$49.99"),
//         Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
//         _buildGame("Nom du jeu 6", "\$59.99"),
//         Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
//       ],
//     );
//   }

//   Widget _buildGame(String title, String price) 
//   {
//     return InkWell
//     (
//       onTap: () 
//       {
//       // TODO: Implement on tap action
//       },
//     child: Container
//     (
//       color: Color(0xFF1e262c),
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row
//       (
//         children: 
//         [
//         Expanded
//         (
//           child: Column
//           (
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: 
//             [
//               Text
//               (
//                 title,
//                 style: TextStyle
//                 (
//                   fontFamily: 'Google Sans',
//                   color: Colors.white,
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text
//               (
//                 price,
//                 style: TextStyle
//                 (
//                   fontFamily: 'Google Sans',
//                   color: Colors.white.withOpacity(0.5),
//                   fontSize: 14.0,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Icon
//         (
//           Icons.arrow_forward_ios_rounded,
//           color: Colors.white.withOpacity(0.5),
//         ),
//       ],
//     ),
//   ),
// );
// }
// }




// TEST => Problème - L'api permet de récupérer l'ID, mais il faut appeler l'autre API pour obtenir tute la data du jeu

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class Game {
//   final int id;
//   final String name;
//   final String imageUrl;
//   final double price;

//   Game({required this.id, required this.name, required this.imageUrl, required this.price});

//   factory Game.fromJson(Map<String, dynamic> json) {
//     return Game(
//       id: json['appid'],
//       name: json['name'],
//       imageUrl: json['img_logo_url'],
//       price: 0.0, // You can add a price field if Steam API provides it
//     );
//   }
// }

// class GamesList extends StatefulWidget {
//   const GamesList({Key? key}) : super(key: key);

//   @override
//   _GamesListState createState() => _GamesListState();
// }

// class _GamesListState extends State<GamesList> {
//   late List<Game> games;

//   @override
//   void initState() {
//     super.initState();
//     fetchGames();
//   }

//   Future<void> fetchGames() async {
//     final response = await http.get(
//       Uri.parse('https://api.steampowered.com/ISteamChartsService/GetMostPlayedGames/v1/'),
//     );

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       final gamesJson = jsonResponse['response']['games'];
//       final games = gamesJson.map((e) => Game.fromJson(e)).toList();
//       setState(() {
//         this.games = games;
//       });
//     } else {
//       throw Exception('Failed to fetch games');
//     }
//   }

//   Widget _buildAllGames() {
//     if (games == null) {
//       return Center(child: CircularProgressIndicator());
//     }

//     return ListView.builder(
//       itemCount: games.length,
//       itemBuilder: (context, index) {
//         final game = games[index];
//         return _buildGame(game);
//       },
//     );
//   }

//   Widget _buildGame(Game game) {
//     return InkWell(
//       onTap: () {
//         // TODO: Implement on tap action
//       },
//       child: Container(
//         color: Color(0xFF1e262c),
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: Row(
//           children: [
//             Image.network(
//               'https://steamcdn-a.akamaihd.net/steam/apps/${game.id}/header.jpg',
//               height: 100.0,
//               width: 100.0,
//               fit: BoxFit.cover,
//             ),
//             SizedBox(
//               width: 16.0,
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     game.name,
//                     style: TextStyle(
//                       fontFamily: 'Google Sans',
//                       color: Colors.white,
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     '\$${game.price}',
//                     style: TextStyle(
//                       fontFamily: 'Google Sans',
//                       color: Colors.white.withOpacity(0.5),
//                       fontSize: 14.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: Colors.white.withOpacity(0.5),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Games List'),
//       ),
//       body: _buildAllGames(),
//     );
//   }
// }
