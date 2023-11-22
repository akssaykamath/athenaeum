import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  // final fireStoreDB = FirebaseFirestore.instance;

  GoogleSignInAccount? _googleSignInAccount;

  GoogleSignInAccount get account => _googleSignInAccount!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _googleSignInAccount = googleUser;

      final googleAuth = await _googleSignInAccount?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // fireStoreDB.collection('users').doc(userCredential.user!.uid);
      //
      // await fireStoreDB.collection("users").get().then((event) {
      //   var values = event;
      //
      //   for (var doc in event.docs) {
      //     print("${doc.id} => ${doc.data()}");
      //   }
      //
      //   // if (event.docs.contains(userCredential.user!.uid)) {
      //   //
      //   // } else {
      //   //
      //   // }
      //
      //   fireStoreDB.collection('users').doc(userCredential.user!.uid);
      // });
      // checkIfRegisteredUser();
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  googleLogout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
