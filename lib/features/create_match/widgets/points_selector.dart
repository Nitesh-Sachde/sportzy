import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/provider/match_form_provider.dart';

class PointsSelector extends ConsumerStatefulWidget {
  const PointsSelector({super.key});

  @override
  ConsumerState<PointsSelector> createState() => _PointsSelectorState();
}

class _PointsSelectorState extends ConsumerState<PointsSelector> {
  late final TextEditingController customPointsController;

  @override
  void initState() {
    super.initState();
    customPointsController = TextEditingController();
  }

  @override
  void dispose() {
    customPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPoints = ref.watch(matchFormProvider);
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    final isPredefined = [11, 21].contains(selectedPoints.points);

    // Ensure controller shows blank when 11 or 21 is selected
    if (isPredefined && customPointsController.text.isNotEmpty) {
      customPointsController.text = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Points:", style: TextStyle(fontSize: screenHeight * 0.02)),
            ...[11, 21].map(
              (count) => Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                child: ChoiceChip(
                  showCheckmark: false,
                  label: Text("$count"),
                  selected: selectedPoints.points == count,
                  onSelected: (_) {
                    ref.read(matchFormProvider.notifier).updatePoints(count);
                    customPointsController.clear(); // Clear custom input
                  },
                  selectedColor: AppColors.tabSelected,
                  backgroundColor: AppColors.tabUnselected,
                  labelStyle: TextStyle(
                    color:
                        selectedPoints.points == count
                            ? AppColors.white
                            : AppColors.black,
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            SizedBox(
              width: screenWidth * 0.23,
              height: screenHeight * 0.05,
              child: TextField(
                controller: customPointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Custom",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenHeight * 0.005,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  final int? custom = int.tryParse(value);
                  if (custom != null && custom > 0) {
                    ref.read(matchFormProvider.notifier).updatePoints(custom);
                  }
                },
              ),
            ),
          ],
        ),
        if (!isPredefined && selectedPoints.points > 0)
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.005),
            child: Text(
              "Custom Points: ${ref.watch(matchFormProvider).points}",
              style: TextStyle(fontSize: screenHeight * 0.016),
            ),
          ),
      ],
    );
  }
}
