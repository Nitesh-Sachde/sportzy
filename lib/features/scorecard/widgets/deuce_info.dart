import 'package:flutter/material.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';

class DeuceInfoWidget extends StatelessWidget {
  const DeuceInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.01,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Deuce Rules",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "When scores are tied near the end of a set, a player must win by a margin of 2 points.",
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ],
      ),
    );
  }
}
