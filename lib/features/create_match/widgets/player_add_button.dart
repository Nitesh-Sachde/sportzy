import 'package:flutter/material.dart';
import 'package:sportzy/core/theme/app_colors.dart';

class PlayerAddButton extends StatelessWidget {
  final int teamNumber;
  final VoidCallback? onPressed;

  const PlayerAddButton({super.key, required this.teamNumber, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text('Add Player to Team $teamNumber'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
