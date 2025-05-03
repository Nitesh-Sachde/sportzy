import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final matchSearchResultsProvider = FutureProvider.autoDispose<List<MatchModel>>(
  (ref) async {
    final query = ref.watch(searchQueryProvider);

    // Don't perform search for empty queries
    if (query.isEmpty || query.length < 2) {
      return [];
    }

    final lowerCaseQuery = query.toLowerCase();
    List<MatchModel> matches = [];

    try {
      // Try the indexed query first
      final QuerySnapshot matchResults =
          await FirebaseFirestore.instance
              .collection('matches')
              .where('keywords', arrayContains: lowerCaseQuery)
              .orderBy('createdAt', descending: true)
              .limit(20)
              .get();

      matches =
          matchResults.docs
              .map(
                (doc) => MatchModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
    } catch (e) {
      // If the indexed query fails, fall back to a simpler query
      print("Search index error: $e");
      print("Falling back to simple query without ordering");

      // Simple query without ordering - may not require an index
      final QuerySnapshot fallbackResults =
          await FirebaseFirestore.instance
              .collection('matches')
              .where('keywords', arrayContains: lowerCaseQuery)
              .limit(20)
              .get();

      matches =
          fallbackResults.docs
              .map(
                (doc) => MatchModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      // Sort in memory instead (not as efficient but works without index)
      matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return matches;
  },
);
