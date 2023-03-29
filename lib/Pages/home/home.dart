import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../detail_jeu/detail_jeu.dart';
import '../recherche/searching.dart';

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
  final String imageTersiaire;

  Game({required this.id, required this.name, required this.publisher, required this.price,required this.imageUrl, required this.imageTersiaire});
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



//Affichage de l'interface
  @override
Widget build(BuildContext context) {
  return Scaffold(
    //Menu supperieur (Accueil)
     appBar: AppBar(
      //On affiche en ligne 
      title: Row(
        children: [
          Expanded(
            //ici le texte accueil qu'on va venir mettre à gauche 
            child: Text(
              'Accueil',
              textAlign: TextAlign.left,
              style : TextStyle(
                fontWeight: FontWeight.bold,
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
      //Et on modifie la couleur de fond. 
      backgroundColor: Color(0xFF1A2025),
    ),
    
    //On vient afficher le reste de la page 
     body: Column(
      children: [
        //La SearchBar
        _buildSearchBar(),
        Expanded(
          //La liste des jeux
          child: _buildGamesList(),
        ),
      ],
      
    ),

    backgroundColor: Color(0xFF1A2025),
  );
}


//Widget pour la recherche 
Widget _buildSearchBar() {
  TextEditingController searchController = TextEditingController();
  //On renvoie une APP bar
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    child : SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
              color: Color(0xFF1e262c),
            ),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF1e262c),
              borderRadius: BorderRadius.circular(25),
            ),
            //On affiche en Row
            child: Row(
              children: [
                Expanded(
                  //On crée un textfield pour recupérer notre texte
                  child: TextField(
                    //on veut que ce soit une bar de recherche, et qu'on puisse recuprer sa valeur par la suite pour l'envoyer en requête API
                    controller: searchController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    //Decoration pour le style
                    decoration: InputDecoration(
                      fillColor: Color(0xFF1e262c),
                      //Texte de base 
                      hintText: "Rechercher un jeu",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10.0),
                    ),
                  ),
                ),
                //On ajoute un widget Padding pour le bouton (loupe)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  //Quand il se passe quelque chose  
                  child: GestureDetector(
                    //Quand on clique dessus 
                    onTap: () {
                      //On recupère le texte qui a été tapé par l'utilisateur
                      String searchQuery = searchController.text;
                      //On va ouvrir une nouvelle fenêtre 
                      Navigator.push(
                        context,
                        //Et on appelle la route de la page Recherche
                        MaterialPageRoute(
                          builder: (_) => SearchPage(searchQuery,),
                        ),
                      );
                    },
                    //Couleur du bouton de la loupe 
                    child: Icon(Icons.search, color: Color(0xFF626AF6)),
                  ),
                ),
              ],
            ),
          ),
      ),
    ),
  );
}





