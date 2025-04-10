import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for team1 players
final team1Provider = StateNotifierProvider<TeamNotifier, List<String>>(
  (ref) => TeamNotifier(),
);

/// State for team2 players
final team2Provider = StateNotifierProvider<TeamNotifier, List<String>>(
  (ref) => TeamNotifier(),
);

class TeamNotifier extends StateNotifier<List<String>> {
  TeamNotifier() : super([]);

  /// Add player to team
  void addPlayer(String playerName) {
    if (state.length < 2 && playerName.trim().isNotEmpty) {
      state = [...state, playerName.trim()];
    }
  }

  /// Remove player by index
  void removePlayer(int index) {
    if (index >= 0 && index < state.length) {
      final newState = [...state]..removeAt(index);
      state = newState;
    }
  }

  /// Clear team list
  void clearTeam() {
    state = [];
  }

  /// Replace entire team (e.g. from modal)
  void setTeam(List<String> newTeam) {
    state = newTeam.map((e) => e.trim()).toList();
  }
}
