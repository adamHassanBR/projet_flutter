import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../detail_jeu/detail_jeu.dart';

//Notre classe de Search (Principale)
class SearchPage extends StatefulWidget {
  final String searchQuery;
  //On veut qu'un texte soit rentré 
  SearchPage(this.searchQuery);

  @override
  _SearchPageState createState() => _SearchPageState();
}

//On crée une classe qui extends notre SearchPage
class _SearchPageState extends State<SearchPage> {
    //On set le controlleur de texte pour récupérer sa valeur pour les recherches 
    late TextEditingController _searchController;
    //On initialise le searchQuery (pour la recherche sur cette page)
    String _searchQuery = '';


  @override
  void initState() {
    //a l'initialisation 
    super.initState();
    //On veut que notre contrôleur Prennen la valeur de la recherche faite par l'utilisateur (plus une question d'UI)
    _searchController = TextEditingController(text: widget.searchQuery);
    //On set notre valeur pour la recherche du fetch en fonction de ce qu'à renseigné l'utilisateur
    _searchQuery = widget.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //On va lancer nos fetch quand la methode est appelée 
  Future<List<Game>> _searchGames(String searchQuery) async {
    final gameIds = await _searchGameIds(searchQuery);
    final games = await fetchGames(gameIds);
    return games;
  }
  
  //On fetch les recherhce de jeux pour récupérer les IDs des jeux 
  Future<List<int>> _searchGameIds(String searchQuery) async {
    final response = await http.get(Uri.parse('https://steamcommunity.com/actions/SearchApps/$searchQuery'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final gamesJson = json as List<dynamic>;
      final gameIds = gamesJson.map<int>((gameJson) => int.parse(gameJson['appid'].toString())).toList();
      return gameIds;
    } else {
      throw Exception('Echec du Fetch de la recherche');
    }
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


//Fonction d'affichage
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
                  'Recherche',
                  textAlign: TextAlign.left,
                  style : TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ), 
            ], 
          ),
        ),
      ),
      //On appelle notre widget du body 
      body: _buildBody(),
      //Et on modifie la couleur de fond. 
      backgroundColor: Color(0xFF1A2025),
    );
  }

  //Widget du body 
  Widget _buildBody() {
    return Column(
      children: [
        Container(
          //On appelle notre widget de barre de recherche
          child: _buildSearchBar(),
        ),
        Expanded(
          //On va update la liste des games en fonction de notre Clé Entrée par l'utilisateur
          child: FutureBuilder<List<Game>>(
            //Call la fonction pour lancer les fetchs
            future: _searchGames(_searchQuery),
            builder: (context, snapshot) {
              //Si on est en attente d'affichage, on affiche le petit icone de chargement
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
                //Sinon quand on a une erreur
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur : ${snapshot.error}'),
                );
                //Sinon quand on a trouvé de la data
              } else if (snapshot.hasData) {
                final games = snapshot.data;
                //On appelle le widget de construction des Jeux
                return _buildGamesList(games!);
              } else {
                //Si on a pas trouvé de matching avec le texte tapé par l'utilisateur
                return Center(
                  child: Text('Aucun résultat pour la recherche "$widget.searchQuery"'),
                );
              }
            },
          ),
        ),
      ],
    );
  }


  //Widget pour construire la liste des  jeux trouvés
  Widget _buildGamesList(List<Game> games) {
    //Pour scroller 
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
            alignment: Alignment.centerLeft,
            //On indique le nombre de jeux trouvés, et sinon on affiche 0 si il y a rien   
            child: Text(
              "Nombre de jeux trouvés: ${games?.length ?? 0}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          ListView.builder(
            //Et dans notre affichage de jeux on va venir afficher le nombre de jeux fetché sous la forme de carte 
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: games?.length,
            itemBuilder: (context, index) {
              final game = games![index];
              //On appelle donc la fonction pour construire les cartes de jeux
              return _buildGameCard(game);
            },
          ),
        ],
      ),
    );
  }


  //FWidget pour construire les Cartes des jeux
  Widget _buildGameCard(Game game) {
    //On renvoie donc une carte
    return Card(
      //modification de l'affichage
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
            //Fond avec l'ilage tersiaire
            image: NetworkImage(game.imageTersiaire),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.85), BlendMode.srcOver),
          ),
        ),
        //En ligne 
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
              child: Expanded(
                child: AspectRatio(
                  //On affiche d'abord l'image princiaple au format carré 
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
              child : Padding(
            padding: EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  //Puis on affiche le titre
                  game.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  //L'editeur 
                  game.publisher.first,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 9),
                Row(
                  //Et le prix
                  children: [
                    //Sinotre prix n'est pas gratuit, on ecris d'abord "Prix"
                    if (game.price != "Gratuit")
                      Text(
                        "Prix: ",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      //Et dans tous les cas on ecris le prix
                    Text(
                      game.price,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
            ),
            //Ici c'est code pour le bouton en ssavoir plus
          GestureDetector(
            //Quand on appuie dessus 
            onTap: () {
              Navigator.push(
                context,
                //On va ouvrir une nouvelle page vers les infos du jeu (PAge InfoJeu)
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => InfoJeu(
                    gameId: game.id.toString(),
                  ),
                ),
              );
            },
            //Affichage special du bouton
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
          ),
        ],
      ),
    ),
  );
}

//Widget pour la recherche 
Widget _buildSearchBar() {
  return Padding(
    //Modification de l'affichage
    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    child: SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1e262c),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                //On veut que notre controleur ce soit _searchController (attribut de la classe)
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                //On a 'rechercher un jeu de base quand rien n'est tapé
                decoration: InputDecoration(
                  hintText: "Rechercher un jeu",
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
              ),
            ),
            //Permet de verifier quand on a un evenement sur la loupe
            InkWell(
              //Quand on appuye dessus
              onTap: () async {
                //On recupere la valeur de notrre texte entre par l'utilisateur 
                final searchQuery = _searchController.text;
                //Et on relance notre fonction pour le fetching de jeux 
                final games = await _searchGames(searchQuery);
                setState(() {
                  //Et on modifie la valeur de notre SerchQuery 
                  _searchQuery = searchQuery;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.search, color: Color(0xFF626AF6)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

//Notre classe qui va contenir les informations des Games. 
class Game {
  //Son ID
  final int id;
  //sOn titre
  final String name;
  //Sa première image
  final String imageUrl;
  //Son editeur
  final List<dynamic> publisher;
  //Son prix 
  final String price;
  //Sa seconde image (ici on a pris la 3eme image par rapport au menu principal)
  final String imageTersiaire;

  Game({required this.id, required this.name, required this.publisher, required this.price,required this.imageUrl, required this.imageTersiaire});
}

