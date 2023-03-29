import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

//Notre classe de Search 
class SearchPage extends StatelessWidget {
  final String searchQuery;

//On veut qu'un texte soit rentré 
  SearchPage(this.searchQuery);

//Fonction pour Fetch les recherche d'un Jeu et récuperer son ID et SOn NOM
Future<List<Game>> _searchGames(String searchQuery) async {
  final response = await http.get(Uri.parse('https://steamcommunity.com/actions/SearchApps/$searchQuery'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final gamesJson = json as List<dynamic>;
    final games = gamesJson.map((gameJson) => Game.fromJson(gameJson)).toList();

    return games;
  } else {
    throw Exception('Echec du Fetch de la recherche');
  }
}


//Fonction affichage temporaire pour voir si ca fonctionne
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche : $searchQuery'),
      ),
      body: FutureBuilder<List<Game>>(
        future: _searchGames(searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          }             else if (snapshot.hasData) {
              final games = snapshot.data;

              return ListView.builder(
                itemCount: games?.length,
                itemBuilder: (context, index) {
                  final game = games![index];

                  return ListTile(
                    title: Text(game.name),
                    subtitle: Text('ID : ${game.appid}'),
                  );
                },
              );
            } else {
              return Center(
                child: Text('Aucun résultat pour la recherche "$searchQuery"'),
              );
            }
          },
        ),
      );
  }
}


//Notre classe qui va contenir les informations des Games. 
class Game {
  final String name;
  final String appid;
  
  Game({required this.name, required this.appid});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['name'] ?? '',
      appid: json['appid'] ?? '',
    );
  }
}

