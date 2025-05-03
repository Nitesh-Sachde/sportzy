// 📁 lib/features/home/provider/match_data_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:sportzy/features/auth/provider/auth_state_provider.dart';

// Provider for a specific match by ID
final matchProvider = StreamProvider.family<MatchModel, String>((ref, matchId) {
  return FirebaseFirestore.instance
      .collection('matches')
      .doc(matchId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) {
          throw Exception('Match not found');
        }
        return MatchModel.fromMap(doc.data()!);
      });
});

// Provider for live matches
final liveMatchesProvider = StreamProvider.autoDispose<List<MatchModel>>((ref) {
  // Listen to authentication state
  final isAuthenticated = ref.watch(isUserAuthenticatedProvider);

  // Return empty stream if not authenticated
  if (!isAuthenticated) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('matches')
      .where('status', isEqualTo: 'live')
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => MatchModel.fromMap(doc.data())).toList(),
      );
});

// Provider for past matches
final pastMatchesProvider = StreamProvider.autoDispose<List<MatchModel>>((ref) {
  // Listen to authentication state
  final isAuthenticated = ref.watch(isUserAuthenticatedProvider);

  // Return empty stream if not authenticated
  if (!isAuthenticated) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('matches')
      .where('status', isEqualTo: 'completed')
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => MatchModel.fromMap(doc.data())).toList(),
      );
});