//Widget du jeu principal, affiché en haut de l'écran d'acceuil
Widget _buildBackgroundImage() {
  return Container(
    //On vient créer notre Box Decoration qui accueillra notre Image de fond 
    decoration: BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
          //On load l'image 
          'https:\/\/cdn.akamai.steamstatic.com\/steam\/apps\/812140\/ss_0ef33c0f230da6ebac94f5959f0e0a8bbc48cf8a.600x338.jpg',
        ),
        //On lui fait remplir toute la surface
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          //on lui donne une opacity pour pouvoir lire les élements affichés dessus
          Colors.black.withOpacity(0.3),
          BlendMode.darken,
        ),
      ),
    ),
    //On va créer un padding horizontal
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      //On va créer un padding au top et bot 
      child: Padding(
        padding: const EdgeInsets.only(top: 80, bottom: 10),
        //On affiche en Row 1- Title + Desc + Boutton et L'image
        child: Row(
          children: [
            Expanded(
              flex: 2,
              //Notre colonne d'affichage de Title + Desc + Boutton
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //titre
                  Text(
                    "Assassin's Creed® Odyssey",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  //Description
                  Text(
                    "Enhance your Assassin's Creed® Odyssey experience with the Ultimate Edition.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  //notre bouton
                  ElevatedButton(
                    //Quand il est pressé on fait un évenement
                    onPressed: () {
                      //On va dire qu'on souhaite naviguer aux détails de notre jeu, et on lui passe son ID en info (en String) et on veut pouvoir revenir sur notre page
                      Navigator.push(
                        context, 
                        PageRouteBuilder(pageBuilder: (_, __, ___) => InfoJeu(gameId: '812140',),),);
                    },
                    child: Text(
                      "En savoir plus",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF626AF6),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.0),
            //On affiche notre image du jeu
            Expanded(
              flex: 1,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  'https:\/\/cdn.akamai.steamstatic.com\/steam\/apps\/812140\/header.jpg?t=1670596226',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}




  //Methode de construction de la liste des Jeux. 
  FutureBuilder<List<Game>> _buildGamesList(){
      return FutureBuilder<List<Game>>(
          future: _futureGames,
          builder: (context, snapshot) {
            //Si notre snapshot à de l'information concernant le jeu
            if (snapshot.hasData) {
              final games = snapshot.data!;
              return ListView.builder(
                itemCount: games.length +1,
                itemBuilder: (context, index) {
                  //Si on est le premier Indeex (Va afficher l'image principale et le texte)
                  if (index == 0) {
                    //on renvoie un conteneur
                    return Container(
                      child: Column(
                        children: [
                          //Pour afficher notre Jeu principal
                          Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 30.0),
                            child: _buildBackgroundImage(),
                          ),
                          //Pour afficher le texte des Meilleures ventes
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              //Padding de droite et gauche
                              padding: EdgeInsets.symmetric(horizontal: 13.0),
                              child: Padding(
                                //Padding avec les cartes
                                padding: EdgeInsets.only(bottom: 10), // ajouter du padding après le texte
                                child: Text(
                                  "Les meilleures ventes",
                                  style: TextStyle(fontSize: 16, color: Colors.white, decoration : TextDecoration.underline),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }else {
                  final game = games[index -1];
                  //On vient créer une carte pour notre jeu
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // On ajoute un bord arrondi
                    ),
                    // On ajoute une marge autour de la carte
                    margin: EdgeInsets.symmetric(vertical: 7, horizontal: 13), 
                    child: Container(
                      height: 115, // On ajoute une hateur personnalisée
                      decoration: BoxDecoration(
                        color: Color(0xFF212B33), // On ajoute la couleur de fond des ListTitle
                        borderRadius: BorderRadius.circular(5), // On ajoute un bord arrondi au container
                        image: DecorationImage(
                          //On vient mettre en fond de notre carte l'image tersiaire du jeu
                          image: NetworkImage(game.imageTersiaire),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.85), BlendMode.srcOver), // Opacité de 85%
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0 ,vertical: 12),
                            child : Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                game.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          ),
                          // On affiche l'image à gauche
                          
                          // Puis les infos à droite
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.all(17),
                              child: Column(
                                //permet d'aligner en horizontal et en vertical
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // On réduit la taille du titre à 16
                                  Text(game.name, style: TextStyle(fontSize: 15, color: Colors.white,)),
                              SizedBox(height: 2),
                              // On réduit la taille du sous-titre à 13
                              Text(game.publisher.first, style: TextStyle(fontSize: 13, color: Colors.white,)),
                              SizedBox(height: 9),
                              // On affiche "Gratuit" ou "Prix: xxx" selon que le prix est gratuit ou non
                              Row(
                                children: [
                                  if (game.price != "Gratuit") Text("Prix: ", style: TextStyle(fontSize: 13, color: Colors.white, decoration : TextDecoration.underline),),
                                  Text(game.price, style:TextStyle(fontSize: 12, color: Colors.white,)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      // On ajoute le bouton "En savoir plus" à droite
                      GestureDetector(
                        //Dès qu'on appuie sur le bouton 
                        onTap: () {
                          //On va dire qu'on souhaite naviguer aux détails de notre jeu, et on lui passe son ID en info (et on le converti en String) et on veut pouvoir revenir sur notre page
                          Navigator.push(
                          context, 
                          PageRouteBuilder(pageBuilder: (_, __, ___) => InfoJeu(gameId: game.id.toString(),),),);
                        },
                        //Notre bouton est dans un Container 
                        child: Container(
                          //Permet de prendre toute la hauteur 
                          height: double.infinity,
                          //On blinde la largeur (pour faire un carré)
                          width: 115,
                          decoration: BoxDecoration(
                            color: Color(0xFF626AF6),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          //On le centre 
                          child: Center(
                            //On prends la hauteur de la carte 
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "En savoir plus",
                                style: TextStyle(color: Colors.white, fontSize: 18,),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      )
                    ],
                  ),
                ),
              );
              }
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
    );
  }
}