import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enum for tabs
enum MatchFilter { live, completed }

final matchFilterProvider = StateProvider<MatchFilter>(
  (ref) => MatchFilter.live,
);

final filteredMatchListProvider = FutureProvider<List<MatchModel>>((ref) async {
  final filter = ref.watch(matchFilterProvider);
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return []; // Not signed in, return empty list
  }

  Query query = FirebaseFirestore.instance
      .collection('matches')
      .where(
        'createdBy',
        isEqualTo: currentUser.uid,
      ); // 🔐 Only fetch user's matches

  if (filter == MatchFilter.live) {
    query = query.where('status', whereIn: ['live', 'ongoing']);
  } else if (filter == MatchFilter.completed) {
    query = query.where('status', isEqualTo: 'completed');
  }

  final snapshot = await query.get();

  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel.fromMap(data);
  }).toList();
});
