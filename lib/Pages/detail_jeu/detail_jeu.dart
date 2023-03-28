import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



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


//permet de Fetch tous les commentaires d'un jeu 
Future<List<Map<String, dynamic>>> fetchGameReviews(String gameId) async {
  final url = 'https://store.steampowered.com/appreviews/$gameId?json=1';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body)['reviews'];
    //On veut que ce soit sous la forme de tableau
    final List<Map<String, dynamic>> reviews = [];

    for (var review in jsonResponse) {
      //On vient recupérer son steam ID
      final idSteam = review['author']['steamid'];
      //On vient récupérer son vote
      final etoileVote = review['voted_up'];
      //On vient récupérer sa review
      final commentaireClient = review['review'];

      reviews.add({
        'idSteam': idSteam,
        'etoileVote': etoileVote,
        'commentaireClient': commentaireClient,
      });
    }

    return reviews;
  } else {
    throw Exception('Echec du chargement des Commentaires');
  }
}


//Fonction qui permet de clarifier la description en supprimant les balises. 
String cleanDescription(String description) {
  // Remplacer toutes les balises <br> par un retour à la ligne
  description = description.replaceAll('<br>', '\n');
  description = description.replaceAll('<br />', '\n');
  description = description.replaceAll('<br/>', '\n');

  // Remplacer toutes les balises &quot; par un "
  description = description.replaceAll('&quot;', '"');

  // Remplacer toutes les balises <li>; par un tiret
  description = description.replaceAll('<li>', '-');
  description = description.replaceAll('</li>', '\n');

  // Supprimer les balises <p>, <h1>, <h2> ... et les balises <img>, <strong>, <ul>, <ol>, <i>, <a>
  description = description.replaceAll(RegExp(r'<\/?p>|<\/?h1>|<\/?h2>|<\/?h3>|<\/?h4>|<\/?h5>|<\/?i>|<\/?h6>|<\/?ol>|<\/?ul>|<ul.*?>|<\/?strong>|<img.*?>|<a.*?>|<\/?a>'), '');
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
  late Future<List<Map<String, dynamic>>> _gameCommentaires;

  @override
  void initState() {
    super.initState();
    _gameDetailsFuture = fetchGameDetails(widget.gameId);
    _gameCommentaires = fetchGameReviews(widget.gameId);
  }


//Affichage de l'écran des Infos du Jeu
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFF1A2025),
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/svg/back.svg',
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      title: Row(
        children: [
          Text(
            "Détails du jeu",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          SizedBox(width: 8.0),
        ],
      ),
    ),

   backgroundColor: Color(0xFF1A2025),
   body: FutureBuilder<Map<String, dynamic>>(
      future: _gameDetailsFuture, 
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          final gameData = snapshot.data!;
          return SingleChildScrollView(
            child: Stack(
              children: [
                SizedBox(
                  height: 400,
                  child: Image.network(gameData['imageSecondaire'], fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 325.0),
                  child: SizedBox(
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        color: Color(0xFF293136),
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: 0.15,
                              child: Image.network(gameData['imageSecondaire'], fit: BoxFit.cover),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Image.network(gameData['imagePrincipale'], fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(gameData['titre'], 
                                      style: TextStyle(
                                        fontSize: 18,  
                                        color: Colors.white)),
                                      SizedBox(height: 8),
                                      Text('${gameData['editeur']}', 
                                      style: TextStyle(
                                        fontSize: 14, 
                                        color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 500, 16, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              onPressed: () {
                                // Code pour afficher la description
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xff626af6),
                              ),
                              child: Text(
                                'Description',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              onPressed: () {
                                // Code pour afficher les avis
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xff626af6),
                              ),
                              child: Text(
                                'Avis',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          gameData['description'],
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    ),
  );
}
}
