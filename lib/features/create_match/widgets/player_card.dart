import 'package:flutter/material.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/model/player_model.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onRemove;

  const PlayerCard({super.key, required this.player, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.012,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey,
            offset: Offset(screenWidth * 0.008, screenHeight * 0.004),
            blurRadius: screenWidth * 0.015,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundImage: const AssetImage('assets/images/avatar.png'),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: screenHeight * 0.02,
                  ),
                ),
                Text(
                  'ID: ${player.id}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenHeight * 0.015,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
