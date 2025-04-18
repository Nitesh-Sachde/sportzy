import 'package:flutter_riverpod/flutter_riverpod.dart';

final scoreNotifierProvider =
    StateNotifierProvider.family<ScoreNotifier, List<List<int>>, String>((
      ref,
      matchId,
    ) {
      return ScoreNotifier();
    });

class ScoreNotifier extends StateNotifier<List<List<int>>> {
  ScoreNotifier()
    : super([
        [0, 0],
      ]); // Start with one set

  int _currentSetIndex = 0;

  int get currentSetIndex {
    if (state.isEmpty) return 0;
    return _currentSetIndex.clamp(0, state.length - 1);
  }

  set currentSetIndex(int value) {
    if (state.isEmpty) {
      _currentSetIndex = 0;
    } else {
      _currentSetIndex = value.clamp(0, state.length - 1);
    }
  }

  void increaseScore(int teamIndex) {
    if (teamIndex < 0 || teamIndex >= 2) return;

    final updatedState = [...state];

    // Validate current index
    if (_currentSetIndex >= updatedState.length) {
      updatedState.add([0, 0]);
      _currentSetIndex = updatedState.length - 1;
    }

    // Validate inner score list
    if (updatedState[_currentSetIndex].length != 2) {
      updatedState[_currentSetIndex] = [0, 0];
    }

    updatedState[_currentSetIndex][teamIndex]++;
    state = updatedState;
  }

  void decreaseScore(int teamIndex) {
    if (teamIndex < 0 || teamIndex >= 2) return;

    final updatedState = [...state];

    // Ensure currentSetIndex is valid
    if (_currentSetIndex >= updatedState.length) return;

    // Ensure current set has exactly two scores
    if (updatedState[_currentSetIndex].length != 2) {
      updatedState[_currentSetIndex] = [0, 0];
    }

    // Only decrease if score is greater than zero
    if (updatedState[_currentSetIndex][teamIndex] > 0) {
      updatedState[_currentSetIndex][teamIndex]--;
      state = updatedState;
    }
  }

  void addNewSet() {
    final updatedState = [
      ...state,
      [0, 0],
    ];
    state = updatedState;
    _currentSetIndex = updatedState.length - 1;
  }

  void loadExistingScores(List<List<int>> existingScores) {
    if (existingScores.isEmpty || existingScores.any((s) => s.length != 2)) {
      state = [
        [0, 0],
      ];
      _currentSetIndex = 0;
    } else {
      state = existingScores;
      _currentSetIndex = existingScores.length - 1;
    }
  }
}
