import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: library_prefixes
import 'package:projet_flutter/Backend/SteamAPI_fetch.dart' as steamAPI;


class InfoJeu extends StatefulWidget {
  //L'id pour indentifier le jeu
  final String gameId;

  const InfoJeu({super.key, required this.gameId});

  @override
  // ignore: library_private_types_in_public_api
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
    _gameDetailsFuture = steamAPI.fetchGameDetails(widget.gameId);
    _gameCommentairesFuture = steamAPI.fetchGameReviews(widget.gameId);
  }



//Affichage de l'écran des Infos du Jeu
  @override
Widget build(BuildContext context) {
  return Scaffold(
    //Appelle le builder de la classe AppBar Widget 
    appBar: AppBarWidget(gameId: widget.gameId),
    backgroundColor: const Color(0xFF1A2025),
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
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                },
                              )
                              //Si on est dans les commentaires alors on affiche les commentaires. 
                            : Text(
                                gameData['description'],
                                style: const TextStyle(fontSize: 16, color: Colors.white),
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
          return const Center(child: CircularProgressIndicator());
        }
      },
    ),
    );
  }
}


// ignore: must_be_immutable
class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String gameId;
  DatabaseReference? _likesRef;
  DatabaseReference? _wishlistRef;


  AppBarWidget({super.key, required this.gameId});

  @override
  // ignore: library_private_types_in_public_api
  _AppBarWidgetState createState() => _AppBarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarWidgetState extends State<AppBarWidget> {
  bool _isLiked = false;
  bool _isInWishlist = false;

  @override
  void initState() {

    super.initState();
    widget._likesRef = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('liked_games')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(widget.gameId);


    widget._wishlistRef = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('wish_games')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(widget.gameId);


    widget._likesRef!.once().then((snapshot) {
      if (snapshot.snapshot.value != null) {
        setState(() {
          _isLiked = true;
        });
      }

    widget._wishlistRef!.once().then((snapshot) {
      if (snapshot.snapshot.value != null) {
        setState(() {
          _isInWishlist = true;
        });
      }
    });
  });}

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A2025),
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/svg/back.svg',
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const Expanded(
            child: Text(
              "Détails du jeu",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
                //permet de gérer l'état si notre _likesRef est null, et eviter le crash
                if (widget._likesRef != null) {
                  if (_isLiked) {
                    // Ajoute l'ID du jeu dans la base de données si l'utilisateur like le jeu
                    widget._likesRef!.set(widget.gameId);
                  } else {
                    // Supprime l'ID du jeu de la base de données si l'utilisateur annule son like
                    widget._likesRef!.remove();
                  }
              }});
            },
            icon: SvgPicture.asset(
              _isLiked ? 'assets/svg/like_full.svg' : 'assets/svg/like.svg',
              height: 20,
              width: 20,
            ),
          ),

          const SizedBox(width: 40),
          IconButton(
            onPressed: () {
              setState(() {
                _isInWishlist = !_isInWishlist;
                //permet de gérer l'état si notre _wishlistRef est null, et eviter le crash
                if (widget._wishlistRef != null) {
                  if (_isInWishlist) {
                    // Ajoute l'ID du jeu dans la base de données si l'utilisateur like le jeu
                    widget._wishlistRef!.set(widget.gameId);
                  } else {
                    // Supprime l'ID du jeu de la base de données si l'utilisateur annule son like
                    widget._wishlistRef!.remove();
                  }
              }});
            },
            icon: SvgPicture.asset(
              _isInWishlist ? 'assets/svg/whishlist_full.svg' : 'assets/svg/whishlist.svg',
              height: 20,
              width: 20,
            ),
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
  const GameCardWidget({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
    //On va afficher ca en SizedBox
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //On veut créer une carte poiur afficher les infos du Jeu (Titre, editeur, image)
        child: Card(
          color: const Color(0xFF293136),
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
                  const SizedBox(width: 16),
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
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        //On ajoute un espace puis lediteur du jeu
                        const SizedBox(height: 8),
                        Text(
                          '${gameData['editeur']}',
                          style: const TextStyle(fontSize: 14, color: Colors.white),
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
  const ButtonsWidget({super.key, required this.onDescriptionPressed, required this.onReviewsPressed, required this.showingReviews});

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
              backgroundColor: showingReviews ? const Color(0xFF1A2025) : const Color(0xff626af6),
              side: const BorderSide(
                color: Color(0xff626af6),
                width: 1,
                ), 
                //On rajoute du radius et on en enlève pour uniformiser les boutons
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ), 
                //On augmente sa height
              minimumSize: const Size(double.infinity, 40),
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
              backgroundColor: showingReviews ? const Color(0xff626af6) : const Color(0xFF1A2025),
              side: const BorderSide(
                color: Color(0xff626af6) ,
                width: 1,
                ), 
                 //On rajoute du radius et on en enlève pour uniformiser les boutons
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                 //On augmente sa height
              minimumSize: const Size(double.infinity, 40),
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
  const ReviewsListWidget({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    //affichage des commentaire en column (une Row avec l'id Steam + Note, puis Commentaire en dessous)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            //On va les créer sous forme de Card 
            return Card(
              //On ajoute du shape
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: const Color(0xFF232B31),
              child: Padding(
                //on ajoute du padding pour homogénéiser 
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 30.0),
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
                          future: steamAPI.fetchSteamUsername(review['idSteam']),
                          builder: (context, snapshot) {
                            //Si on est connecté 
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData) {
                                return Text(
                                  //On renvoie du texte en fonctiond e ce que le fetch nous renvoie 
                                  snapshot.data!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                );
                                //SI il y a une erreur 
                              } else if (snapshot.hasError) {
                                return const Text(
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
                            return const CircularProgressIndicator();
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
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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



