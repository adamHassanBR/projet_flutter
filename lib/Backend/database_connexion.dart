import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

//Classe permettant de gérer les conexion avec la data base. Appelé dans le front 
class Database {

  //On créé notre connexion avec la real time database
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //fonction future qui sera appelée pour connecter l'utilisateur dans 'connexion'
  Future<void> signIn(String email, String password) async {
    try {
      //On veut le log avec son email et son opass word qu'on a recupéré dans les textfields 
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      //Gestions d'erreurs 
      if (e.code == 'user-not-found') {
        //Si l'email existe pas
        return Future.error('Aucun utilisateur trouvé pour cet email');
      } else if (e.code == 'wrong-password') {
        //Si le mot de passe est mauvais
        return Future.error('Mauvais mot de passe');
      } else {
        //Si on arrive pas à se connecter à la bdd
        return Future.error('Erreur de connexion: ${e.message}');
      }
    }
  }

    //fonction permettant l'inscription sur la realtime database
    Future<void> signUp(String email, String password) async {
    try {
      //On va utiliser les données entrées (email et pw)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // On envoi un email de vérification à l'utilisateur créé
      await userCredential.user!.sendEmailVerification();

    //gestion des erreurs 
    } on FirebaseAuthException catch (e) {
      //Si le pw est trop faible 
      if (e.code == 'weak-password') {
        return Future.error('Le mot de passe est trop faible.');
        //Si l'eamil a deja été utilisé 
      } else if (e.code == 'email-already-in-use') {
        return Future.error('Cet email est déjà utilisé.');
      } else {
        //Si on arrive pas à créer ke compte 
        return Future.error('Erreur lors de la création du compte: ${e.message}');
      }
    } catch (e) {
      //Si une erreur quelconque arrive 
      return Future.error('Erreur inattendue: ${e.toString()}');
    }
  }

  //Permet de se connecter pour ecrire dans la partie like de la data base. On a besoin de l'ID
  Future<void> connectToLike(String gameId, bool isLiked) async {
    //connection
    DatabaseReference likesRef = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('liked_games')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(gameId);
    //Si il est pas deja liké 
    if (isLiked) {
      //on le like
      await likesRef.set(gameId);
    } else {
      //sinon on le delike
      await likesRef.remove();
    }
  }

  //permet de voir si un jeu est liké ou non dans la data base 
  Future<bool> isLiked(String gameId) async {
    //conecction
    DatabaseReference likesRef = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('liked_games')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(gameId);
    //On va lire s"il existe 
    DatabaseEvent snapshot = await likesRef.once();
    return snapshot.snapshot.value != null;
  }


  //Permet de se connecter pour ecrire dans la partie wishlist de la data base. On a besoin de l'ID
  Future<void> connectToWishlist(String gameId, bool isInWishlist) async {
    //connection
    DatabaseReference wishlistRef = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('wish_games')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(gameId);
    //Si il est pas encore wishlisté
    if (isInWishlist) {
      //on l'ajoute 
      await wishlistRef.set(gameId);
    } else {
      //sinon on le supprime
      await wishlistRef.remove();
    }
  }

  //permet de voir si un jeu est wishlisté ou non dans la data base 
  Future<bool> isInWishlist(String gameId) async {
    //connection
    DatabaseReference wishlistRef = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('wish_games')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(gameId);
        //On va lire s"il existe 
    DatabaseEvent snapshot = await wishlistRef.once();
    return snapshot.snapshot.value != null;
  }
  
}

