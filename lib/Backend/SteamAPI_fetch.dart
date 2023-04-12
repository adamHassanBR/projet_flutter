// ignore_for_file: file_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Game.dart';


//permet de venir récupérer les IDs du top 100 des jeux sur Steam et les renvoient sous forme de tableau de int (seulement pour la page d'accueil)
Future<List<int>> fetchGameIdsWithoutParameter() async {
  //Requête API pour les jeux en français avec '&supportedlang=french'
  final response = await http.get(Uri.parse('https://api.steampowered.com/ISteamChartsService/GetMostPlayedGames/v1/?supportedlang=french'));
  
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<dynamic> ranks = jsonResponse['response']['ranks'];
    //On récupère les ids, et on les mets dans un tableau d'Id 
    final List<int> ids = ranks.map((rank) => rank['appid'] as int).toList();
    //Qu'on renvoie ensuite
    return ids;
  } else {
    //Si on arrive pas à fecth 
    throw Exception('Echec du Fetch les Ids des Jeux');
  }
}

//permet de venir récupérer les IDs du top 100 des jeux sur Steam et les renvoient sous forme de tableau de int
Future<List<int>> fetchGameIds(List<int> gameIds) async {
  //Requête API pour les jeux en français avec '&supportedlang=french'
  final response = await http.get(Uri.parse('https://api.steampowered.com/ISteamChartsService/GetMostPlayedGames/v1/?supportedlang=french'));
  
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<dynamic> ranks = jsonResponse['response']['ranks'];
    //On récupère les ids, et on les mets dans un tableau d'Id 
    final List<int> ids = ranks.map((rank) => rank['appid'] as int).toList();
    //Qu'on renvoie ensuite
    return ids;
  } else {
    //Si on arrive pas à fecth 
    throw Exception('Echec du Fetch les Ids des Jeux');
  }
}






