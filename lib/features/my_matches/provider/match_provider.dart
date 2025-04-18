import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/features/create_match/model/match_model.dart'; // This import can be removed if it's no longer needed.
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for tabs
enum MatchFilter { live, completed }

final matchFilterProvider = StateProvider<MatchFilter>(
  (ref) => MatchFilter.live,
);
final filteredMatchListProvider = FutureProvider<List<MatchModel>>((ref) async {
  final filter = ref.watch(matchFilterProvider);

  Query query = FirebaseFirestore.instance.collection('matches');

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
