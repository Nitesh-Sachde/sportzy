import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/add_players_provider.dart';

class PlayerAddButton extends ConsumerWidget {
  final int teamNumber;

  const PlayerAddButton({super.key, required this.teamNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          ref.read(teamPlayersProvider(teamNumber).notifier).addPlayer();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Player"),
      ),
    );
  }
}
