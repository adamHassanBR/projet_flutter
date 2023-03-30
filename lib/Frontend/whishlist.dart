import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WishlistPage extends StatelessWidget {
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
                  'Ma liste de souhaits',
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/empty_whishlist.svg',
              height: 150,
              width: 150,
            ),
            SizedBox(height: 70),
            Text(
              "Vous n'avez pas encore ajouté de contenu.\n\nCliquez sur l'étoile pour en rajouter",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF1A2025),
    );
  }
}
