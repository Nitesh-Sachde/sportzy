import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/my_matches/provider/match_provider.dart';
import 'package:sportzy/features/my_matches/widgets/my_match_card.dart';
import 'package:sportzy/router/routes.dart';

class MyMatchesScreen extends ConsumerWidget {
  const MyMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = MatchFilter.live;
    final completed = MatchFilter.completed;
    final filter = ref.watch(matchFilterProvider);
    final matchesAsync = ref.watch(filteredMatchListProvider);
    ref.refresh(filteredMatchListProvider);
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('My Matches'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle Tabs
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.01,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(matchFilterProvider.notifier).state = live;
                            ref.refresh(filteredMatchListProvider);
                          },

                          // ignore: unused_result
                          child: Container(
                            height: screenHeight * 0.06,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  filter == live
                                      ? AppColors.tabSelected
                                      : AppColors.tabUnselected,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Live',
                              style: TextStyle(
                                color:
                                    filter == live
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(matchFilterProvider.notifier).state =
                                completed;
                            ref.refresh(filteredMatchListProvider);
                          },

                          child: Container(
                            height: screenHeight * 0.06,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  filter == completed
                                      ? AppColors.tabSelected
                                      : AppColors.tabUnselected,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                color:
                                    filter == completed
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Match Card List
                // Inside MyMatchesScreen
                // Match Card List
                Expanded(
                  child: matchesAsync.when(
                    data: (matches) {
                      if (matches.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/no_match_found.webp',
                                height: screenHeight * 0.27,
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              Text(
                                'No matches found!',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.027,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          return MatchCard(match: matches[index]);
                        },
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (err, stack) =>
                            Center(child: Text('Error loading matches')),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.02,
            right: screenWidth * 0.04,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,

              children: [
                FloatingActionButton.extended(
                  backgroundColor: AppColors.red,
                  icon: Icon(Icons.create, color: AppColors.white),

                  onPressed: () async {
                    await Navigator.pushNamed(context, Routes.createMatch);
                  },

                  label: Text(
                    "Create Match",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
