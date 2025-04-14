import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportzy/features/auth/pages/sign_up_page.dart';
import 'package:sportzy/features/auth/pages/verification_link_sent_page.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  Future<User?> signUpWithEmail({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      await user!.updateDisplayName(name.trim());

      // Store user in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'gender': '',
        'age': '',
        'phone': '',
        'profileImageUrl': '',
        'keywords': generateSearchKeywords(name.trim(), user.uid),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await userCredential.user!.sendEmailVerification();

      // Navigate to verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerificationLinkSentPage()),
      );
      return user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign up failed')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignUpPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignUpPage()),
      );
    }
    return null;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  List<String> generateSearchKeywords(String name, String uid) {
    final List<String> keywords = [];

    name = name.toLowerCase();
    for (int i = 1; i <= name.length; i++) {
      keywords.add(name.substring(0, i));
    }

    for (int i = 1; i <= uid.length; i++) {
      keywords.add(uid.substring(0, i));
    }

    return keywords.toSet().toList();
  }
}
