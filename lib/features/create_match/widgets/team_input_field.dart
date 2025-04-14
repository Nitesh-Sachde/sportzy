import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/models/player_model.dart';

class TeamInputField extends ConsumerWidget {
  final String teamTitle;
  final List<Player> players;
  final bool isDoubles;
  final Function(int, String) onChanged;

  const TeamInputField({
    super.key,
    required this.teamTitle,
    required this.players,
    required this.isDoubles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);
    final expectedCount = isDoubles ? 2 : 1;

    // Pad the players list with empty Player objects if needed
    final paddedPlayers = List.generate(
      expectedCount,
      (index) =>
          index < players.length ? players[index] : Player(name: '', id: ''),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamTitle,
          style: TextStyle(
            fontSize: screenHeight * 0.022,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        ...List.generate(isDoubles ? 2 : 1, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.015),
            child: TextFormField(
              initialValue: paddedPlayers[index].name,
              onChanged: (value) => onChanged(index, value),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Player name required';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter Team Name',
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.018,
                  horizontal: screenWidth * 0.04,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
