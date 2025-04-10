import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/provider/match_form_provider.dart';

class SportSelector extends ConsumerWidget {
  const SportSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);
    final form = ref.watch(matchFormProvider);
    final notifier = ref.read(matchFormProvider.notifier);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder:
              (_) => ListView(
                children:
                    ['Badminton', 'Table Tennis']
                        .map(
                          (sport) => ListTile(
                            title: Text(sport),
                            onTap: () {
                              notifier.updateSport(sport);
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
              ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015,
          horizontal: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(form.sport),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.05,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
