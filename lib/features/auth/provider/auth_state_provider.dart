import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider that exposes a simple boolean for "is user authenticated"
final isUserAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(data: (user) => user != null, orElse: () => false);
});
