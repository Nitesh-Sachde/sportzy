import 'package:flutter/material.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart'; // update path if different

class LiveMatchCard extends StatelessWidget {
  const LiveMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Container(
      width: screenWidth * 0.75,
      height: screenHeight * 0.32,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.sports_tennis, color: Colors.white),
              SizedBox(width: 6),
              Text(
                "Badminton Singles",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.007),
          const Text("BM12345", style: TextStyle(color: Colors.redAccent)),
          SizedBox(height: screenHeight * 0.01),
          const Text("DAU Campus", style: TextStyle(color: Colors.white70)),
          SizedBox(height: screenHeight * 0.007),
          const Text(
            "March 27, 2025 10:00 AM",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          const Center(
            child: Text(
              "MscIT 1 vs MscIT 2",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ScoreBox(score: '5', playerName: 'Nitesh'),
              Text("SET 1", style: TextStyle(color: Colors.white)),
              ScoreBox(score: '8', playerName: 'Chandresh'),
            ],
          ),
        ],
      ),
    );
  }
}

class PastMatchCard extends StatelessWidget {
  const PastMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Container(
      width: screenWidth * 0.68,
      height: screenHeight * 0.28,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Table Tennis Singles",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text("TT12345", style: TextStyle(color: Colors.white)),
          SizedBox(height: 6),
          Text("DAU Campus", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 6),
          Text(
            "March 25, 2025 11:00 AM",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Spacer(),
          Row(
            children: [
              Icon(Icons.emoji_events, size: 36, color: Colors.yellow),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Team MscIT Won",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ScoreBox extends StatelessWidget {
  final String score;
  final String playerName;

  const ScoreBox({super.key, required this.score, required this.playerName});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            score,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 4),
        Text(playerName, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
