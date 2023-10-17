import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  //instaniation the firebase authentication.
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  //registering the user.
  Future<User?> register(
    String name,
    String email,
    String phone,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await firebaseFirestore
          .collection("usersCollection")
          .doc(userCredential.user!.uid)
          .set({
        "uid": userCredential.user!.uid,
        "id": userCredential.user?.uid,
        "name": name,
        "phone": phone,
        "email": email,
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  // login method.
  Future<User?> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future logout() async {
    await firebaseAuth.signOut();
  }
}
