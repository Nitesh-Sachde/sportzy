import 'package:flutter/material.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/models/player_model.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onRemove;

  const PlayerCard({super.key, required this.player, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.grey, offset: Offset(2, 2), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage(
              'assets/images/avatar.png',
            ), // Use your avatar path
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'ID: ${player.id}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
