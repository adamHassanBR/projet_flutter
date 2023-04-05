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