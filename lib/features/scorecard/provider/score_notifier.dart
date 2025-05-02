import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/features/home/screen/past_match_scorecard.dart';
import 'package:sportzy/features/playerprofile/service/statistics_service.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';

// Update this provider
final scoreNotifierProvider =
    StateNotifierProvider.family<ScoreNotifier, List<List<int>>, String>((
      ref,
      matchId,
    ) {
      return ScoreNotifier(matchId: matchId);
    });

class ScoreNotifier extends StateNotifier<List<List<int>>> {
  final String matchId;

  // Initialize with a non-empty list to avoid range errors
  ScoreNotifier({required this.matchId})
    : super([
        [0, 0],
      ]);

  int _currentSetIndex = 0;
  bool _matchCompleted = false;
  bool _inDeuce = false;

  int get currentSetIndex => _currentSetIndex;
  bool get matchCompleted => _matchCompleted;
  bool get inDeuce => _inDeuce;

  void increaseScore(
    int teamIndex,
    int maxPoints,
    int totalSets,
    BuildContext context,
  ) async {
    if (_matchCompleted || teamIndex < 0 || teamIndex > 1) return;

    final updatedState = [...state];
    updatedState[_currentSetIndex][teamIndex]++;

    final team1 = updatedState[_currentSetIndex][0];
    final team2 = updatedState[_currentSetIndex][1];

    // Check for deuce situation
    if (team1 >= maxPoints - 1 &&
        team2 >= maxPoints - 1 &&
        (team1 - team2).abs() < 2) {
      _inDeuce = true;
      _showDeuceToast(context);
    } else {
      _inDeuce = false;
    }

    // Check for set win
    if ((team1 >= maxPoints || team2 >= maxPoints) &&
        (team1 - team2).abs() >= 2) {
      final winner = team1 > team2 ? 0 : 1;
      _showSnackBar(
        context,
        "Set ${_currentSetIndex + 1} won by Team ${winner + 1}",
      );

      _inDeuce = false; // Reset deuce state
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
        final winningTeamIndex = team1Wins > team2Wins ? 0 : 1;
        final winningTeamName = winningTeamIndex == 0 ? 'Team 1' : 'Team 2';

        // Add a better try-catch with more specific error messages
        try {
          // Get the winning player IDs
          final List<String> winnerPlayerIds = await _fetchTeamPlayerIds(
            matchId,
            winningTeamIndex == 0,
          );

          // Update match status in Firebase
          await FirebaseFirestore.instance
              .collection("matches")
              .doc(matchId)
              .update({
                "status": "completed",
                "winner": winningTeamIndex == 0 ? "team1" : "team2",
                "completedAt": FieldValue.serverTimestamp(),
              });

          // Get match data for statistics update
          final matchDoc =
              await FirebaseFirestore.instance
                  .collection("matches")
                  .doc(matchId)
                  .get();

          if (!matchDoc.exists || matchDoc.data() == null) {
            throw Exception("Match document not found");
          }

          // Update statistics
          final statisticsService = StatisticsService();
          final matchModel = MatchModel.fromMap(matchDoc.data()!);
          await statisticsService.updateStatisticsAfterMatch(
            matchModel,
            winnerPlayerIds,
          );

          // Show success message
          _showSnackBar(context, "🎉 $winningTeamName won the match!");

          // Redirect after a brief delay
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PastMatchScoreCard(matchId: matchId),
                ),
              );
            }
          });
        } catch (e) {
          print("Error finalizing match: $e");
          _showSnackBar(
            context,
            "Error finalizing match: ${e.toString().split('\n')[0]}",
          );
        }
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

  void _showDeuceToast(BuildContext context) {
    // Create a deuce overlay notification
    final overlay = Overlay.of(context);
    final deuceOverlay = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width,
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(230),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    "DEUCE!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(deuceOverlay);

    // Remove the overlay after a delay
    Future.delayed(const Duration(seconds: 2), () {
      deuceOverlay.remove();
    });
  }

  Future<List<String>> _fetchTeamPlayerIds(String matchId, bool isTeam1) async {
    try {
      final matchDoc =
          await FirebaseFirestore.instance
              .collection("matches")
              .doc(matchId)
              .get();

      if (matchDoc.exists) {
        final matchData = matchDoc.data()!;
        final List<dynamic> players =
            isTeam1 ? matchData['team1Players'] : matchData['team2Players'];

        // Properly cast the dynamic list to List<String>
        return players.map((p) => p.toString()).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching team players: $e");
      return []; // Return empty list on error
    }
  }
}
