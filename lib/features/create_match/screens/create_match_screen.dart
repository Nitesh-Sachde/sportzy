import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/provider/add_players_provider.dart';
import 'package:sportzy/features/create_match/provider/match_form_provider.dart';
import 'package:sportzy/features/create_match/widgets/add_player_dialog.dart';
import 'package:sportzy/features/create_match/widgets/mode_selector.dart';
import 'package:sportzy/features/create_match/widgets/points_selector.dart';
import 'package:sportzy/features/create_match/widgets/set_selector.dart';
import 'package:sportzy/features/create_match/widgets/sport_selector.dart';
import 'package:sportzy/features/create_match/widgets/player_card.dart';
import 'package:sportzy/widgets/custom_appbar.dart';

class CreateMatchScreen extends ConsumerWidget {
  const CreateMatchScreen({super.key});

  void showSearchDialog(
    BuildContext context,
    WidgetRef ref,
    int teamNumber,
    bool isDoubles,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AddPlayerDialog(teamNumber: teamNumber, isDoubles: isDoubles),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);
    final form = ref.watch(matchFormProvider);
    final isDoubles = form.mode.toLowerCase() == "doubles";
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
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
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

              // Team 1 Input Section
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter Team 1 Name',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.018,
                    horizontal: screenWidth * 0.04,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged:
                    (val) => ref
                        .read(matchFormProvider.notifier)
                        .updateTeamName(1, val.trim()),
              ),
              SizedBox(height: screenHeight * 0.015),
              ...team1Players.map(
                (player) => PlayerCard(
                  player: player,
                  onRemove: () {
                    ref
                        .read(teamPlayersProvider(1).notifier)
                        .removePlayer(player);
                  },
                ),
              ),
              if (team1Players.length < (isDoubles ? 2 : 1))
                ElevatedButton(
                  onPressed: () => showSearchDialog(context, ref, 1, isDoubles),
                  child: const Text("Add Player"),
                ),
              SizedBox(height: screenHeight * 0.025),

              // Team 2 Input Section
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter Team 2 Name',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.018,
                    horizontal: screenWidth * 0.04,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged:
                    (val) => ref
                        .read(matchFormProvider.notifier)
                        .updateTeamName(2, val.trim()),
              ),
              SizedBox(height: screenHeight * 0.015),
              ...team2Players.map(
                (player) => PlayerCard(
                  player: player,
                  onRemove: () {
                    ref
                        .read(teamPlayersProvider(2).notifier)
                        .removePlayer(player);
                  },
                ),
              ),
              if (team2Players.length < (isDoubles ? 2 : 1))
                ElevatedButton(
                  onPressed: () => showSearchDialog(context, ref, 2, isDoubles),
                  child: const Text("Add Player"),
                ),
              SizedBox(height: screenHeight * 0.04),

              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter Match Location',
                  prefixIcon: Icon(Icons.location_on_rounded),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.018,
                    horizontal: screenWidth * 0.04,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged:
                    (val) => ref
                        .read(matchFormProvider.notifier)
                        .updateLocation(val),
              ),
              SizedBox(height: screenHeight * 0.04),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.065,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Validation & creation logic here
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    color: AppColors.white,
                    size: screenWidth * 0.06,
                  ),
                  iconAlignment: IconAlignment.end,
                  label: Text(
                    "Create",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
