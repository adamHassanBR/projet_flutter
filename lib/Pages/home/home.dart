import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: "Rechercher un jeu",
            hintStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Color(0xFF1e262c),
            border: InputBorder.none,
          ),
        ),
        backgroundColor: Color(0xFF1e262c),
        elevation: 0.0,
      ),
      backgroundColor: Color(0xFF1e262c),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                bottom: 10.0,
              ),
              child: Text(
                "Jeux les plus joués",
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
            _buildMostPlayedGame(),
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                bottom: 10.0,
              ),
              child: Text(
                "Tous les jeux",
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
            _buildAllGames(),
          ],
        ),
      ),
    );
  }

  Widget _buildMostPlayedGame() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // TODO: Add game image
          SizedBox(height: 10.0),
          Text(
            "Titre du jeu",
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            "Courte description du jeu",
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white.withOpacity(0.5),
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              "En savoir plus",
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF636AF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              "https://cdn.cloudflare.steamstatic.com/steam/apps/570/header.jpg?t=1628649045"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget _buildAllGames() 
  {
    return Column
    (
      children: 
      [
        _buildGame("Nom du jeu 1", "\$9.99"),
        Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
        _buildGame("Nom du jeu 2", "\$19.99"),
        Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
        _buildGame("Nom du jeu 3", "\$29.99"),
        Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
        _buildGame("Nom du jeu 4", "\$39.99"),
        Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
        _buildGame("Nom du jeu 5", "\$49.99"),
        Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
        _buildGame("Nom du jeu 6", "\$59.99"),
        Divider(height: 1.0, color: Colors.white.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildGame(String title, String price) 
  {
    return InkWell
    (
      onTap: () 
      {
      // TODO: Implement on tap action
      },
    child: Container
    (
      color: Color(0xFF1e262c),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row
      (
        children: 
        [
        Expanded
        (
          child: Column
          (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: 
            [
              Text
              (
                title,
                style: TextStyle
                (
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text
              (
                price,
                style: TextStyle
                (
                  fontFamily: 'Google Sans',
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
        Icon
        (
          Icons.arrow_forward_ios_rounded,
          color: Colors.white.withOpacity(0.5),
        ),
      ],
    ),
  ),
);
}
}




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
