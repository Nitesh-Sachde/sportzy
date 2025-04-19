// 📁 lib/features/home/provider/match_data_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';

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
final liveMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('matches')
      .where('status', isEqualTo: 'live')
      .orderBy('createdAt', descending: true)
      .limit(10) // Limit to prevent excessive data fetching
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => MatchModel.fromMap(doc.data())).toList(),
      );
});

// Provider for past matches
final pastMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
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
