import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/provider/add_players_provider.dart';
import 'package:sportzy/features/create_match/provider/match_form_provider.dart';
import 'package:sportzy/features/create_match/widgets/mode_selector.dart';
import 'package:sportzy/features/create_match/widgets/points_selector.dart';
import 'package:sportzy/features/create_match/widgets/set_selector.dart';
import 'package:sportzy/features/create_match/widgets/sport_selector.dart';
import 'package:sportzy/features/create_match/widgets/team_input_field.dart';
import 'package:sportzy/features/create_match/widgets/player_add_button.dart';
import 'package:sportzy/widgets/custom_appbar.dart';

class CreateMatchScreen extends ConsumerWidget {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    final form = ref.watch(matchFormProvider);
    final team1Players = ref.watch(teamPlayersProvider(1));
    final team2Players = ref.watch(teamPlayersProvider(2));
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: CustomAppBar(
        title: "Match Details",
        isBackButtonVisible: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),

        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter Match Details Below",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: screenHeight * 0.023,
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                const SportSelector(),
                SizedBox(height: screenHeight * 0.025),
                const ModeSelector(),
                SizedBox(height: screenHeight * 0.025),
                const SetSelector(),
                SizedBox(height: screenHeight * 0.025),
                PointsSelector(),
                SizedBox(height: screenHeight * 0.025),

                TeamInputField(
                  teamTitle: 'Team 1',
                  players: team1Players,
                  isDoubles: form.isDoubles,
                  onChanged: (index, name) {
                    ref
                        .read(teamPlayersProvider(1).notifier)
                        .updatePlayer(index, name);
                  },
                ),
                SizedBox(height: screenHeight * 0.015),
                const PlayerAddButton(teamNumber: 1),

                SizedBox(height: screenHeight * 0.025),

                TeamInputField(
                  teamTitle: 'Team 2',
                  players: team2Players,
                  isDoubles: form.isDoubles,
                  onChanged: (index, name) {
                    ref
                        .read(teamPlayersProvider(2).notifier)
                        .updatePlayer(index, name);
                  },
                ),
                SizedBox(height: screenHeight * 0.015),
                const PlayerAddButton(teamNumber: 2),

                SizedBox(height: screenHeight * 0.03),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Match Location",
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  onChanged:
                      (val) => ref
                          .read(matchFormProvider.notifier)
                          .updateLocation(val.trim()),
                ),
                SizedBox(height: screenHeight * 0.04),
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.065,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Validation logic will be triggered here
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Player Details"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
