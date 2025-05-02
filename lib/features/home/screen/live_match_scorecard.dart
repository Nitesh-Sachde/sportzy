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

class LiveMatchScoreCard extends ConsumerStatefulWidget {
  final String matchId;

  const LiveMatchScoreCard({super.key, required this.matchId});

  @override
  ConsumerState<LiveMatchScoreCard> createState() => _LiveMatchScoreCardState();
}

class _LiveMatchScoreCardState extends ConsumerState<LiveMatchScoreCard> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);
    final matchAsync = ref.watch(matchByIdProvider(widget.matchId));

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: AppColors.primary,
      appBar: CustomAppBar(
        title: "Live Match",
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

          // Calculate current score and stats
          int team1Wins = 0;
          int team2Wins = 0;
          int currentSet = match.currentSetIndex + 1;

          for (var set in match.scores) {
            if (set[0] > set[1]) {
              team1Wins++;
            } else if (set[1] > set[0]) {
              team2Wins++;
            }
          }

          final team1IsLeading = team1Wins > team2Wins;
          final team2IsLeading = team2Wins > team1Wins;

          // Get current set scores
          String team1CurrentScore = "0";
          String team2CurrentScore = "0";

          if (currentSet > 0 && match.scores.isNotEmpty) {
            final currentSetIndex = currentSet - 1;
            if (currentSetIndex < match.scores.length) {
              team1CurrentScore = "${match.scores[currentSetIndex][0]}";
              team2CurrentScore = "${match.scores[currentSetIndex][1]}";
            }
          }

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.01,
              vertical: screenHeight * 0.02,
            ),
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
                    _buildMatchInfoCard(
                      screenHeight,
                      screenWidth,
                      match,
                      match.sport.toLowerCase() == 'badminton',
                      team1IsLeading,
                      team2IsLeading,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Live scores boxes
                    _buildLiveScoreSection(
                      screenHeight,
                      screenWidth,
                      team1CurrentScore,
                      team2CurrentScore,
                      currentSet,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Set history for completed sets
                    if (match.scores.isNotEmpty)
                      _buildSetHistory(
                        screenHeight,
                        screenWidth,
                        currentSet,
                        match.scores,
                        match, // Pass the match object
                      ),

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
    bool team1IsLeading,
    bool team2IsLeading,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
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
            offset: Offset(2, 2),
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
                team1IsLeading,
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
                team2IsLeading,
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
    bool isLeading,
  ) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    // Colors for leading and trailing teams
    final leadingColor = Colors.green.shade600;
    final trailingColor = Colors.red.shade600;
    final textColor = isLeading ? leadingColor : trailingColor;

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
            color: isLeading ? leadingColor : trailingColor,
            borderRadius: BorderRadius.circular(10),
          ),

          child: playerWidget,
        ),
      ],
    );
  }

  Widget _buildLiveScoreSection(
    double height,
    double width,
    String team1Score,
    String team2Score,
    int currentSet,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.01,
              ),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "CURRENT SET: $currentSet",
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.05,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildScoreBox(team1Score, width),
            SizedBox(width: width * 0.05),
            _buildScoreBox(team2Score, width),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreBox(String score, double width) {
    debugPrint(score);
    return Container(
      width: width * 0.28,
      height: width * 0.3,
      decoration: BoxDecoration(
        color: AppColors.yelllow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black,
            blurRadius: 3,
            offset: Offset(2, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        score,
        style: TextStyle(fontSize: width * 0.15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSetHistory(
    double height,
    double width,
    int currentSet,
    List<List<int>> scores,
    MatchModel match, // Add match as parameter
  ) {
    // Safety check to make sure we have scores to display
    if (scores.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get all sets that are completed (have a clear winner)
    final completedSets = <List<int>>[];

    for (var set in scores) {
      // A set is completed if it has two scores and one is greater than the other
      if (set.length >= 2 && set[0] != set[1]) {
        // Check if either team has enough points with 2-point lead (typically game point)
        if ((set[0] >= match.points || set[1] >= match.points) &&
            (set[0] - set[1]).abs() >= 2) {
          completedSets.add(set);
        }
      }
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.01,
          ),
          child: Text(
            completedSets.isEmpty ? "NO COMPLETED SETS" : "COMPLETED SETS",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.05,
              color: AppColors.black,
            ),
          ),
        ),
        ...List.generate(completedSets.length, (index) {
          final set = completedSets[index];

          // Determine which team won the set for coloring
          final team1WonSet = set[0] > set[1];
          final team2WonSet = set[1] > set[0];

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
                  _setScoreBox("${set[0]}", width, height, team1WonSet),
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
                  _setScoreBox("${set[1]}", width, height, team2WonSet),
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
