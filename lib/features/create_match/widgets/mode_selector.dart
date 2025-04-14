import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/provider/match_form_provider.dart';

class ModeSelector extends ConsumerWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(matchFormProvider);
    // final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Mode',
          style: TextStyle(
            fontSize: screenHeight * 0.022,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ModeTile(
              label: 'Singles',
              isSelected: selectedMode.mode == 'singles',
              onTap:
                  () => ref
                      .read(matchFormProvider.notifier)
                      .updateMode('singles'),
            ),
            _ModeTile(
              label: 'Doubles',
              isSelected: selectedMode.mode == 'doubles',
              onTap:
                  () => ref
                      .read(matchFormProvider.notifier)
                      .updateMode('doubles'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.4,
        height: screenHeight * 0.06,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.grey,
              offset: Offset(4, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.white : AppColors.black,
            fontSize: screenHeight * 0.018,
          ),
        ),
      ),
    );
  }
}
