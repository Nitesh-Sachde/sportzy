import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';

final justSignedInProvider = StateProvider<bool>((ref) => false);

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthRepository(auth);
});

final authStateProvider = StreamProvider<User?>((ref) async* {
  final authRepo = ref.watch(authRepositoryProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);

  await for (final user in authRepo.authStateChanges) {
    if (user != null) {
      try {
        await user.reload();
        final refreshedUser = firebaseAuth.currentUser;

        if (refreshedUser == null) {
          yield null; //  User deleted or signed out
        } else {
          yield refreshedUser; //  Still valid
        }
      } catch (e) {
        yield null; //  Reload failed — possibly deleted
      }
    } else {
      yield null; //  Not signed in
    }
  }
});

// Direct access to the current Firebase user (nullable)
final currentUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});
