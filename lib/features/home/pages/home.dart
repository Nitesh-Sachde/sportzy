import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/home/controller/home_controller.dart';
import 'package:sportzy/features/home/widgets/match_cards.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  String userId = '';
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final details = await HomeController().fetchUserDetails();
    setState(() {
      name = details['name']!;
      userId = details['userId']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSection(screenWidth, screenHeight),
            Expanded(child: _buildScrollableSection(screenWidth, screenHeight)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: const AssetImage("assets/images/avatar.png"),
            radius: screenHeight * 0.032,
          ),
          SizedBox(width: screenWidth * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $name",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.02,
                ),
              ),
              Text(
                "UID: $userId",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.016,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.search, color: Colors.white, size: screenHeight * 0.033),
          SizedBox(width: screenWidth * 0.07),
          Icon(
            Icons.notifications,
            color: Colors.white,
            size: screenHeight * 0.033,
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableSection(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchSection(
              "Live Matches",
              const LiveMatchCard(),
              screenWidth,
              screenHeight,
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildMatchSection(
              "Past Matches",
              const PastMatchCard(),
              screenWidth,
              screenHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchSection(
    String title,
    Widget card,
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text(
            title,
            style: TextStyle(
              fontSize: screenHeight * 0.025,
              fontWeight: FontWeight.bold,
              color: title == "Live Matches" ? Colors.red : Colors.black87,

              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black38,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        SizedBox(
          height: screenHeight * 0.32,
          child: PageView.builder(
            controller: PageController(
              viewportFraction: 0.94, // So that a bit of next/prev card peeks
            ),
            itemCount: 5, // Replace with your list length
            itemBuilder: (context, index) {
              return title == "Live Matches"
                  ? LiveMatchCard()
                  : PastMatchCard(); // Or PastMatchCard based on screen
            },
          ),
        ),
      ],
    );
  }
}
