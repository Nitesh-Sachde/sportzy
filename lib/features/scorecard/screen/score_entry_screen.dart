import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:sportzy/features/scorecard/service/match_service.dart';
import 'package:sportzy/features/scorecard/provider/match_provider_to_scorecard.dart';
import 'package:sportzy/features/scorecard/provider/score_notifier.dart';
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
    final scoreNotifier = ref.read(
      scoreNotifierProvider(widget.matchId).notifier,
    );
    final scoreState = ref.watch(scoreNotifierProvider(widget.matchId));
    debugPrint(widget.matchId);

    // Make sure scores is not empty
    final scores =
        scoreState.isNotEmpty
            ? scoreState.where((s) => s.length == 2).toList()
            : [
              [0, 0],
            ];

    // Safety check for currentSetIndex
    final currentSetIndex =
        scoreState.isNotEmpty
            ? scoreNotifier.currentSetIndex.clamp(0, scores.length - 1)
            : 0;
    debugPrint('SCORES: $scores | currentSetIndex: $currentSetIndex');
    for (int i = 0; i < scores.length; i++) {
      debugPrint('Set $i: ${scores[i]} | length: ${scores[i].length}');
    }

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
              final matchScores =
                  match.scores.isNotEmpty
                      ? match.scores
                      : [
                        [0, 0],
                      ];

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
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.005),
                _buildMatchInfoCard(
                  screenHeight,
                  screenWidth,
                  match,
                  match.sport.toLowerCase() == 'badminton',
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTeamBox(
                      match.team1Name,
                      match.mode == 'singles'
                          ? match.team1PlayerName[0]
                          : "${match.team1PlayerName[0]} & ${match.team1PlayerName[1]}",
                      screenWidth,
                    ),
                    const Text(
                      "vs",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    _buildTeamBox(
                      match.team2Name,
                      match.mode == 'singles'
                          ? match.team2PlayerName[0]
                          : "${match.team2PlayerName[0]} & ${match.team2PlayerName[1]}",
                      screenWidth,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Safety check: Only show scores if list is not empty and index is valid
                scores.isNotEmpty && currentSetIndex <= scores.length
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildScoreBox(
                          "${scores[currentSetIndex][0]}",
                          screenWidth,
                        ),
                        _buildScoreBox(
                          "${scores[currentSetIndex][1]}",
                          screenWidth,
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
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        scoreNotifier.increaseScore(0);
                        MatchService.updateMatchScores(
                          matchId: match.matchId,
                          scores: scoreNotifier.state,
                        );
                      },

                      child: const Icon(Icons.arrow_drop_up, size: 32),
                    ),
                    GestureDetector(
                      onTap: () {
                        scoreNotifier.increaseScore(1);
                        MatchService.updateMatchScores(
                          matchId: match.matchId,
                          scores: scoreNotifier.state,
                        );
                      },
                      child: const Icon(Icons.arrow_drop_up, size: 32),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildSetHistory(
                  screenHeight,
                  screenWidth,
                  currentSetIndex,
                  scores,
                ),
              ],
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
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color:
            isBadminton
                ? AppColors.badmintoncardBackground
                : AppColors.ttcardBackground,
        borderRadius: BorderRadius.circular(20),
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
                        "SET ${match.currentSetIndex + 1}",
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
        ],
      ),
    );
  }

  Widget _buildTeamBox(String team, String player, double width) {
    return Column(
      children: [
        Text(team, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(player, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildScoreBox(String score, double width) {
    debugPrint(score);
    return Container(
      width: width * 0.28,
      height: width * 0.28,
      decoration: BoxDecoration(
        color: const Color(0xFFFFDE80),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        score,
        style: TextStyle(fontSize: width * 0.12, fontWeight: FontWeight.bold),
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
        final isCurrent = index == currentSet;
        // Safety check to ensure we don't go out of bounds
        if (index >= scores.length || scores[index].length < 2) {
          return const SizedBox.shrink(); // Skip if out of bounds
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.005),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _setScoreBox("${scores[index][0]}", width),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.black : AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "SET ${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _setScoreBox("${scores[index][1]}", width),
            ],
          ),
        );
      }),
    );
  }

  Widget _setScoreBox(String score, double width) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(score, style: const TextStyle(color: Colors.white)),
    );
  }
}
