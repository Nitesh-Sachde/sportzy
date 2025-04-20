import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/dynamic_link_service.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:sportzy/features/scorecard/provider/match_provider_to_scorecard.dart';
import 'package:sportzy/widgets/custom_appbar.dart';
import 'package:intl/intl.dart';

class PastMatchScoreCard extends ConsumerStatefulWidget {
  final String matchId;

  const PastMatchScoreCard({super.key, required this.matchId});

  @override
  ConsumerState<PastMatchScoreCard> createState() => _PastMatchScoreCardState();
}

class _PastMatchScoreCardState extends ConsumerState<PastMatchScoreCard> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);
    final matchAsync = ref.watch(matchByIdProvider(widget.matchId));
    final matchId = widget.matchId;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: AppColors.primary,
      appBar: CustomAppBar(
        title: "Match Result",
        showShare: true,
        isBackButtonVisible: true,
        onShare: () async {
          final shortLink = await DynamicLinkService.createMatchDynamicLink(
            widget.matchId,
          );
          Share.share('Check out this match on Sportzy: $shortLink');
        },
      ),
      body: matchAsync.when(
        loading:
            () => Scaffold(
              body: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primary,
                  size: screenWidth * 0.2,
                ),
              ),
            ),
        error: (error, _) => Center(child: Text("Error: $error")),
        data: (match) {
          if (!_initialized) {
            Future.microtask(() {
              setState(() {
                _initialized = true;
              });
            });
          }

          // Calculate which team won the match
          int team1Wins = 0;
          int team2Wins = 0;
          for (var set in match.scores) {
            if (set[0] > set[1]) {
              team1Wins++;
            } else if (set[1] > set[0]) {
              team2Wins++;
            }
          }

          final team1IsWinner = team1Wins > team2Wins;
          final team2IsWinner = team2Wins > team1Wins;
          final requiredWins = (match.sets / 2).ceil();
          final matchCompleted =
              team1Wins >= requiredWins || team2Wins >= requiredWins;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SizedBox(
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // SizedBox(height: screenHeight * 0.005),
                    if (matchCompleted)
                      _buildMatchResult(
                        screenHeight,
                        screenWidth,
                        team1IsWinner ? match.team1Name : match.team2Name,
                      ),

                    _buildMatchInfoCard(
                      screenHeight,
                      screenWidth,
                      match,
                      match.sport.toLowerCase() == 'badminton',
                      team1IsWinner,
                      team2IsWinner,
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    // Show all sets
                    _buildSetHistory(screenHeight, screenWidth, match.scores),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchInfoCard(
    double screenHeight,
    double screenWidth,
    MatchModel match,
    bool isBadminton,
    bool team1IsWinner,
    bool team2IsWinner,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        // vertical: screenHeight * 0.015,
      ),

      padding: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color:
            isBadminton
                ? AppColors.badmintoncardBackground
                : AppColors.ttcardBackground,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black,
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match ID Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            decoration: const BoxDecoration(
              color: AppColors.myMatchCardBar,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Text(
                match.matchId,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.025,
                ),
              ),
            ),
          ),

          // Match Info
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sport, Location, Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${match.sport} ${match.mode == 'singles' ? 'Singles' : 'Doubles'}",
                      style: TextStyle(
                        color: isBadminton ? AppColors.white : AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          size: screenHeight * 0.02,
                          color:
                              isBadminton ? AppColors.white : AppColors.black,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          match.location,
                          style: TextStyle(
                            color:
                                isBadminton ? AppColors.white : AppColors.black,
                            fontSize: screenHeight * 0.018,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      DateFormat(
                        'MMMM dd, yyyy hh:mm a',
                      ).format(match.createdAt),
                      style: TextStyle(
                        color: isBadminton ? AppColors.white : AppColors.black,
                        fontSize: screenHeight * 0.016,
                      ),
                    ),
                  ],
                ),

                // Sets info
                Center(
                  child: Container(
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.28,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        match.sets == 1
                            ? "${match.sets} SET"
                            : "${match.sets} SETS",
                        style: TextStyle(
                          color: AppColors.amber,
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeamBox(
                match.team1Name,
                match.mode == 'singles'
                    ? Text(
                      match.team1PlayerName[0],
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : Column(
                      children: [
                        Text(
                          match.team1PlayerName[0],
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          match.team1PlayerName[1],
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                screenWidth,
                isBadminton,
                team1IsWinner,
              ),
              Text(
                "vs",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.06,
                  color: isBadminton ? AppColors.white : AppColors.black,
                ),
              ),
              _buildTeamBox(
                match.team2Name,
                match.mode == 'singles'
                    ? Text(
                      match.team2PlayerName[0],
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : Column(
                      children: [
                        Text(
                          match.team2PlayerName[0],
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          match.team2PlayerName[1],
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                screenWidth,
                isBadminton,
                team2IsWinner,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamBox(
    String team,
    Widget playerWidget,
    double width,
    bool isBadminton,
    bool isWinner,
  ) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    // Colors for winner and loser
    final winnerColor = Colors.green.shade600;
    final loserColor = Colors.red.shade600;
    final textColor = isWinner ? winnerColor : loserColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          team,
          style: TextStyle(
            color: isBadminton ? AppColors.white : AppColors.bTeamNametext,
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.06,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          decoration: BoxDecoration(
            color: isWinner ? winnerColor : loserColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: playerWidget,
        ),
      ],
    );
  }

  Widget _buildMatchResult(double height, double width, String winnerName) {
    return SizedBox(
      height: height * 0.27,
      width: width * 1,

      // margin: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/winner_trophy.png',
                scale: 4,
                fit: BoxFit.contain,
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      "MATCH WINNER",
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                    Text(
                      "Team $winnerName",
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetHistory(double height, double width, List<List<int>> scores) {
    // Safety check to make sure we have scores to display
    if (scores.isEmpty) {
      return const SizedBox.shrink(); // Return empty widget if no scores
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.01,
          ),
          child: Text(
            "SET RESULTS",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.05,
              color: AppColors.black,
            ),
          ),
        ),
        ...List.generate(scores.length, (index) {
          // Safety check to ensure we don't go out of bounds
          if (index >= scores.length || scores[index].length < 2) {
            return const SizedBox.shrink(); // Skip if out of bounds
          }

          final team1WonSet = scores[index][0] > scores[index][1];
          final team2WonSet = scores[index][1] > scores[index][0];

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: height * 0.005,
              horizontal: width * 0.05,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: height * 0.01,
                horizontal: width * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _setScoreBox(
                    "${scores[index][0]}",
                    width,
                    height,
                    team1WonSet,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.03,
                      vertical: height * 0.01,
                    ),
                    height: height * 0.045,
                    width: width * 0.17,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        "SET ${index + 1}",
                        style: const TextStyle(
                          color: AppColors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _setScoreBox(
                    "${scores[index][1]}",
                    width,
                    height,
                    team2WonSet,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _setScoreBox(
    String score,
    double width,
    double height,
    bool isWinner,
  ) {
    final Color bgColor =
        isWinner ? Colors.green.shade600 : Colors.red.shade600;

    return Container(
      height: height * 0.045,
      width: width * 0.1,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          score,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
