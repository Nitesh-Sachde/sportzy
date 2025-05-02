import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:sportzy/features/playerprofile/model/statistics_model.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user statistics
  Future<PlayerStatistics> getCurrentUserStatistics() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return getUserStatistics(user.uid);
  }

  // Add a method to create default stats if they don't exist
  Future<void> ensureStatisticsExist(String userId) async {
    // Check if overall stats document exists
    final overallDoc =
        await _firestore
            .collection('player_stats')
            .doc(userId)
            .collection('overall')
            .doc('stats')
            .get();

    // If it doesn't exist, create it with default values
    if (!overallDoc.exists) {
      await _firestore
          .collection('player_stats')
          .doc(userId)
          .collection('overall')
          .doc('stats')
          .set({
            'totalMatchesPlayed': 0,
            'totalMatchesWon': 0,
            'winPercentage': 0.0,
          });

      // Create default sport stats
      await _firestore
          .collection('player_stats')
          .doc(userId)
          .collection('sports')
          .doc('badminton')
          .set({'played': 0, 'won': 0, 'winPercentage': 0.0});

      await _firestore
          .collection('player_stats')
          .doc(userId)
          .collection('sports')
          .doc('table_tennis')
          .set({'played': 0, 'won': 0, 'winPercentage': 0.0});
    }
  }

  // Get statistics for a specific user
  Future<PlayerStatistics> getUserStatistics(String userId) async {
    try {
      // Ensure statistics documents exist
      await ensureStatisticsExist(userId);

      // Get the overall stats
      final overallStatsDoc = await _firestore
          .collection('player_stats')
          .doc(userId)
          .collection('overall')
          .doc('stats')
          .get(GetOptions(source: Source.server)); // Force server fetch

      // Get sport-specific stats using standardized IDs
      final badmintonStatsDoc = await _firestore
          .collection('player_stats')
          .doc(userId)
          .collection('sports')
          .doc('badminton')
          .get(GetOptions(source: Source.server)); // Force server fetch

      final tableTennisStatsDoc = await _firestore
          .collection('player_stats')
          .doc(userId)
          .collection('sports')
          .doc('table_tennis')
          .get(GetOptions(source: Source.server)); // Force server fetch

      // Get recent matches
      final recentMatchesQuery = await _firestore
          .collection('player_stats')
          .doc(userId)
          .collection('recent_matches')
          .orderBy('date', descending: true)
          .limit(10)
          .get(GetOptions(source: Source.server)); // Force server fetch

      // Build sport stats
      final sportStats = <String, SportStatistics>{};

      // Add badminton stats
      if (badmintonStatsDoc.exists) {
        final data = badmintonStatsDoc.data() ?? {};
        sportStats['badminton'] = SportStatistics(
          played: data['played'] ?? 0,
          won: data['won'] ?? 0,
        );
      } else {
        sportStats['badminton'] = SportStatistics(played: 0, won: 0);
      }

      // Add table tennis stats
      if (tableTennisStatsDoc.exists) {
        final data = tableTennisStatsDoc.data() ?? {};
        sportStats['table tennis'] = SportStatistics(
          played: data['played'] ?? 0,
          won: data['won'] ?? 0,
        );
      } else {
        sportStats['table tennis'] = SportStatistics(played: 0, won: 0);
      }

      // Parse recent matches
      final recentMatches = <RecentMatch>[];
      for (final doc in recentMatchesQuery.docs) {
        final data = doc.data();
        if (data['date'] != null) {
          recentMatches.add(
            RecentMatch(
              matchId: data['matchId'] ?? '',
              sport: data['sport'] ?? '',
              mode: data['mode'] ?? '',
              location: data['location'] ?? '',
              date: (data['date'] as Timestamp).toDate(),
              opponent: data['opponent'] ?? '',
              won: data['won'] ?? false,
            ),
          );
        }
      }

      // Create PlayerStatistics
      if (overallStatsDoc.exists) {
        final data = overallStatsDoc.data() ?? {};
        return PlayerStatistics(
          totalMatchesPlayed: data['totalMatchesPlayed'] ?? 0,
          totalMatchesWon: data['totalMatchesWon'] ?? 0,
          sportStats: sportStats,
          recentMatches: recentMatches,
        );
      }

      // Return empty stats if document doesn't exist
      return PlayerStatistics.empty();
    } catch (e) {
      print("Error fetching statistics: $e");
      // Return empty stats on error
      return PlayerStatistics.empty();
    }
  }

  // Update this method to standardize sport IDs
  Future<void> updateStatisticsAfterMatch(
    MatchModel match,
    List<String> winnerPlayerIds,
  ) async {
    try {
      if (match.team1Players.isEmpty || match.team2Players.isEmpty) {
        print("Warning: Match has empty player lists");
      }

      final batch = _firestore.batch();
      final allPlayerIds = [...match.team1Players, ...match.team2Players];

      // Standardize sport ID to match what we use when fetching
      final String sportId = _getStandardizedSportId(match.sport);

      for (final playerId in allPlayerIds) {
        // Check if playerId is valid
        if (playerId.isEmpty) {
          print("Warning: Empty player ID found, skipping");
          continue;
        }

        final isWinner = winnerPlayerIds.contains(playerId);
        final isTeam1 = match.team1Players.contains(playerId);

        // Determine opponent team name
        final opponentTeam = isTeam1 ? match.team2Name : match.team1Name;

        // References to the documents
        final overallStatsRef = _firestore
            .collection('player_stats')
            .doc(playerId)
            .collection('overall')
            .doc('stats');

        final sportStatsRef = _firestore
            .collection('player_stats')
            .doc(playerId)
            .collection('sports')
            .doc(sportId);

        final recentMatchRef = _firestore
            .collection('player_stats')
            .doc(playerId)
            .collection('recent_matches')
            .doc(match.matchId);

        // Get current stats or initialize them
        final overallDoc = await overallStatsRef.get();
        final sportDoc = await sportStatsRef.get();

        // Update overall stats
        final Map<String, dynamic> overallUpdates = {
          'totalMatchesPlayed': FieldValue.increment(1),
        };

        if (isWinner) {
          overallUpdates['totalMatchesWon'] = FieldValue.increment(1);
        }

        // Update sport-specific stats
        final Map<String, dynamic> sportUpdates = {
          'played': FieldValue.increment(1),
        };

        if (isWinner) {
          sportUpdates['won'] = FieldValue.increment(1);
        }

        // Calculate and update win percentages
        if (overallDoc.exists) {
          final currentOverall = overallDoc.data() ?? {};
          final int currentPlayed =
              (currentOverall['totalMatchesPlayed'] ?? 0) + 1;
          final int currentWins =
              (currentOverall['totalMatchesWon'] ?? 0) + (isWinner ? 1 : 0);
          overallUpdates['winPercentage'] = (currentWins / currentPlayed) * 100;
        } else {
          overallUpdates['winPercentage'] = isWinner ? 100.0 : 0.0;
        }

        if (sportDoc.exists) {
          final currentSport = sportDoc.data() ?? {};
          final int currentPlayed = (currentSport['played'] ?? 0) + 1;
          final int currentWins =
              (currentSport['won'] ?? 0) + (isWinner ? 1 : 0);
          sportUpdates['winPercentage'] = (currentWins / currentPlayed) * 100;
        } else {
          sportUpdates['winPercentage'] = isWinner ? 100.0 : 0.0;
        }

        // Add recent match
        final recentMatchData = {
          'matchId': match.matchId,
          'sport': match.sport,
          'mode': match.mode,
          'location': match.location,
          'date': Timestamp.fromDate(match.createdAt),
          'opponent': opponentTeam,
          'won': isWinner,
        };

        // Use batch to perform all writes atomically
        batch.set(overallStatsRef, overallUpdates, SetOptions(merge: true));
        batch.set(sportStatsRef, sportUpdates, SetOptions(merge: true));
        batch.set(recentMatchRef, recentMatchData);
      }

      await batch.commit();
      print("Statistics updated successfully for all players");
    } catch (e) {
      print("Error in updateStatisticsAfterMatch: $e");
      rethrow;
    }
  }

  // Add this helper method to standardize sport IDs
  String _getStandardizedSportId(String sport) {
    final normalizedSport = sport.toLowerCase().trim();

    if (normalizedSport.contains('badminton')) {
      return 'badminton';
    } else if (normalizedSport.contains('table') ||
        normalizedSport.contains('tennis')) {
      return 'table_tennis';
    }

    // Default case - use the lowercase sport name
    return normalizedSport;
  }
}
