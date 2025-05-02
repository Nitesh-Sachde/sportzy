// lib/features/scorecard/service/match_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core'; // Ensure dart:core is imported for Map type hint

class MatchService {
  static Future<void> updateMatchScores({
    required String matchId,
    required int currentSetIndex,
    required List<List<int>> scores,
  }) async {
    final Map<String, List<int>> scoresMap = {
      for (int i = 0; i < scores.length; i++) 'set_$i': scores[i],
    };

    await FirebaseFirestore.instance.collection('matches').doc(matchId).update({
      'scoresMap': scoresMap,
      'currentSetIndex': currentSetIndex,
    });
  }

  static Future<void> markMatchCompleted(String matchId) async {
    await FirebaseFirestore.instance.collection('matches').doc(matchId).update({
      'status': 'completed',
    });
  }

  static Future<void> deleteMatch(String matchId) async {
    try {
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .delete();
      return;
    } catch (e) {
      throw Exception('Failed to delete match: $e');
    }
  }
}
