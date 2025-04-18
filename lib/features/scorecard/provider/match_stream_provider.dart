import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/create_match/model/match_model.dart';

final matchStreamProvider = StreamProvider.family<MatchModel, String>((
  ref,
  matchId,
) {
  return FirebaseFirestore.instance
      .collection('matches')
      .doc(matchId)
      .snapshots()
      .map((doc) => MatchModel.fromMap(doc.data()!));
});
