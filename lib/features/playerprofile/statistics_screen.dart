import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/playerprofile/provider/statistics_provider.dart';
import 'package:sportzy/features/playerprofile/model/statistics_model.dart';
import 'package:sportzy/widgets/custom_appbar.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  final String? userId; // Optional: if null, will show current user stats

  const StatisticsScreen({super.key, this.userId});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _debugPrintStatistics(); // Add this line
  }

  Future<void> _loadUserName() async {
    final userId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            userName = userDoc.data()!['fullname'] ?? 'User';
          });
        }
      } catch (e) {
        print('Error loading user name: $e');
      }
    }
  }

  Future<void> _debugPrintStatistics() async {
    final userId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      print('Debugging statistics for user: $userId');

      // Check overall stats
      final overallStatsDoc =
          await FirebaseFirestore.instance
              .collection('player_stats')
              .doc(userId)
              .collection('overall')
              .doc('stats')
              .get();

      print('Overall stats exists: ${overallStatsDoc.exists}');
      if (overallStatsDoc.exists) {
        print('Overall stats: ${overallStatsDoc.data()}');
      }

      // Check badminton stats
      final badmintonStatsDoc =
          await FirebaseFirestore.instance
              .collection('player_stats')
              .doc(userId)
              .collection('sports')
              .doc('badminton')
              .get();

      print('Badminton stats exists: ${badmintonStatsDoc.exists}');
      if (badmintonStatsDoc.exists) {
        print('Badminton stats: ${badmintonStatsDoc.data()}');
      }

      // Check table tennis stats
      final tableStatsDoc =
          await FirebaseFirestore.instance
              .collection('player_stats')
              .doc(userId)
              .collection('sports')
              .doc('table_tennis')
              .get();

      print('Table Tennis stats exists: ${tableStatsDoc.exists}');
      if (tableStatsDoc.exists) {
        print('Table Tennis stats: ${tableStatsDoc.data()}');
      }
    } catch (e) {
      print('Error debugging statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    // Use the stream provider correctly
    final statisticsAsync =
        widget.userId != null
            ? ref.watch(specificUserStatisticsProvider(widget.userId!))
            : ref.watch(userStatisticsProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: CustomAppBar(title: "Statistics", isBackButtonVisible: true),
      body: RefreshIndicator(
        onRefresh: () async {
          // Force refresh by invalidating the provider
          if (widget.userId != null) {
            ref.invalidate(specificUserStatisticsProvider(widget.userId!));
          } else {
            ref.invalidate(userStatisticsProvider);
          }
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: statisticsAsync.when(
          data: (stats) => _buildStatisticsUI(context, stats),
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          error:
              (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading statistics: ${error.toString()}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.userId != null) {
                          ref.invalidate(
                            specificUserStatisticsProvider(widget.userId!),
                          );
                        } else {
                          ref.invalidate(userStatisticsProvider);
                        }
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildStatisticsUI(BuildContext context, PlayerStatistics stats) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // Completely invalidate the providers
          ref.invalidate(userStatisticsProvider);
          if (widget.userId != null) {
            ref.invalidate(specificUserStatisticsProvider(widget.userId!));
          }

          // Force UI to rebuild with a longer delay
          await Future.delayed(const Duration(milliseconds: 800));

          // Force a full refresh by triggering setState
          if (mounted) {
            setState(() {});
          }

          return;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.03),

                // Profile Avatar
                _buildProfileAvatar(context, userName),

                SizedBox(height: screenHeight * 0.02),

                // Overall Statistics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      context,
                      "${stats.totalMatchesPlayed}",
                      "Total Matches\nPlayed",
                      Colors.redAccent.shade100,
                    ),
                    _buildStatCard(
                      context,
                      "${stats.totalMatchesWon}",
                      "Total Matches\nWon",
                      Colors.greenAccent.shade100,
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // Win Percentage
                _buildWinPercentageCard(context, stats.winPercentage),

                SizedBox(height: screenHeight * 0.02),

                // Sport Specific Stats - Badminton
                if (stats.sportStats.containsKey('badminton'))
                  _buildSportStatCard(
                    context,
                    "Badminton",
                    stats.sportStats['badminton']!,
                    AppColors.primary,
                  ),

                SizedBox(height: screenHeight * 0.02),

                // Sport Specific Stats - Table Tennis
                if (stats.sportStats.containsKey('table tennis'))
                  _buildSportStatCard(
                    context,
                    "Table-Tennis",
                    stats.sportStats['table tennis']!,
                    Colors.blue,
                  ),

                SizedBox(height: screenHeight * 0.02),

                // Recent Matches
                if (stats.recentMatches.isNotEmpty) ...[
                  _buildSectionHeader(context, "Recent Match"),
                  SizedBox(height: screenHeight * 0.01),
                  _buildRecentMatchCard(context, stats.recentMatches.first),
                ],

                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String name) {
    final screenWidth = ScreenSize.screenWidth(context);

    return Column(
      children: [
        CircleAvatar(
          radius: screenWidth * 0.1,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "U",
            style: TextStyle(
              fontSize: screenWidth * 0.12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          name.isNotEmpty ? name : "User",
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Container(
      width: screenWidth * 0.43,
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02,
        horizontal: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.09,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.006),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinPercentageCard(BuildContext context, double percentage) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.018,
        horizontal: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Win Percentage",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            "${percentage.toStringAsFixed(2)}%",
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportStatCard(
    BuildContext context,
    String sport,
    SportStatistics stats,
    Color color,
  ) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sport,
            style: TextStyle(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildStatRow("Played", "${stats.played}", screenWidth),
          _buildStatRow("Won", "${stats.won}", screenWidth),
          _buildStatRow(
            "Win Percentage",
            "${stats.winPercentage.toStringAsFixed(2)}%",
            screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: screenWidth * 0.042, color: Colors.white),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.042,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final screenWidth = ScreenSize.screenWidth(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRecentMatchCard(BuildContext context, RecentMatch match) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);
    final dateFormat = DateFormat('MMMM d, yyyy h:mm a');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.matchId,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color:
                      match.sport.toLowerCase() == 'badminton'
                          ? AppColors.primary
                          : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${match.sport} ${match.mode}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: screenWidth * 0.045,
                color: Colors.grey[700],
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                match.location,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.005),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: screenWidth * 0.045,
                color: Colors.grey[700],
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                dateFormat.format(match.date),
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "vs ${match.opponent}",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color: match.won ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  match.won ? "WON" : "LOST",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
