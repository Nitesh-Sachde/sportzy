import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:sportzy/features/home/screen/live_scorecard_screen.dart';
import 'package:sportzy/features/home/screen/past_match_scorecard.dart';

class LiveMatchCard extends ConsumerWidget {
  final MatchModel match;

  const LiveMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);
    final cardColor =
        match.sport == 'Badminton'
            ? AppColors.badmintoncardBackground
            : AppColors.ttcardBackground;
    final isDoubles = match.mode.toLowerCase().contains('doubles');

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LiveScorecardScreen(matchId: match.matchId),
            ),
          ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.012,
          vertical: screenHeight * 0.01,
        ),
        width: screenWidth * 0.9,
        height: screenHeight * 0.32,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child:
            match.sport == 'Badminton'
                ? _buildBadmintonCard(
                  context,
                  isDoubles,
                  screenWidth,
                  screenHeight,
                )
                : _buildTableTennisCard(
                  context,
                  isDoubles,
                  screenWidth,
                  screenHeight,
                ),
      ),
    );
  }

  Widget _buildBadmintonCard(
    BuildContext context,
    bool isDoubles,
    double screenWidth,
    double screenHeight,
  ) {
    final currentScores = match.scores[match.currentSetIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${match.sport} ${isDoubles ? "Doubles" : "Singles"}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
            ),
            Text(
              match.matchId,
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.045,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.white),
                Text(
                  match.location,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
            SizedBox(width: screenWidth * 0.06),
            Text(
              DateFormat("MMMM d, yyyy h:mm a").format(match.createdAt),
              style: TextStyle(
                color: AppColors.white,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.007),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bTeamBarBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: AppColors.bTeamBarBackground, blurRadius: 2),
              ],
            ),
            width: screenWidth * 1,
            height: screenHeight * 0.04,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    match.team1Name,
                    style: TextStyle(
                      color: AppColors.bTeamNametext,
                      fontSize: screenWidth * 0.06,
                    ),
                  ),
                ),
                Text(
                  "vs",
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                Text(
                  match.team2Name,
                  style: TextStyle(
                    color: AppColors.bTeamNametext,
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.012),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ScoreBox(
                  score: '${currentScores[0]}',
                  playerName1:
                      match.team1PlayerName.isNotEmpty
                          ? match.team1PlayerName[0]
                          : '',
                  playerName2:
                      isDoubles && match.team1PlayerName.length > 1
                          ? match.team1PlayerName[1]
                          : null,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Text(
                  "SET ${match.currentSetIndex + 1}",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ScoreBox(
                  score: '${currentScores[1]}',
                  playerName1:
                      match.team2PlayerName.isNotEmpty
                          ? match.team2PlayerName[0]
                          : '',
                  playerName2:
                      isDoubles && match.team2PlayerName.length > 1
                          ? match.team2PlayerName[1]
                          : null,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "View Match",
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Icon(Icons.arrow_circle_right_rounded, color: AppColors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildTableTennisCard(
    BuildContext context,
    bool isDoubles,
    double screenWidth,
    double screenHeight,
  ) {
    final currentScores = match.scores[match.currentSetIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${match.sport} ${isDoubles ? "Doubles" : "Singles"}",
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
            ),
            Text(
              match.matchId,
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.045,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.black),

                Text(
                  match.location,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
            SizedBox(width: screenWidth * 0.06),
            Text(
              DateFormat("MMMM d, yyyy h:mm a").format(match.createdAt),
              style: TextStyle(
                color: AppColors.black,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.007),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.ttTeamBarBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: AppColors.ttTeamBarBackground, blurRadius: 2),
              ],
            ),
            width: screenWidth * 1,
            height: screenHeight * 0.04,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    match.team1Name,
                    style: TextStyle(
                      color: AppColors.ttTeamNametext,
                      fontSize: screenWidth * 0.06,
                    ),
                  ),
                ),
                Text(
                  "vs",
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                Text(
                  match.team2Name,
                  style: TextStyle(
                    color: AppColors.ttTeamNametext,
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.012),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ScoreBox(
                  score: '${currentScores[0]}',
                  playerName1:
                      match.team1PlayerName.isNotEmpty
                          ? match.team1PlayerName[0]
                          : '',
                  playerName2:
                      isDoubles && match.team1PlayerName.length > 1
                          ? match.team1PlayerName[1]
                          : null,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Text(
                  "SET ${match.currentSetIndex + 1}",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ScoreBox(
                  score: '${currentScores[1]}',
                  playerName1:
                      match.team2PlayerName.isNotEmpty
                          ? match.team2PlayerName[0]
                          : '',
                  playerName2:
                      isDoubles && match.team2PlayerName.length > 1
                          ? match.team2PlayerName[1]
                          : null,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "View Match",
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Icon(Icons.arrow_circle_right_rounded, color: AppColors.red),
          ],
        ),
      ],
    );
  }
}

class PastMatchCard extends ConsumerStatefulWidget {
  final MatchModel match;

  const PastMatchCard({required this.match, super.key});

  @override
  ConsumerState<PastMatchCard> createState() => _PastMatchCardState();
}

class _PastMatchCardState extends ConsumerState<PastMatchCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);
    final isDoubles = widget.match.team1PlayerName.length > 1;
    final sport = widget.match.sport;

    final cardColor =
        sport == 'Badminton'
            ? AppColors.badmintoncardBackground
            : AppColors.ttcardBackground;

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      PastMatchScoreCard(matchId: widget.match.matchId),
            ),
          ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.012,
          vertical: screenHeight * 0.01,
        ),
        width: screenWidth * 0.9,
        height: screenHeight * 0.35,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: EdgeInsets.all(screenWidth * 0.027),
        child:
            sport == 'Badminton'
                ? _buildBadmintonPastCard(
                  context,
                  isDoubles,
                  screenWidth,
                  screenHeight,
                )
                : _buildTableTennisPastCard(
                  context,
                  isDoubles,
                  screenWidth,
                  screenHeight,
                ),
      ),
    );
  }

  Widget _buildBadmintonPastCard(
    BuildContext context,
    bool isDoubles,
    double screenWidth,
    double screenHeight,
  ) {
    // Determine the winner
    int team1Wins = 0;
    int team2Wins = 0;
    for (final setScore in widget.match.scores) {
      if (setScore[0] > setScore[1])
        team1Wins++;
      else if (setScore[1] > setScore[0])
        team2Wins++;
    }
    final winningTeam =
        team1Wins > team2Wins ? widget.match.team1Name : widget.match.team2Name;
    final winningPlayers =
        team1Wins > team2Wins
            ? widget.match.team1PlayerName.join(', ')
            : widget.match.team2PlayerName.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${widget.match.sport} ${isDoubles ? "Doubles" : "Singles"}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
            ),
            Text(
              widget.match.matchId,
              style: TextStyle(
                color: AppColors.amber,
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.045,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.white),
                Text(
                  widget.match.location,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),

            Text(
              DateFormat("MMMM d, yyyy h:mm a").format(widget.match.createdAt),
              style: TextStyle(
                color: AppColors.white,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/badminton_trophy.webp",
              alignment: Alignment.center,
              scale: 3.4,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
              height: screenHeight * 0.1,
              width: screenWidth * 0.45,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: AppColors.grey, blurRadius: 4),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    winningTeam,
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.07,
                    ),
                  ),

                  Text(
                    "Won the match",
                    style: TextStyle(
                      color: AppColors.bTeamNametext,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "View Match",
              style: TextStyle(
                color: AppColors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Icon(Icons.arrow_circle_right_rounded, color: AppColors.amber),
          ],
        ),
      ],
    );
  }

  Widget _buildTableTennisPastCard(
    BuildContext context,
    bool isDoubles,
    double screenWidth,
    double screenHeight,
  ) {
    // Determine the winner
    int team1Wins = 0;
    int team2Wins = 0;
    for (final setScore in widget.match.scores) {
      if (setScore[0] > setScore[1])
        team1Wins++;
      else if (setScore[1] > setScore[0])
        team2Wins++;
    }
    final winningTeam =
        team1Wins > team2Wins ? widget.match.team1Name : widget.match.team2Name;
    final winningPlayers =
        team1Wins > team2Wins
            ? widget.match.team1PlayerName.join(', ')
            : widget.match.team2PlayerName.join(', ');

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${widget.match.sport} ${isDoubles ? "Doubles" : "Singles"}",
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
            ),
            Text(
              widget.match.matchId,
              style: TextStyle(
                color: AppColors.amber,
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.045,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.black),
                Text(
                  widget.match.location,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),

            Text(
              DateFormat("MMMM d, yyyy h:mm a").format(widget.match.createdAt),
              style: TextStyle(
                color: AppColors.black,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/table_tennis_trophy.webp",
              alignment: Alignment.center,
              scale: 3.5,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
              height: screenHeight * 0.12,
              width: screenWidth * 0.45,
              decoration: BoxDecoration(
                color: AppColors.ttTeamWonBG,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: AppColors.ttTeamWonBG, blurRadius: 4),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    winningTeam,
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.07,
                    ),
                  ),

                  Text(
                    "Won the match",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "View Match",
              style: TextStyle(
                color: AppColors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Icon(Icons.arrow_circle_right_rounded, color: AppColors.amber),
          ],
        ),
      ],
    );
  }
}

class ScoreBox extends StatelessWidget {
  final String score;
  final String playerName1;
  final String? playerName2;

  const ScoreBox({
    super.key,
    required this.score,
    required this.playerName1,
    this.playerName2,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          decoration: BoxDecoration(
            color: AppColors.amber,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            score,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenHeight * 0.025,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          playerName1,
          style: TextStyle(
            color: AppColors.white,
            fontSize: screenWidth * 0.045,
          ),
        ),
        if (playerName2 != null)
          Text(
            playerName2!,
            style: TextStyle(
              color: AppColors.white,
              fontSize: screenWidth * 0.045,
            ),
          ),
      ],
    );
  }
}
