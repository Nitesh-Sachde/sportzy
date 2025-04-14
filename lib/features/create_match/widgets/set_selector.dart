import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/provider/match_form_provider.dart';

class SetSelector extends ConsumerWidget {
  const SetSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    final selectedSets = ref.watch(matchFormProvider);

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
                  selected: selectedSets.sets == count,
                  onSelected:
                      (_) => ref
                          .read(matchFormProvider.notifier)
                          .updateSets(count),
                  selectedColor: AppColors.tabSelected,
                  backgroundColor: AppColors.tabUnselected,
                  labelStyle: TextStyle(
                    color:
                        selectedSets.sets == count
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
