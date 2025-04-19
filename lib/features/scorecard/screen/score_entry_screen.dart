import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:sportzy/features/my_matches/screen/my_matches_screen.dart';
import 'package:sportzy/features/scorecard/service/match_service.dart';
import 'package:sportzy/features/scorecard/provider/match_provider_to_scorecard.dart';
import 'package:sportzy/features/scorecard/provider/score_notifier.dart';
import 'package:sportzy/router/routes.dart';
import 'package:sportzy/widgets/custom_appbar.dart';
import 'package:intl/intl.dart';

class ScoreEntryScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ScoreEntryScreen({super.key, required this.matchId});

  @override
  ConsumerState<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends ConsumerState<ScoreEntryScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);
    final matchAsync = ref.watch(matchByIdProvider(widget.matchId));
    final scoreNotifier = ref.watch(
      scoreNotifierProvider(widget.matchId).notifier,
    );
    final scoreState = ref.read(scoreNotifierProvider(widget.matchId));
    debugPrint(widget.matchId);

    // Make sure scores is not empty
    final scores = scoreState.toList();

    // Safety check for currentSetIndex
    final currentSetIndex = scoreNotifier.currentSetIndex;
    debugPrint('SCORES: $scores | currentSetIndex: $currentSetIndex');
    for (int i = 0; i < scores.length; i++) {
      debugPrint('Set $i: ${scores[i]} | length: ${scores[i].length}');
    }
    final setNum = currentSetIndex + 1;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: CustomAppBar(
        title: widget.matchId,
        showDelete: true,
        showShare: true,
        isBackButtonVisible: true,
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
              // Initialize with default score if match.scores is empty
              final matchScores = match.scores;
              scoreNotifier.loadExistingScores(
                List<List<int>>.from(
                  matchScores.map<List<int>>((s) => List<int>.from(s)),
                ),
              );
              setState(() {
                _initialized = true;
              });
            });
          }

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
                    SizedBox(height: screenHeight * 0.005),
                    _buildMatchInfoCard(
                      screenHeight,
                      screenWidth,
                      match,
                      match.sport.toLowerCase() == 'badminton',
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    // Safety check: Only show scores if list is not empty and index is valid
                    scores.isNotEmpty && currentSetIndex < scores.length
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                scoreNotifier.increaseScore(
                                  0,
                                  match.points,
                                  match.sets,
                                  context,
                                );

                                MatchService.updateMatchScores(
                                  matchId: match.matchId,
                                  currentSetIndex: currentSetIndex,
                                  scores: scoreNotifier.state,
                                );
                              },
                              child: _buildScoreBox(
                                "${scores[currentSetIndex][0]}",
                                screenWidth,
                              ),
                            ),
                            Center(
                              child: Container(
                                height: screenHeight * 0.05,
                                width: screenWidth * 0.2,
                                decoration: BoxDecoration(
                                  color: AppColors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    "SET $setNum",
                                    style: TextStyle(
                                      color: AppColors.amber,
                                      fontSize: screenWidth * 0.06,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                scoreNotifier.increaseScore(
                                  1,
                                  match.points,
                                  match.sets,
                                  context,
                                );

                                MatchService.updateMatchScores(
                                  matchId: match.matchId,
                                  currentSetIndex: currentSetIndex,
                                  scores: scoreNotifier.state,
                                );
                              },
                              child: _buildScoreBox(
                                "${scores[currentSetIndex][1]}",
                                screenWidth,
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildScoreBox("0", screenWidth),

                            _buildScoreBox("0", screenWidth),
                          ],
                        ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            scoreNotifier.decreaseScore(0);
                            MatchService.updateMatchScores(
                              matchId: match.matchId,
                              currentSetIndex: currentSetIndex,
                              scores: scoreNotifier.state,
                            );
                          },
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: screenWidth * 0.25,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.23),
                        GestureDetector(
                          onTap: () {
                            scoreNotifier.decreaseScore(1);
                            MatchService.updateMatchScores(
                              matchId: match.matchId,
                              currentSetIndex: currentSetIndex,
                              scores: scoreNotifier.state,
                            );
                          },
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: screenWidth * 0.25,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    _buildSetHistory(
                      screenHeight,
                      screenWidth,
                      currentSetIndex,
                      scores.sublist(
                        0,
                        currentSetIndex,
                      ), // 👈 Completed sets only
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
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.015,
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

                // Team Names
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
                        "${match.sets} SETS",
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
                    ? match.team1PlayerName[0]
                    : "${match.team1PlayerName[0]} & ${match.team1PlayerName[1]}",
                screenWidth,
                match.sport.toLowerCase() == 'badminton',
              ),
              Text(
                "vs",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.06,
                  color: AppColors.red,
                ),
              ),
              _buildTeamBox(
                match.team2Name,
                match.mode == 'singles'
                    ? match.team2PlayerName[0]
                    : "${match.team2PlayerName[0]} & ${match.team2PlayerName[1]}",
                screenWidth,
                match.sport.toLowerCase() == 'badminton',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamBox(
    String team,
    String player,
    double width,
    bool isBadminton,
  ) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          team,
          style: TextStyle(
            color: isBadminton ? AppColors.white : AppColors.ttTeamWonBG,
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
            color:
                isBadminton ? AppColors.bTeamBarBackground : AppColors.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            player,
            style: TextStyle(
              color: isBadminton ? AppColors.bTeamNametext : AppColors.white,
              fontSize: screenWidth * 0.04,
            ),
          ),
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
        boxShadow: [
          const BoxShadow(
            color: AppColors.black,
            blurRadius: 4,
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
  ) {
    // Safety check to make sure we have scores to display
    if (scores.isEmpty) {
      return const SizedBox.shrink(); // Return empty widget if no scores
    }

    return Column(
      children: List.generate(scores.length, (index) {
        // Safety check to ensure we don't go out of bounds
        if (index >= scores.length || scores[index].length < 2) {
          return const SizedBox.shrink(); // Skip if out of bounds
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.005),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _setScoreBox("${scores[index][0]}", width, height),
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
              _setScoreBox("${scores[index][1]}", width, height),
            ],
          ),
        );
      }),
    );
  }

  Widget _setScoreBox(String score, double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: height * 0.01,
      ),
      height: height * 0.045,
      width: width * 0.1,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(score, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
