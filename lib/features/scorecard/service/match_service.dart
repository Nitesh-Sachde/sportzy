// lib/features/scorecard/service/match_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core'; // Ensure dart:core is imported for Map type hint

class MatchService {
  static Future<void> updateMatchScores({
    required String matchId,
    required List<List<int>> scores,
  }) async {
    final Map<String, List<int>> scoresMap = {
      for (int i = 0; i < scores.length; i++) 'set_$i': scores[i],
    };

    await FirebaseFirestore.instance.collection('matches').doc(matchId).update({
      'scoresMap': scoresMap,
      'currentSetIndex': scores.length - 1,
    });
  }

  static Future<void> markMatchCompleted(String matchId) async {
    await FirebaseFirestore.instance.collection('matches').doc(matchId).update({
      'status': 'completed',
    });
  }
}
