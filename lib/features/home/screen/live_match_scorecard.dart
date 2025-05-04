import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/dynamic_link_service.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:sportzy/features/home/screen/past_match_scorecard.dart';
import 'package:sportzy/features/scorecard/provider/match_provider_to_scorecard.dart';
import 'package:sportzy/widgets/custom_appbar.dart';
import 'package:intl/intl.dart';

// Add StreamProvider to listen to match changes
final matchStatusStreamProvider = StreamProvider.family<String, String>((
  ref,
  matchId,
) {
  return FirebaseFirestore.instance
      .collection('matches')
      .doc(matchId)
      .snapshots()
      .map((snapshot) => snapshot.data()?['status'] ?? 'live');
});

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

    // Watch for match status changes
    final matchStatusAsync = ref.watch(
      matchStatusStreamProvider(widget.matchId),
    );

    // Check if match is completed, then redirect
    matchStatusAsync.whenData((status) {
      if (status == 'completed') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PastMatchScoreCard(matchId: widget.matchId),
            ),
          );
        });
      }
    });

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
                      match, // Add match as a parameter
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

  // Update the _buildLiveScoreSection method to include deuce/advantage indicators
  Widget _buildLiveScoreSection(
    double height,
    double width,
    String team1Score,
    String team2Score,
    int currentSet,
    MatchModel match, // Add match as a parameter
  ) {
    final team1Points = int.tryParse(team1Score) ?? 0;
    final team2Points = int.tryParse(team2Score) ?? 0;
    final maxPoints = match.points; // Get max points from match model

    // Determine deuce/advantage state
    bool isDeuce = false;
    bool isAdvantage = false;
    int? advantageTeam;

    if (team1Points >= maxPoints - 1 && team2Points >= maxPoints - 1) {
      if (team1Points == team2Points) {
        isDeuce = true;
      } else if ((team1Points - team2Points).abs() == 1) {
        isAdvantage = true;
        advantageTeam = team1Points > team2Points ? 0 : 1;
      }
    }

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

        // Deuce or advantage indicator
        if (isDeuce || isAdvantage)
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: EdgeInsets.only(top: height * 0.02),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.015,
            ),
            decoration: BoxDecoration(
              color:
                  isDeuce
                      ? Colors.red.shade600.withOpacity(0.8)
                      : Colors.green.shade600.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      isDeuce
                          ? Colors.red.shade800.withOpacity(0.4)
                          : Colors.green.shade800.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDeuce ? Icons.priority_high : Icons.stars,
                  color: Colors.white,
                  size: width * 0.07,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  isDeuce
                      ? "DEUCE"
                      : "ADVANTAGE ${advantageTeam == 0 ? match.team1Name : match.team2Name}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.05,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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

  // Now update the _buildSetHistory method to check for deuce
  Widget _buildSetHistory(
    double height,
    double width,
    int currentSet,
    List<List<int>> scores,
    MatchModel match,
  ) {
    // Safety check to make sure we have scores to display
    if (scores.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedSets = <List<int>>[];
    final hadDeuceList = <bool>[];

    for (var set in scores) {
      // A set is completed if it has two scores and one is greater than the other
      if (set.length >= 2 && set[0] != set[1]) {
        // Check if either team has enough points with 2-point lead (typically game point)
        if ((set[0] >= match.points || set[1] >= match.points) &&
            (set[0] - set[1]).abs() >= 2) {
          completedSets.add(set);

          // Check if this set had a deuce (both reached maxPoints-1)
          final hadDeuce =
              set[0] >= match.points - 1 && set[1] >= match.points - 1;
          hadDeuceList.add(hadDeuce);
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
          final hadDeuce =
              index < hadDeuceList.length ? hadDeuceList[index] : false;

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
                  _setScoreBox(
                    "${set[0]}",
                    width,
                    height,
                    team1WonSet,
                    hadDeuce: hadDeuce, // Pass the hadDeuce flag
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
                    "${set[1]}",
                    width,
                    height,
                    team2WonSet,
                    hadDeuce: hadDeuce, // Pass the hadDeuce flag
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // Update the _setScoreBox method to include the deuce indicator
  Widget _setScoreBox(
    String score,
    double width,
    double height,
    bool isWinner, {
    bool hadDeuce = false, // Add this parameter
  }) {
    final Color bgColor =
        isWinner ? Colors.green.shade600 : Colors.red.shade600;

    return Stack(
      children: [
        Container(
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
        ),
        // Add the deuce indicator
        if (hadDeuce)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: width * 0.035,
              height: width * 0.035,
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'D',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