//Crée notre fetch qui va aller chercher les informations d'un jeu en fonction de son ID (Récupérée avant)
Future<List<Game>> fetchGames(List<int> gameIds) async {
  final List<Game> games = [];

  for (int id in gameIds) {
    //requête API, on veut que les données en Fr, pour avoir les titres francais, et les devises francaises avec '&supportedlang=french'
    final response = await http.get(Uri.parse('https://store.steampowered.com/api/appdetails?appids=$id&supportedlang=french'));

    if (response.statusCode == 200) {
      final String jsonString = response.body;
      if (jsonString.isNotEmpty) {
        final Map<String, dynamic> decodedJson = json.decode(jsonString);
        final Map<String, dynamic>? jsonResponse = decodedJson[id.toString()]['data'];
        if (jsonResponse != null) {
          //On va aller dans la partie 'Data' de notre jeu
          //Pour s'assurer que nos informations ne sont pas null (Au cas ou un jeu ait été retiré ou autre)
          //On récupère le nom
          String name = jsonResponse['name']; 
          if (name.length > 27) {
            // Sépare la chaîne en mots individuels.
            List<String> motsName = name.split(' ');
            // Concatène les mots jusqu'à ce que la longueur maximale soit atteinte.
            String nouvelleChaineName = '';
            for (int i = 0; i < motsName.length; i++) {
              if ((nouvelleChaineName + motsName[i]).length > 27) {
                break;
              }
              nouvelleChaineName += '${motsName[i]} ';
            }
            // Supprime le dernier caractère, qui est un espace supplémentaire.
            name = nouvelleChaineName.substring(0, nouvelleChaineName.length - 1);
          }
          //On récupère l'image
          final String imageUrl = jsonResponse['header_image'];
          //On récupère le créateur 
          final List<dynamic> publisher = jsonResponse['publishers'];
          if (publisher.first.length > 20) {
            // Sépare la chaîne en mots individuels.
            List<String> mots = publisher.first.split(' ');
            // Concatène les mots jusqu'à ce que la longueur maximale soit atteinte.
            String nouvelleChaine = '';
            for (int i = 0; i < mots.length; i++) {
              if ((nouvelleChaine + mots[i]).length > 20) {
                break;
              }
              nouvelleChaine += '${mots[i]} ';
            }
            // Supprime le dernier caractère, qui est un espace supplémentaire.
            publisher.first = nouvelleChaine.substring(0, nouvelleChaine.length - 1);
          }
          final List<dynamic> screenshotsList = jsonResponse['screenshots'];
          final String imageTersiaire = screenshotsList.isNotEmpty ? screenshotsList.last['path_thumbnail'] : '';

          //On va venir se focaliser sur la partie 'Price' de 'Data' pour pouvoir récupérer le jeu
          final Map<String, dynamic>? jsonResponse2 = decodedJson[id.toString()]['data']['price_overview'];
          
          //On créé notre var Prix
          String price; 
          //Si le jeu n'est pas gratuit (S'il est gratuit price_overview n'existe pas dans le code)
          if (jsonResponse2 != null) {
            //Si le prix du jeu est correctement renseigné 
            if(jsonResponse2['initial_formatted']!= "") {
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
      }
    } else {
      //Si ca ne fonctionne pas
      throw Exception('Echec du Fetch des informations des Jeux');
    }
  }
  return games;
}



  //On fetch les recherche de jeux pour récupérer les IDs des jeux 
  Future<List<int>> searchGameIds(String searchQuery) async {
    //On veut aller à cette adresse
    final response = await http.get(Uri.parse('https://steamcommunity.com/actions/SearchApps/$searchQuery'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final gamesJson = json as List<dynamic>;
      //On recupère les ids des jeux resuktants de la recherche 
      final gameIds = gamesJson.map<int>((gameJson) => int.parse(gameJson['appid'].toString())).toList();
      return gameIds;
    } else {
      //Si on a une erreur
      throw Exception('Echec du Fetch de la recherche');
    }
  }




  //On va venir fetcher toute l'information de notre jeu en fonction de son ID
Future<Map<String, dynamic>> fetchGameDetails(String gameId) async {
  //On va dans l'API
  final url = 'https://store.steampowered.com/api/appdetails?appids=$gameId&supportedlang=french';
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
    final String imageTersiaire = screenshotsList.isNotEmpty ? screenshotsList.last['path_thumbnail'] : '';

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
      'imageTersiaire' : imageTersiaire,
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
  description = description.replaceAll('<br />', '\n');
  description = description.replaceAll('<br/>', '\n');

  // Remplacer toutes les balises &quot; par un "
  description = description.replaceAll('&quot;', '"');

  // Remplacer toutes les balises <li>; par un tiret
  description = description.replaceAll('<li>', '-');
  description = description.replaceAll('</li>', '\n');

  // Supprimer les balises <p>, <h1>, <h2> ... et les balises <img>, <strong>, <ul>, <ol>, <i>, <a>
  description = description.replaceAll(RegExp(r'<\/?p>|<\/?h1>|<\/?h2>|<\/?h3>|<\/?h4>|<\/?h5>|<\/?i>|<\/?h6>|<\/?ol>|<\/?ul>|<ul.*?>|<\/?u>|<u.*?>|<\/?strong>|<img.*?>|<a.*?>|<\/?a>|<h1.*?>|<h2.*?>|<h3.*?>|<h4.*?>|<h5.*?>|<h6.*?>'), '');
  return description;
}





//On va venir fetch nos commentaire via l'API
Future<List<Map<String, dynamic>>> fetchGameReviews(String gameId) async {
  //On choppe le jeu en fonction de son ID via l'API
  final url = 'https://store.steampowered.com/appreviews/$gameId?json=1';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body)['reviews'];
    final List<Map<String, dynamic>> reviews = [];
    //Si on a pas une erreur lors du load
    if (jsonResponse != null) {
      //Pour tous les reviews disponibles
      for (var review in jsonResponse) {
        //On recupère l'auteur 
        final idSteam = review['author']['steamid'];
        //On recupère sa note (Soit bonne soit mauvaise)
        final etoileVote = review['voted_up'];
        //On recupère son commentaire
        final commentaireClient = review['review'];

        // On vérifie la longueur du commentaire pour éviter de charger les commentaires de plus de 1000 caractères, afin d'eviter le spam
        if (commentaireClient.length > 1500) {
          continue; // Ignorer cette revue et passer à la suivante
        }
        //On ajoute dans le tableau des reviews avec ses infos 
        reviews.add({
          'idSteam': idSteam,
          'etoileVote': etoileVote,
          'commentaireClient': commentaireClient,
        });
      }
    }
    //On renvoien le tableau 
    return reviews;
  } else {
    throw Exception('Echec du chargement des Commentaires');
  }
}





//Permet de Fetch le username des utilisateurs Steams en fonction de leur ID
Future<String> fetchSteamUsername(String steamId) async {
  //Clé API Steam de Thibault Gautier
  const apiKey = "345E950B428C0A29F7ED5A936D461277";
  //On fetch à cet url
  final url =
      "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=$apiKey&format=json&steamids=$steamId";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    //On récupère le pseudo Steam
    String username = jsonResponse['response']['players'][0]['personaname'];
    if(username.length > 25) {
      //S'il est trop grand, on le tronc 
        username = username.substring(0, 25);
    }
    return username;
  } else {
    //Si on a une erreur 
    throw Exception('Failed to fetch steam username.');
  }
}