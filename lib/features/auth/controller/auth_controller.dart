import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/features/home/provider/match_data_provider.dart';
import 'package:sportzy/features/home/screen/home_page.dart';
import 'package:sportzy/features/auth/screen/sign_up_page.dart';
import 'dart:math';

import 'package:sportzy/features/auth/screen/verification_link_sent_page.dart';
import 'package:sportzy/features/playerprofile/provider/statistics_provider.dart';

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
      Future<void> saveUserFcmToken() async {
        final user = FirebaseAuth.instance.currentUser;
        final token = await FirebaseMessaging.instance.getToken();

        if (user != null && token != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'fcmToken': token});
        }
      }

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

Future<User?> signUp({
  required BuildContext context,
  required String name,
  required String email,
  required String password,
}) async {
  try {
    final auth = FirebaseAuth.instance;
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final id = generateRandomUserId();
    final user = userCredential.user;
    await user!.updateDisplayName(name.trim());

    // Store user in Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'id': id,
      'name': name.trim(),
      'email': email.trim(),
      'gender': '',
      'age': '',
      'phone': '',
      'profileImageUrl': '',
      'keywords': generateSearchKeywords(name.trim(), id.trim().toLowerCase()),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await userCredential.user!.sendEmailVerification();

    // Navigate to verification screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VerificationLinkSentPage()),
    );
    Future<void> saveUserFcmToken() async {
      final user = FirebaseAuth.instance.currentUser;
      final token = await FirebaseMessaging.instance.getToken();

      if (user != null && token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
      }
    }

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

final _auth = FirebaseAuth.instance;
Stream<User?> get authStateChanges => _auth.authStateChanges();

User? get currentUser => _auth.currentUser;

List<String> generateSearchKeywords(String name, String id) {
  final List<String> keywords = [];

  name = name.toLowerCase();
  for (int i = 1; i <= name.length; i++) {
    keywords.add(name.substring(0, i));
  }

  for (int i = 1; i <= id.length; i++) {
    keywords.add(id.substring(0, i));
  }

  return keywords.toSet().toList();
}

Future<void> signOut(WidgetRef ref) async {
  try {
    // First invalidate all providers that depend on authentication
    ref.invalidate(liveMatchesProvider);
    ref.invalidate(pastMatchesProvider);
    ref.invalidate(userStatisticsProvider);

    // Then sign out
    await _auth.signOut();
  } catch (e) {
    throw Exception('Failed to sign out');
  }
}
