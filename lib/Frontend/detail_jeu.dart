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

//Permet de Fetch le username des utilisateurs Steams en fonction de leur ID
Future<String> fetchSteamUsername(String steamId) async {
  //Clé API Steam de Thibault Gautier
  final apiKey = "345E950B428C0A29F7ED5A936D461277";
  //On fetch à cet url
  final url =
      "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=$apiKey&format=json&steamids=$steamId";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final username = jsonResponse['response']['players'][0]['personaname'];
    return username;
  } else {
    throw Exception('Failed to fetch steam username.');
  }
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
  description = description.replaceAll(RegExp(r'<\/?p>|<\/?h1>|<\/?h2>|<\/?h3>|<\/?h4>|<\/?h5>|<\/?i>|<\/?h6>|<\/?ol>|<\/?ul>|<ul.*?>|<\/?strong>|<img.*?>|<a.*?>|<\/?a>|<h1.*?>|<h2.*?>|<h3.*?>|<h4.*?>|<h5.*?>|<h6.*?>'), '');
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
  late Future<List<Map<String, dynamic>>> _gameCommentairesFuture;

  //Permet de gérer d'afficher les commentaires ou les avis
  bool _showingReviews = false;

  @override
  void initState() {
    super.initState();
    _gameDetailsFuture = fetchGameDetails(widget.gameId);
    _gameCommentairesFuture = fetchGameReviews(widget.gameId);

    //Pour verifier que les commentaires sont bien Fetch
    // _gameCommentairesFuture.then((reviews) {
    //   print('Nombre de commentaires récupérés : ${reviews.length}');
    // }).catchError((error) {
    //   print('Erreur lors de la récupération des commentaires : $error');
    // });
  }




//Affichage de l'écran des Infos du Jeu
  @override
