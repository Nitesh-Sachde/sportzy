import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/provider/add_players_provider.dart';

class AddPlayersSheet extends ConsumerStatefulWidget {
  final bool isDoubles;

  const AddPlayersSheet({super.key, required this.isDoubles});

  @override
  ConsumerState<AddPlayersSheet> createState() => _AddPlayersSheetState();
}

class _AddPlayersSheetState extends ConsumerState<AddPlayersSheet> {
  final _formKey = GlobalKey<FormState>();
  final _team1Controllers = [TextEditingController(), TextEditingController()];
  final _team2Controllers = [TextEditingController(), TextEditingController()];

  @override
  void dispose() {
    for (final c in _team1Controllers) {
      c.dispose();
    }
    for (final c in _team2Controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _savePlayers() {
    if (_formKey.currentState!.validate()) {
      final team1 =
          _team1Controllers
              .where((c) => c.text.trim().isNotEmpty)
              .map((c) => c.text.trim())
              .toList();
      final team2 =
          _team2Controllers
              .where((c) => c.text.trim().isNotEmpty)
              .map((c) => c.text.trim())
              .toList();

      ref.read(team1PlayersProvider.notifier).state = team1;
      ref.read(team2PlayersProvider.notifier).state = team2;

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);
    final players = widget.isDoubles ? 2 : 1;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      height: screenHeight * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              "Add Players",
              style: TextStyle(
                fontSize: screenHeight * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Team 1
            Text(
              "Team 1",
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...List.generate(
              players,
              (i) => _buildPlayerField(_team1Controllers[i], "Player ${i + 1}"),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Team 2
            Text(
              "Team 2",
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...List.generate(
              players,
              (i) => _buildPlayerField(_team2Controllers[i], "Player ${i + 1}"),
            ),

            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              onPressed: _savePlayers,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(screenWidth * 0.8, screenHeight * 0.06),
              ),
              child: const Text("Save Players"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerField(TextEditingController controller, String label) {
    final screenHeight = ScreenSize.screenHeight(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: TextFormField(
        controller: controller,
        validator:
            (value) => value!.trim().isEmpty ? "Player name required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
