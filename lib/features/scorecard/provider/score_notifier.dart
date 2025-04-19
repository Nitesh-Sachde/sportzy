import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/features/home/screen/past_match_scorecard.dart';

final scoreNotifierProvider =
    StateNotifierProvider.family<ScoreNotifier, List<List<int>>, String>((
      ref,
      matchId,
    ) {
      return ScoreNotifier(matchId: matchId);
    });

class ScoreNotifier extends StateNotifier<List<List<int>>> {
  final String matchId;
  ScoreNotifier({required this.matchId}) : super([[]]);
  int _currentSetIndex = 0;
  bool _matchCompleted = false;

  int get currentSetIndex => _currentSetIndex;
  bool get matchCompleted => _matchCompleted;

  void increaseScore(
    int teamIndex,
    int maxPoints,
    int totalSets,
    BuildContext context,
  ) {
    if (_matchCompleted || teamIndex < 0 || teamIndex > 1) return;

    final updatedState = [...state];
    updatedState[_currentSetIndex][teamIndex]++;

    final team1 = updatedState[_currentSetIndex][0];
    final team2 = updatedState[_currentSetIndex][1];

    if ((team1 >= maxPoints || team2 >= maxPoints) &&
        (team1 - team2).abs() >= 2) {
      final winner = team1 > team2 ? 0 : 1;
      _showSnackBar(
        context,
        "Set ${_currentSetIndex + 1} won by Team ${winner + 1}",
      );

      _currentSetIndex++;

      int team1Wins = 0;
      int team2Wins = 0;
      for (var s in updatedState) {
        if (s[0] > s[1])
          team1Wins++;
        else if (s[1] > s[0])
          team2Wins++;
      }

      final requiredWins = (totalSets / 2).ceil();
      if (team1Wins == requiredWins || team2Wins == requiredWins) {
        _matchCompleted = true;
        final winningTeamName = team1Wins > team2Wins ? 'Team 1' : 'Team 2';

        _showSnackBar(context, "🎉 $winningTeamName won the match!");

        // 🔥 Update match status in Firebase
        FirebaseFirestore.instance.collection("matches").doc(matchId).update({
          "status": "completed",
        });

        // 🧭 Redirect to PastMatchScoreCard

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PastMatchScoreCard(matchId: matchId),
          ),
        );
      }
    }

    state = updatedState;
  }

  void decreaseScore(int teamIndex) {
    if (_matchCompleted || teamIndex < 0 || teamIndex > 1) return;

    final updatedState = [...state];
    if (_currentSetIndex >= updatedState.length) return;
    if (updatedState[_currentSetIndex][teamIndex] > 0) {
      updatedState[_currentSetIndex][teamIndex]--;
      state = updatedState;
    }
  }

  void loadExistingScores(List<List<int>> existingScores) {
    state = existingScores;
    _currentSetIndex = currentSetIndex;
    _matchCompleted = false;
  }

  void reset() {
    _matchCompleted = false;
    _currentSetIndex = 0;
    state = [
      [0, 0],
    ];
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }
}
