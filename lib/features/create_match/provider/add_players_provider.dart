import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportzy/features/create_match/model/player_model.dart';

final teamPlayersProvider =
    StateNotifierProvider.family<TeamPlayersNotifier, List<Player>, int>(
      (ref, teamNumber) => TeamPlayersNotifier(teamNumber),
    );

class TeamPlayersNotifier extends StateNotifier<List<Player>> {
  TeamPlayersNotifier(this.teamNumber) : super([]);

  final int teamNumber;

  void addPlayer(Player player, bool isDoubles) {
    if (isDoubles && state.length >= 2) return;
    if (!isDoubles && state.isNotEmpty) return;
    if (!state.contains(player)) {
      state = [...state, player];
    }
  }

  void updatePlayer(int index, String name) {
    final updated = [...state];
    updated[index] = updated[index].copyWith(name: name);
    state = updated;
  }

  void removePlayer(Player player) {
    state = state.where((p) => p.id != player.id).toList();
  }

  void clearPlayers() {
    state = [];
  }

  /// 🔍 Search players from Firestore by name or keywords
  Future<List<Player>> searchPlayers(String query) async {
    final lowercaseQuery = query.toLowerCase();

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('keywords', arrayContains: lowercaseQuery)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Player(
        name: data['name'] ?? '',
        id: data['id'],
        keywords: List<String>.from(data['keywords'] ?? []),
      );
    }).toList();
  }
}
