import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/home/controller/home_controller.dart';
import 'package:sportzy/features/home/provider/match_data_provider.dart';
import 'package:sportzy/features/home/widgets/match_cards.dart';
import 'package:sportzy/features/home/widgets/search_modal.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  String userId = '';
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();

    // Refresh the providers whenever the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(liveMatchesProvider);
      ref.refresh(pastMatchesProvider);
    });
  }

  Future<void> _loadUserDetails() async {
    final details = await DashboardController().fetchUserDetails();
    setState(() {
      name = details['name']!;
      userId = details['userId']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSection(screenWidth, screenHeight),
            Expanded(child: _buildScrollableSection(screenWidth, screenHeight)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.white,
            radius: screenHeight * 0.032,
            child: Text(
              getInitials(name),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $name",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.02,
                ),
              ),
              Text(
                "ID: $userId",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.016,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSearchModal(context),
            child: Icon(
              Icons.search,
              color: Colors.white,
              size: screenHeight * 0.033,
            ),
          ),
          SizedBox(width: screenWidth * 0.07),
          // Icon(
          //   Icons.notifications,
          //   color: Colors.white,
          //   size: screenHeight * 0.033,
          // ),
        ],
      ),
    );
  }

  Widget _buildScrollableSection(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMatchSection("Live Matches", screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.01),
            _buildMatchSection("Past Matches", screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchSection(
    String title,
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text(
            title,
            style: TextStyle(
              fontSize: screenHeight * 0.025,
              fontWeight: FontWeight.bold,
              color: title == "Live Matches" ? Colors.red : Colors.black87,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black38,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        SizedBox(
          height: screenHeight * 0.35,
          child:
              title == "Live Matches"
                  ? _buildLiveMatches(screenWidth, screenHeight)
                  : _buildPastMatches(screenWidth, screenHeight),
        ),
      ],
    );
  }

  Widget _buildLiveMatches(double screenWidth, double screenHeight) {
    final liveMatchesAsync = ref.watch(liveMatchesProvider);

    return liveMatchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(child: Text('No live matches available'));
        }

        return PageView.builder(
          controller: PageController(viewportFraction: 0.93),
          itemCount: matches.length,
          itemBuilder: (context, index) => LiveMatchCard(match: matches[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Could not load matches',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.018,
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    // Force refresh the providers
                    ref.refresh(liveMatchesProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPastMatches(double screenWidth, double screenHeight) {
    final pastMatchesAsync = ref.watch(pastMatchesProvider);

    return pastMatchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(child: Text('No past matches available'));
        }

        return PageView.builder(
          controller: PageController(viewportFraction: 0.93),
          itemCount: matches.length,
          itemBuilder: (context, index) => PastMatchCard(match: matches[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Could not load matches',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.018,
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    // Force refresh the providers
                    ref.refresh(pastMatchesProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchModal(),
    );
  }
}

String getInitials(String? name) {
  if (name == null || name.trim().isEmpty) return "";
  final names = name.trim().split(RegExp(r'\s+'));
  if (names.length > 1) {
    return "${names[0][0]}${names[1][0]}".toUpperCase();
  }
  return names[0][0].toUpperCase();
}
