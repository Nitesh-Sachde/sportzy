import 'package:flutter_riverpod/flutter_riverpod.dart';

final team1PlayersProvider = StateProvider<List<String>>((ref) => []);
final team2PlayersProvider = StateProvider<List<String>>((ref) => []);
final teamPlayersProvider =
    StateNotifierProvider.family<TeamPlayersNotifier, List<String>, int>((
      ref,
      teamNumber,
    ) {
      return TeamPlayersNotifier();
    });

class TeamPlayersNotifier extends StateNotifier<List<String>> {
  TeamPlayersNotifier() : super(['']); // Starts with 1 empty player

  void updatePlayer(int index, String name) {
    if (index < state.length) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) name else state[i],
      ];
    }
  }

  void addPlayer() {
    if (state.length < 2) {
      state = [...state, ''];
    }
  }
}
