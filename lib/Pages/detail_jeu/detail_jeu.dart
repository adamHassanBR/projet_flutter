import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


//On va venir fetcher toute l'information de notre jeu en fonction de son ID
Future<Map<String, dynamic>> fetchGameDetails(String gameId) async {
  //On va dans l'API
  final url = 'https://store.steampowered.com/api/appdetails?appids=$gameId';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body)[gameId];
    //On récupère l'info
    final gameDetails = jsonResponse['data'];
    //on enregistre son nom
    final String titre = gameDetails['name'];
    //On enregistre son editeur
    final List<dynamic> editeurList = gameDetails['publishers'];
    final String editeur = editeurList.isNotEmpty ? editeurList.first : '';
    //on recupère son image de jeu
    final String imagePrincipale = gameDetails['header_image'];
    //on recupère une seconde image
    final List<dynamic> screenshotsList = gameDetails['screenshots'];
    final String imageSecondaire = screenshotsList.isNotEmpty ? screenshotsList.first['path_thumbnail'] : '';
    //on récupère sa description
    final String description = gameDetails['detailed_description'];
    //on Va clarifier la description
    final String cleanedDescription = cleanDescription(description);

    //on va charger toute cette info dans un tableau
    final Map<String, dynamic> gameData = {
      'titre': titre,
      'editeur': editeur,
      'imagePrincipale': imagePrincipale,
      'imageSecondaire': imageSecondaire,
      'description': cleanedDescription,
    };
    //On renvoie le tableau
    return gameData;
  } else {
    throw Exception('Echec du chargement des informations');
  }
}

//Fonction qui permet de clarifier la description en supprimant les balises. 
String cleanDescription(String description) {
  // Remplacer toutes les balises <br> par un retour à la ligne
  description = description.replaceAll('<br>', '\n');

  // Supprimer les balises <p>, <h1>, <h2> ... et les balises <img> et <strong>
  description = description.replaceAll(RegExp(r'<\/?p>|<\/?h1>|<\/?h2>|<\/?h3>|<\/?h4>|<\/?h5>|<\/?h6>|<\/?strong>|<img.*?>'), '');
  return description;
}


class InfoJeu extends StatefulWidget {
  //L'id pour indentifier le jeu
  final String gameId;

  InfoJeu({required this.gameId});

  @override
  _InfoJeuState createState() => _InfoJeuState();
}

class _InfoJeuState extends State<InfoJeu> {
  late Future<Map<String, dynamic>> _gameDetailsFuture;

  @override
  void initState() {
    super.initState();
    _gameDetailsFuture = fetchGameDetails(widget.gameId);
  }


//Affichage de l'écran des Infos du Jeu
  @override
Widget build(BuildContext context) {
  return Scaffold(
    //A modifier par la suite
    appBar: AppBar(
      title: Text('Informations du jeu'),
    ),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _gameDetailsFuture,
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        //Si ya de la data
        if (snapshot.hasData) {
          final gameData = snapshot.data!;
          //On affiche nos infos de jeu
          return ListView(
            children: [
              //Affichage (A modifier)
              Image.network(gameData['imagePrincipale']),
              Text(gameData['titre'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('editeur: ${gameData['editeur']}'),
              Text(gameData['description']),
              if (gameData['imageSecondaire'] != null) ...[
                Text('Capture d\'écran:'),
                Image.network(gameData['imageSecondaire']),
              ],
              //Bouton pour sortir et revenir au menu home
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text('retour en arrière'),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else {
          //Si ca prends du temps à charger on affiche un progress indicator
          return Center(child: CircularProgressIndicator());
        }
      },
    ),
  );
}
}
