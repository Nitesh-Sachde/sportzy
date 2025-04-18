import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/home/screen/dashboard.dart';
import 'package:sportzy/features/my_matches/screen/my_matches_screen.dart';
import 'package:sportzy/features/playerprofile/profile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const MyMatchesScreen(), // Replace with your Matches/History screen
    const Dashboard(), // Home screen content // Settings/Profile screen
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(currentUserProvider); // Example usage
    double screenWidth = ScreenSize.screenWidth(context);
    double screenHeight = ScreenSize.screenHeight(context);
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        color: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.01,
        ),
        child: GNav(
          haptic: true,
          backgroundColor: AppColors.white,
          color: AppColors.primary,
          activeColor: AppColors.white,
          tabBackgroundColor: AppColors.primary,
          gap: 8,
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          padding: EdgeInsets.all(screenWidth * 0.023),
          tabs: [
            GButton(
              icon: Icons.list_rounded,
              text: 'Matches',
              textSize: screenWidth * 0.07,
              iconSize: screenWidth * 0.09,
            ),
            GButton(
              icon: Icons.home,
              text: 'Home',
              textSize: screenWidth * 0.07,
              iconSize: screenWidth * 0.09,
            ),
            GButton(
              icon: Icons.settings,
              text: 'Profile',
              textSize: screenWidth * 0.07,
              iconSize: screenWidth * 0.09,
            ),
          ],
        ),
      ),
    );
  }
}
