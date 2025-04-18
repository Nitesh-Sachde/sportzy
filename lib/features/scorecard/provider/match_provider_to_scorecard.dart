import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';

final matchByIdProvider = StreamProvider.family<MatchModel, String>((
  ref,
  matchId,
) {
  return FirebaseFirestore.instance
      .collection('matches')
      .doc(matchId)
      .snapshots()
      .map((doc) => MatchModel.fromMap(doc.data()!));
});
final playerNameProvider = StreamProvider.family<String, String>((ref, name) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc('id')
      .snapshots()
      .map((doc) => name = name);
});
