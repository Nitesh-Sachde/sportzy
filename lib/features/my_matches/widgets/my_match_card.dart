import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/home/screen/past_match_scorecard.dart';
import 'package:sportzy/features/scorecard/screen/score_entry_screen.dart';

class MatchCard extends ConsumerWidget {
  final MatchModel match;
  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);
    final dateFormatter = DateFormat('dd MMM yyyy • hh:mm a');
    return GestureDetector(
      onTap: () {
        match.status == 'live'
            ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScoreEntryScreen(matchId: match.matchId),
              ),
            )
            : Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PastMatchScoreCard(matchId: match.matchId),
              ),
            );
      },

      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01,
          horizontal: screenWidth * 0.03,
        ),
        decoration: BoxDecoration(
          color:
              match.sport.toLowerCase() == "badminton"
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
              decoration: BoxDecoration(
                color: AppColors.myMatchCardBar,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  match.matchId,
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.023,
                  ),
                ),
              ),
            ),

            // Match Info Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.01,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            match.sport,
                            style: TextStyle(
                              color:
                                  match.sport.toLowerCase() == 'badminton'
                                      ? AppColors.white
                                      : AppColors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * 0.02,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            match.mode,
                            style: TextStyle(
                              color:
                                  match.sport.toLowerCase() == 'badminton'
                                      ? AppColors.white
                                      : AppColors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * 0.02,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: screenHeight * 0.02,
                            color:
                                match.sport.toLowerCase() == 'badminton'
                                    ? AppColors.white
                                    : AppColors.black,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            match.location,
                            style: TextStyle(
                              color:
                                  match.sport.toLowerCase() == 'badminton'
                                      ? AppColors.white
                                      : AppColors.black,
                              fontSize: screenHeight * 0.018,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        dateFormatter.format(match.createdAt),
                        style: TextStyle(
                          color:
                              match.sport.toLowerCase() == 'badminton'
                                  ? AppColors.white
                                  : AppColors.black,
                          fontSize: screenHeight * 0.016,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.012),
                    ],
                  ),
                  Column(
                    children: [
                      match.sport.toLowerCase().contains('badminton')
                          ? Column(
                            children: [
                              Text(
                                match.team1Name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight * 0.025,
                                  color: AppColors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                ),
                                child: Text(
                                  "vs",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenHeight * 0.023,
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                              Text(
                                match.team2Name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight * 0.025,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          )
                          : Column(
                            children: [
                              Text(
                                match.team1Name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight * 0.025,
                                  color: AppColors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                ),
                                child: Text(
                                  "vs",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenHeight * 0.023,
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                              Text(
                                match.team2Name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight * 0.025,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
