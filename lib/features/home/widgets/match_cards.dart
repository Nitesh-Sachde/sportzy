import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';

class LiveMatchCard extends ConsumerStatefulWidget {
  const LiveMatchCard({super.key});

  @override
  ConsumerState<LiveMatchCard> createState() => _LiveMatchCardState();
}

class _LiveMatchCardState extends ConsumerState<LiveMatchCard> {
  final bool isDoubles = true;
  final String sport = 'Table Tennis'; // Change to 'Table Tennis' to test

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);
    final cardColor =
        sport == 'Badminton'
            ? AppColors.badmintoncardBackground
            : AppColors.ttcardBackground;

    return GestureDetector(
      onTap: () => print("Live match card clicked"),
      child:
          sport == 'Badminton'
              ? Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                width: screenWidth * 0.9,
                height: screenHeight * 0.32,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$sport ${isDoubles ? "Doubles" : "Singles"}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),

                        Text(
                          "BM12345",
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.white,
                        ),
                        Text(
                          "DAU Campus",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.06),

                        Text(
                          "March 27, 2025 10:00 AM",
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
                            BoxShadow(
                              color: AppColors.bTeamBarBackground,
                              blurRadius: 2,
                            ),
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
                                "MscIT 1",
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
                              "MscIT 2",
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
                              score: '5',
                              playerName1: 'Nitesh',
                              playerName2: isDoubles ? 'Jay' : null,
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                            child: Text(
                              "SET 1",
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
                              score: '8',
                              playerName1: 'Chandresh',
                              playerName2: isDoubles ? 'Manav' : null,
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
                        Icon(
                          Icons.arrow_circle_right_rounded,
                          color: AppColors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                width: screenWidth * 0.9,
                height: screenHeight * 0.32,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$sport ${isDoubles ? "Doubles" : "Singles"}",
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),

                        Text(
                          "TT12345",
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.black,
                        ),
                        Text(
                          "DAU Campus",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.06),

                        Text(
                          "March 27, 2025 10:00 AM",
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
                            BoxShadow(
                              color: AppColors.ttTeamBarBackground,
                              blurRadius: 2,
                            ),
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
                                "MscIT 1",
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
                              "MscIT 2",
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
                              score: '5',
                              playerName1: 'Nitesh',
                              playerName2: isDoubles ? 'Jay' : null,
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                            child: Text(
                              "SET 1",
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
                              score: '8',
                              playerName1: 'Chandresh',
                              playerName2: isDoubles ? 'Manav' : null,
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
                        Icon(
                          Icons.arrow_circle_right_rounded,
                          color: AppColors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}

class PastMatchCard extends ConsumerStatefulWidget {
  const PastMatchCard({super.key});

  @override
  ConsumerState<PastMatchCard> createState() => _PastMatchCardState();
}

class _PastMatchCardState extends ConsumerState<PastMatchCard> {
  final bool isDoubles = true;
  final String sport = 'Badminton';

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);
    final cardColor =
        sport == 'Badminton'
            ? AppColors.badmintoncardBackground
            : AppColors.ttcardBackground;

    return GestureDetector(
      onTap: () => print("Live match card clicked"),
      child:
          sport == 'Badminton'
              ? Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                width: screenWidth * 0.9,
                height: screenHeight * 0.32,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$sport ${isDoubles ? "Doubles" : "Singles"}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),

                        Text(
                          "BM12345",
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.white,
                        ),
                        Text(
                          "DAU Campus",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.06),

                        Text(
                          "March 27, 2025 10:00 AM",
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
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.01,
                          ),
                          height: screenHeight * 0.12,
                          width: screenWidth * 0.45,
                          decoration: BoxDecoration(
                            color: AppColors.bTeamBarBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
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
                        Icon(
                          Icons.arrow_circle_right_rounded,
                          color: AppColors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                width: screenWidth * 0.9,
                height: screenHeight * 0.32,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$sport ${isDoubles ? "Doubles" : "Singles"}",
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),

                        Text(
                          "TT12345",
                          style: TextStyle(
                            color: AppColors.amber,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.black,
                        ),
                        Text(
                          "DAU Campus",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.06),

                        Text(
                          "March 27, 2025 10:00 AM",
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

                          scale: 3.4,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.01,
                          ),
                          height: screenHeight * 0.12,
                          width: screenWidth * 0.45,
                          decoration: BoxDecoration(
                            color: AppColors.ttTeamWonBG,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
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
                        Icon(
                          Icons.arrow_circle_right_rounded,
                          color: AppColors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
