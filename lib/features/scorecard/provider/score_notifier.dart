import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/features/home/screen/past_match_scorecard.dart';
import 'package:sportzy/features/playerprofile/service/statistics_service.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'dart:developer' as developer;

// Add these providers for deuce state management
final deuceStateProvider = StateProvider.family<DeuceState, String>((
  ref,
  matchId,
) {
  return DeuceState.none;
});

final advantageTeamProvider = StateProvider.family<int?, String>((
  ref,
  matchId,
) {
  return null; // null = no advantage, 0 = team1, 1 = team2
});

// Define deuce states
enum DeuceState { none, deuce, advantage }

// Update this provider
final scoreNotifierProvider =
    StateNotifierProvider.family<ScoreNotifier, List<List<int>>, String>((
      ref,
      matchId,
    ) {
      return ScoreNotifier(ref: ref, matchId: matchId);
    });

class ScoreNotifier extends StateNotifier<List<List<int>>> {
  final String matchId;
  final Ref ref;

  // Initialize with a non-empty list to avoid range errors
  ScoreNotifier({required this.matchId, required this.ref})
    : super([
        [0, 0],
      ]);

  int _currentSetIndex = 0;
  bool _matchCompleted = false;

  // We'll use the providers instead of these fields
  // bool _inDeuce = false;
  // int? _advantageTeam = null;

  int get currentSetIndex => _currentSetIndex;
  bool get matchCompleted => _matchCompleted;
  bool get inDeuce => ref.read(deuceStateProvider(matchId)) == DeuceState.deuce;
  int? get advantageTeam => ref.read(advantageTeamProvider(matchId));
  bool get isAdvantage =>
      ref.read(deuceStateProvider(matchId)) == DeuceState.advantage;

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

    final currentDeuceState = ref.read(deuceStateProvider(matchId));
    final currentAdvantageTeam = ref.read(advantageTeamProvider(matchId));

    // Handle deuce and advantage states
    if (team1 >= maxPoints - 1 && team2 >= maxPoints - 1) {
      if (team1 == team2) {
        // It's a deuce
        ref.read(deuceStateProvider(matchId).notifier).state = DeuceState.deuce;
        ref.read(advantageTeamProvider(matchId).notifier).state = null;
        _showDeuceToast(context, "DEUCE!");
      } else if ((team1 - team2).abs() == 1) {
        // It's an advantage
        ref.read(deuceStateProvider(matchId).notifier).state =
            DeuceState.advantage;
        ref.read(advantageTeamProvider(matchId).notifier).state =
            team1 > team2 ? 0 : 1;

        final advantageTeam = team1 > team2 ? "Team 1" : "Team 2";
        _showDeuceToast(context, "ADVANTAGE $advantageTeam!");
      } else if ((team1 - team2).abs() >= 2) {
        // Set is won
        ref.read(deuceStateProvider(matchId).notifier).state = DeuceState.none;
        ref.read(advantageTeamProvider(matchId).notifier).state = null;
      }
    }

    // Check for set win
    if ((team1 >= maxPoints || team2 >= maxPoints) &&
        (team1 - team2).abs() >= 2) {
      // Current set is completed
      final winner = team1 > team2 ? 0 : 1;
      _showSnackBar(
        context,
        "Set ${_currentSetIndex + 1} won by Team ${winner + 1}",
      );

      // Reset deuce state
      ref.read(deuceStateProvider(matchId).notifier).state = DeuceState.none;
      ref.read(advantageTeamProvider(matchId).notifier).state = null;

      _currentSetIndex++;

      // Add new set if needed
      if (_currentSetIndex >= updatedState.length &&
          _currentSetIndex < totalSets) {
        updatedState.add([0, 0]);
      }

      // Count set wins
      int team1Wins = 0;
      int team2Wins = 0;
      for (var s in updatedState) {
        if (s[0] > s[1]) {
          team1Wins++;
        } else if (s[1] > s[0]) {
          team2Wins++;
        }
      }

      // Check if match is completed
      final requiredWins = (totalSets / 2).ceil();
      if (team1Wins == requiredWins || team2Wins == requiredWins) {
        _matchCompleted = true;
        final winningTeamIndex = team1Wins > team2Wins ? 0 : 1;
        final winningTeamName = winningTeamIndex == 0 ? 'Team 1' : 'Team 2';

        try {
          // Show loading overlay before proceeding
          final loadingOverlay = OverlayEntry(
            builder:
                (context) => Material(
                  color: Colors.black.withAlpha(128), // 0.5 opacity = 128 alpha
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LoadingAnimationWidget.staggeredDotsWave(
                            color: AppColors.primary,
                            size: 50,
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Finalizing match...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          );

          // Insert the loading overlay
          if (context.mounted) {
            Overlay.of(context).insert(loadingOverlay);
          }

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

          // Remove loading overlay after all operations complete
          if (context.mounted) {
            loadingOverlay.remove();
          }

          // Redirect after a brief delay with loading animation
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (_, __, ___) => PastMatchScoreCard(matchId: matchId),
                transitionDuration: Duration(milliseconds: 500),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }
        } catch (e) {
          developer.log("Error finalizing match: $e", name: 'ScoreNotifier');
          _showSnackBar(
            context,
            "Error finalizing match: ${e.toString().split('\n')[0]}",
          );
        }
      }
    }

    state = updatedState;
  }

