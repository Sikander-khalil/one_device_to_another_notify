import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      assert(user!.email != null);

      assert(user!.displayName != null);

      assert(!user!.isAnonymous);

      assert(await user!.getIdToken() != null);

      final User currentUser = firebaseAuth.currentUser!;

      assert(user?.uid == currentUser.uid);


      print(user?.displayName);



      print(user?.email);


      return user;
    } catch (e) {

      print(e.toString());

    }
    return null;
  }
}
