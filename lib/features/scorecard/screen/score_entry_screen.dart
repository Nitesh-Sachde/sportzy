// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/dynamic_link_service.dart';
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
        onDelete: () => _showDeleteConfirmationDialog(),
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
              final scoreNotifier = ref.read(
                scoreNotifierProvider(widget.matchId).notifier,
              );

              // Check if match.scores exists and is not empty
              if (match.scores.isNotEmpty) {
                scoreNotifier.loadExistingScores(
                  List<List<int>>.from(
                    match.scores.map<List<int>>((s) => List<int>.from(s)),
                  ),
                  maxPoints: match.points,
                );
              } else {
                // Initialize with default empty scores for each set
                final defaultScores = List.generate(match.sets, (_) => [0, 0]);
                scoreNotifier.loadExistingScores(
                  defaultScores,
                  maxPoints: match.points,
                );
              }

              setState(() {
                _initialized = true;
              });
            });

            // Show a loading indicator until initialization is complete
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Always check scores before using them
          final scores = match.scores;
          if (scores.isEmpty) {
            return const Center(child: Text("Initializing match scores..."));
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
                                isDeuce: scoreNotifier.inDeuce,
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
                                isDeuce: scoreNotifier.inDeuce,
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
                    SizedBox(height: screenHeight * 0.01),

                    // Show deuce/advantage label based on state
                    Builder(
                      builder: (context) {
                        final deuceState = ref.watch(
                          deuceStateProvider(widget.matchId),
                        );
                        final advantageTeam = ref.watch(
                          advantageTeamProvider(widget.matchId),
                        );

                        if (deuceState == DeuceState.deuce) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.priority_high,
                                  color: Colors.white,
                                  size: screenWidth * 0.06,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  "DEUCE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (deuceState == DeuceState.advantage) {
                          final teamName =
                              advantageTeam == 0
                                  ? match.team1Name
                                  : match.team2Name;
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars,
                                  color: Colors.white,
                                  size: screenWidth * 0.06,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  "ADVANTAGE $teamName",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return SizedBox.shrink(); // No deuce or advantage
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            scoreNotifier.decreaseScore(0, match.points);
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
                            scoreNotifier.decreaseScore(1, match.points);
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
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : Column(
                      children: [
                        Text(
                          match.team1PlayerName[0],
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          match.team1PlayerName[1],
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                    ? Text(
                      match.team2PlayerName[0],
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : Column(
                      children: [
                        Text(
                          match.team2PlayerName[0],
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          match.team2PlayerName[1],
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
    Widget playerWidget,
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
            color: AppColors.bTeamBarBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: playerWidget,
        ),
      ],
    );
  }

  Widget _buildScoreBox(String score, double width, {bool isDeuce = false}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: width * 0.28,
      height: width * 0.3,
      decoration: BoxDecoration(
        color: isDeuce ? Colors.amber.withOpacity(0.8) : AppColors.yelllow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDeuce ? Colors.red.withOpacity(0.6) : AppColors.black,
            blurRadius: isDeuce ? 8 : 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        score,
        style: TextStyle(
          fontSize: width * 0.15,
          fontWeight: FontWeight.bold,
          color: isDeuce ? Colors.red : Colors.black,
        ),
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
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.01,
          ),
          child: Text(
            "COMPLETED SETS",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.05,
              color: AppColors.black,
            ),
          ),
        ),
        ...List.generate(scores.length, (index) {
          // If this is the current set and it's not completed, don't show it
          if (index >= scores.length || scores[index].length < 2) {
            return const SizedBox.shrink(); // Skip if out of bounds
          }

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
            ),
          );
        }),
      ],
    );
  }

  Widget _setScoreBox(String score, double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: height * 0.008,
      ),
      height: height * 0.05,
      width: width * 0.12, // Increased width to fit two digits
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            score,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: width * 0.045,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Match'),
            content: Text(
              'Are you sure you want to delete this match? This action cannot be undone.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
              TextButton(
                onPressed: () {
                  _deleteMatch();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteMatch() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
      );

      // Delete the match from Firestore
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .delete();

      // Close loading indicator
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Match deleted successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      // Close loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete match: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