  void decreaseScore(int teamIndex, int maxPoints) {
    if (_matchCompleted || teamIndex < 0 || teamIndex > 1) return;

    final updatedState = [...state];
    if (_currentSetIndex >= updatedState.length) return;
    if (updatedState[_currentSetIndex][teamIndex] > 0) {
      updatedState[_currentSetIndex][teamIndex]--;

      final team1 = updatedState[_currentSetIndex][0];
      final team2 = updatedState[_currentSetIndex][1];

      // Update deuce/advantage states when decreasing score
      if (team1 >= maxPoints - 1 && team2 >= maxPoints - 1) {
        if (team1 == team2) {
          // It's a deuce
          ref.read(deuceStateProvider(matchId).notifier).state =
              DeuceState.deuce;
          ref.read(advantageTeamProvider(matchId).notifier).state = null;
        } else if ((team1 - team2).abs() == 1) {
          // It's an advantage
          ref.read(deuceStateProvider(matchId).notifier).state =
              DeuceState.advantage;
          ref.read(advantageTeamProvider(matchId).notifier).state =
              team1 > team2 ? 0 : 1;
        } else {
          ref.read(deuceStateProvider(matchId).notifier).state =
              DeuceState.none;
          ref.read(advantageTeamProvider(matchId).notifier).state = null;
        }
      } else {
        ref.read(deuceStateProvider(matchId).notifier).state = DeuceState.none;
        ref.read(advantageTeamProvider(matchId).notifier).state = null;
      }

      state = updatedState;
    }
  }

  // In the loadExistingScores method, fetch maxPoints and update the check:
  // First, add a parameter to receive maxPoints
  void loadExistingScores(
    List<List<int>> existingScores, {
    int maxPoints = 21,
  }) {
    state = existingScores;
    _currentSetIndex = currentSetIndex;
    _matchCompleted = false;

    // Reset deuce and advantage states
    ref.read(deuceStateProvider(matchId).notifier).state = DeuceState.none;
    ref.read(advantageTeamProvider(matchId).notifier).state = null;

    // Check if current score is in deuce or advantage
    if (existingScores.isNotEmpty && _currentSetIndex < existingScores.length) {
      final currentSet = existingScores[_currentSetIndex];
      if (currentSet.length >= 2) {
        final team1 = currentSet[0];
        final team2 = currentSet[1];

        if (team1 >= maxPoints - 1 && team2 >= maxPoints - 1) {
          if (team1 == team2) {
            ref.read(deuceStateProvider(matchId).notifier).state =
                DeuceState.deuce;
          } else if ((team1 - team2).abs() == 1) {
            ref.read(deuceStateProvider(matchId).notifier).state =
                DeuceState.advantage;
            ref.read(advantageTeamProvider(matchId).notifier).state =
                team1 > team2 ? 0 : 1;
          }
        }
      }
    }
  }

  void reset() {
    _matchCompleted = false;
    _currentSetIndex = 0;
    ref.read(deuceStateProvider(matchId).notifier).state = DeuceState.none;
    ref.read(advantageTeamProvider(matchId).notifier).state = null;
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

  void _showDeuceToast(BuildContext context, String message) {
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
                    color:
                        message.contains("DEUCE")
                            ? Colors.red.withAlpha(230)
                            : Colors.green.withAlpha(230),
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
                    message,
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
      developer.log("Error fetching team players: $e", name: 'ScoreNotifier');
      return []; // Return empty list on error
    }
  }
}