Widget build(BuildContext context) {
  return Scaffold(
    //Appelle le builder de la classe AppBar Widget 
    appBar: AppBarWidget(),
    backgroundColor: Color(0xFF1A2025),
    // On a un body future car le fetching des infos du jeu est un future
    body : FutureBuilder<Map<String, dynamic>>(
      //Pour les details du jeu on appelle le fetching 
      future: _gameDetailsFuture,
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        //Si on a de la data
        if (snapshot.hasData) {
          final gameData = snapshot.data!;
          //On renvoie quelque chosede scrollable
          return SingleChildScrollView(
            child: Stack(
              children: [
                SizedBox(
                  height: 400,
                  child: Image.network(
                    //On veut que l'image du dessus ne soit pas l'image du jeu, mais une image Ingame
                    gameData['imageSecondaire'],
                    fit: BoxFit.cover,
                  ),
                ),
                //On va appeler le builder de la classe GameCard pour créer notre 'Carte' avec les informations du jeu
                Padding(
                  padding: const EdgeInsets.only(top: 325.0),
                  child: GameCardWidget(gameData: gameData),
                ),
                //permet de gérer le switch entre les avis et les commentaires 
                Padding(
                  //On realigne au bon endroit 
                  padding: const EdgeInsets.fromLTRB(16, 500, 16, 0),
                  child: Column(
                    children: [
                      //On appelle notre builder de la classe permettant de gérer les boutons
                      ButtonsWidget(
                        //Quand on appuie sur le bouton description
                        onDescriptionPressed: () {
                          setState(() {
                            //On mets (Afficher avis ?) à faux
                            _showingReviews = false;
                          });
                        },
                        //Quand on appuie sur le bouton avis
                        onReviewsPressed: () {
                          setState(() {
                            //On mets (Afficher avis ?) à vrai
                            _showingReviews = true;
                          });
                        },
                        //on set le state 
                        showingReviews: _showingReviews,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _showingReviews
                        //on met en future notre fetch et on veut savoir si on est dans le menu avis ou Commentaire. 
                            ? FutureBuilder<List<Map<String, dynamic>>>(
                                future: _gameCommentairesFuture,
                                //On appelle notre builder si on est dans les avis
                                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                                  if (snapshot.hasData) {
                                    //et si on a de la donnée, on va afficher les avis en appelant le builder de ReviewsListWidget
                                    return ReviewsListWidget(reviews: snapshot.data!);
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('${snapshot.error}'));
                                  } else {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                },
                              )
                              //Si on est dans les commentaires alors on affiche les commentaires. 
                            : Text(
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
          //SI la data est longue à charger, on affiche le progress indicator 
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




// Widget pour la barre d'affichage principale
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  @override
  //On size en fonction de kToolbarHeight
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  //Le builder
  @override
  Widget build(BuildContext context) {
    //On renvoie une appBar
    return AppBar(
      backgroundColor: Color(0xFF1A2025),
      // Permet d'afficher le bouton de retour 
      leading: IconButton(
        icon: SvgPicture.asset(
          //on va load notre SVG
          'assets/svg/back.svg',
          color: Colors.white,
        ),
        //Quand on appuie dessus on revient au menu Home
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Expanded(
          //affichage de texte
            child: Text(
              "Détails du jeu",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          //Puis on va afficher les SVG de l'etoile et du like
          SvgPicture.asset(
            'assets/svg/like.svg',
            height: 20,
            width: 20,
          ),
          //On ajoute un espace entre les 2 Svg 
          SizedBox(width: 40),
          SvgPicture.asset(
            'assets/svg/whishlist.svg',
            height: 20,
            width: 20,
          ),
        ],
      ),
    );
  }
}



//Permet d'afficher les cartes des Commentaires ou la description
class GameCardWidget extends StatelessWidget {
  final Map<String, dynamic> gameData;
  //On veut qu'il y ait la data qui soient demandée lors de l'appel
  GameCardWidget({required this.gameData});

  @override
  Widget build(BuildContext context) {
    //On va afficher ca en SizedBox
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //On veut créer une carte poiur afficher les infos du Jeu (Titre, editeur, image)
        child: Card(
          color: Color(0xFF293136),
          child: Stack(
            children: [
              Opacity(
                opacity: 0.3,
                //On veut que notre fond de carte soit une image du jeu, mais pas l'image du jeu. 
                child: Image.network(
                  gameData['imageTersiaire'],
                  fit: BoxFit.cover,
                  //Et que ca prenne toute la carte 
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              //on est en row (Image Puis texte en ligne)
              Row(
                children: [
                  //Et on affiche les infos 
                  SizedBox(
                    width: 100,
                    child: AspectRatio(
                      //ON veut que ce soit carré 
                      aspectRatio: 1,
                      child: Padding(
                        //On ajoute un padding à gauche pour pas que ca colle
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.network(
                          //Affichage de l'image du jeu 
                          gameData['imagePrincipale'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    //Et on veut une colonne pour afficher le titre et l'editeur 
                    child: Column(
                      //Alignement pour le style
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //On ajoute le titre du jeu
                        Text(
                          gameData['titre'],
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        //On ajoute un espace puis lediteur du jeu
                        SizedBox(height: 8),
                        Text(
                          '${gameData['editeur']}',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}





//Pour les bouttons et gérer leur couleur
class ButtonsWidget extends StatelessWidget {
  final VoidCallback onDescriptionPressed;
  final VoidCallback onReviewsPressed;
  final bool showingReviews;

  //ON veut savoir si on a press dessus, et si on dot afficher les reviews ou non
  ButtonsWidget({required this.onDescriptionPressed, required this.onReviewsPressed, required this.showingReviews});

  //Notre builder
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          //Notre bouton description
          child: ElevatedButton(
            onPressed: onDescriptionPressed,
            style: ElevatedButton.styleFrom(
              //Quand il est appuyé ou non on change sa couleur
              primary: showingReviews ? Color(0xFF1A2025) : Color(0xff626af6),
              side: BorderSide(
                color: Color(0xff626af6),
                width: 1,
                ), 
                //On rajoute du radius et on en enlève pour uniformiser les boutons
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ), 
                //On augmente sa height
              minimumSize: Size(double.infinity, 40),
            ),
            child: Text(
              'DESCRIPTION',
              style: TextStyle(
                fontSize: 16,
                //Quand il est appuyé ou non on change sa couleur de texte
                color: showingReviews ? Colors.white : Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          //Notre bouton Avis
          child: ElevatedButton(
            onPressed: onReviewsPressed,
            style: ElevatedButton.styleFrom(
               //Quand il est appuyé ou non on change sa couleur
              primary: showingReviews ? Color(0xff626af6) : Color(0xFF1A2025),
              side: BorderSide(
                color: Color(0xff626af6) ,
                width: 1,
                ), 
                 //On rajoute du radius et on en enlève pour uniformiser les boutons
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                 //On augmente sa height
              minimumSize: Size(double.infinity, 40),
            ),
            child: Text(
              'AVIS',
              style: TextStyle(
                fontSize: 16,
                 //Quand il est appuyé ou non on change sa couleur de texte
                color: showingReviews ? Colors.white : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}





//Permet d'afficher les commentaires du client  
class ReviewsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  //On veut que l'appel envoie les reviews en List<Map<String, dynamic>>. 
  ReviewsListWidget({required this.reviews});

  @override
  Widget build(BuildContext context) {
    //affichage des commentaire en column (une Row avec l'id Steam + Note, puis Commentaire en dessous)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            //On va les créer sous forme de Card 
            return Card(
              //On ajoute du shape
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: Color(0xFF232B31),
              child: Padding(
                //on ajoute du padding pour homogénéiser 
                padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //notre Row avec les etoiles er l'ID steam
                    Row(
                      //alignement au centre
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        FutureBuilder<String>(
                          //Permet d'aller récupérer le Blaz d'un utilisateur Steam en fonction de son ID 
                          future: fetchSteamUsername(review['idSteam']),
                          builder: (context, snapshot) {
                            //Si on est connecté 
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData) {
                                return Text(
                                  //On renvoie du texte en fonctiond e ce que le fetch nous renvoie 
                                  snapshot.data!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                );
                                //SI il y a une erreur 
                              } else if (snapshot.hasError) {
                                return Text(
                                  "Erreur de chargement de l'utilisateur",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                );
                              }
                            }
                            // On affiche un indicateur de chargement en attendant que la fonction fetchSteamUsername soit terminée
                            return CircularProgressIndicator();
                          },
                        ),
                        //Affichage de nos etoiles. Si bien 5 etoiles, si pas bien 1 etoile. 
                        Image.asset(
                          'assets/img/etoile_${review['etoileVote'] ? '5' : '0'}.png',
                          height: 80,
                          width: 80,
                        ),
                      ],
                    ),
                    //On affiche notre commentaire client. 
                    Text(
                      review['commentaireClient'],
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}



