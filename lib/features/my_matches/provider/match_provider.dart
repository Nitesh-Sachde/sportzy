import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/features/my_matches/model/my_match_model.dart'; // This import can be removed if it's no longer needed.
import 'package:cloud_firestore/cloud_firestore.dart';
// Importing the correct MatchModel

final matchListProvider = FutureProvider<List<MatchModel>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('matches').get();

  return snapshot.docs.map((doc) {
    // Assuming the Firestore document has the correct fields
    return MatchModel(
      matchId: doc['matchId'],
      sport: doc['sport'],
      mode: doc['mode'],
      team1Name: doc['team1Name'],
      team2Name: doc['team2Name'],
      team1Players: List<String>.from(doc['team1Players']),
      team2Players: List<String>.from(doc['team2Players']),
      location: doc['location'],
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
    );
  }).toList();
});

final matchProvider = FutureProvider.family<MatchModel, String>((
  ref,
  matchId,
) async {
  final doc =
      await FirebaseFirestore.instance.collection('matches').doc(matchId).get();

  if (!doc.exists) {
    throw Exception("Match not found");
  }

  return MatchModel.fromMap(
    doc.data()!,
  ); // Using the factory method to convert Firestore data
});
