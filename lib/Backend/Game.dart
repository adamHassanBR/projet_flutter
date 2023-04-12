//Créé notre classe Game qui va contenir 1 jeu et ses informations. 
class Game {
  //Son ID
  final int id;
  //Son Nom de jeu
  final String name;
  //Son image principale
  final String imageUrl;
  //son editeur (besoin d'une liste car le format est particulier en API)
  final List<dynamic> publisher;
  //Son prix 
  final String price;
  //Une autre image pour pouvoir l'afficher 
  final String imageTersiaire;

  Game({required this.id, required this.name, required this.publisher, required this.price,required this.imageUrl, required this.imageTersiaire});
}