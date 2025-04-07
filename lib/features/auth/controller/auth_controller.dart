import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportzy/features/home/pages/home_page.dart';
import 'package:sportzy/features/auth/pages/sign_up_page.dart';
import 'dart:math';

import 'package:sportzy/features/auth/pages/verification_link_sent_page.dart';

String generateRandomUserId() {
  final random = Random();
  final number = random.nextInt(900000) + 100000; // Ensures 6 digits
  return 'S$number';
}

Future<void> signIn({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    final auth = FirebaseAuth.instance;

    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = userCredential.user;

    if (user != null && !user.emailVerified) {
      // If not verified, send user to verification link page
      await user.sendEmailVerification();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerificationLinkSentPage()),
      );
    } else {
      // Verified user → HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign in failed')));
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
  }
}

Future<void> signUp({
  required BuildContext context,
  required String name,
  required String email,
  required String password,
}) async {
  try {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;
    final userId = generateRandomUserId();

    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'userId': userId,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Send verification email
    await userCredential.user!.sendEmailVerification();

    // Navigate to verification screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VerificationLinkSentPage()),
    );
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
}
