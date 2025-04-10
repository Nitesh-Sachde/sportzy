import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/provider/set_point_provider.dart';

class SetSelector extends ConsumerWidget {
  const SetSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    final selectedSets = ref.watch(setsProvider);
    final selectedPoints = ref.watch(pointsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Match Format",
          style: TextStyle(
            fontSize: screenHeight * 0.022,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.015),

        // Set Count
        Row(
          children: [
            Text("Sets: ", style: TextStyle(fontSize: screenHeight * 0.02)),
            ...[1, 3, 5].map(
              (count) => Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                child: ChoiceChip(
                  showCheckmark: false,
                  label: Text("$count"),
                  selected: selectedSets == count,
                  onSelected:
                      (_) => ref.read(setsProvider.notifier).state = count,
                  selectedColor: AppColors.tabSelected,
                  backgroundColor: AppColors.tabUnselected,
                  labelStyle: TextStyle(
                    color:
                        selectedSets == count
                            ? AppColors.white
                            : AppColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
