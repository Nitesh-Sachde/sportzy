import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerStatistics {
  final int totalMatchesPlayed;
  final int totalMatchesWon;
  final Map<String, SportStatistics> sportStats;
  final List<RecentMatch> recentMatches;

  PlayerStatistics({
    required this.totalMatchesPlayed,
    required this.totalMatchesWon,
    required this.sportStats,
    required this.recentMatches,
  });

  double get winPercentage {
    if (totalMatchesPlayed == 0) return 0.0;
    return (totalMatchesWon / totalMatchesPlayed) * 100;
  }

  factory PlayerStatistics.empty() {
    return PlayerStatistics(
      totalMatchesPlayed: 0,
      totalMatchesWon: 0,
      sportStats: {
        'badminton': SportStatistics(played: 0, won: 0),
        'table tennis': SportStatistics(played: 0, won: 0),
      },
      recentMatches: [],
    );
  }

  factory PlayerStatistics.fromMap(Map<String, dynamic> map) {
    final sportStatsMap = (map['sportStats'] as Map<String, dynamic>?) ?? {};
    final sportStats = sportStatsMap.map(
      (key, value) =>
          MapEntry(key, SportStatistics.fromMap(value as Map<String, dynamic>)),
    );

    final recentMatchesList =
        (map['recentMatches'] as List?)
            ?.map((match) => RecentMatch.fromMap(match as Map<String, dynamic>))
            .toList() ??
        [];

    return PlayerStatistics(
      totalMatchesPlayed: map['totalMatchesPlayed'] ?? 0,
      totalMatchesWon: map['totalMatchesWon'] ?? 0,
      sportStats: sportStats,
      recentMatches: recentMatchesList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMatchesPlayed': totalMatchesPlayed,
      'totalMatchesWon': totalMatchesWon,
      'sportStats': sportStats.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'recentMatches': recentMatches.map((match) => match.toMap()).toList(),
    };
  }

  PlayerStatistics copyWith({
    int? totalMatchesPlayed,
    int? totalMatchesWon,
    Map<String, SportStatistics>? sportStats,
    List<RecentMatch>? recentMatches,
  }) {
    return PlayerStatistics(
      totalMatchesPlayed: totalMatchesPlayed ?? this.totalMatchesPlayed,
      totalMatchesWon: totalMatchesWon ?? this.totalMatchesWon,
      sportStats: sportStats ?? this.sportStats,
      recentMatches: recentMatches ?? this.recentMatches,
    );
  }
}

class SportStatistics {
  final int played;
  final int won;

  SportStatistics({required this.played, required this.won});

  double get winPercentage => played > 0 ? (won / played) * 100 : 0;

  factory SportStatistics.fromMap(Map<String, dynamic> map) {
    return SportStatistics(played: map['played'] ?? 0, won: map['won'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'played': played, 'won': won};
  }

  SportStatistics copyWith({int? played, int? won}) {
    return SportStatistics(played: played ?? this.played, won: won ?? this.won);
  }
}

class RecentMatch {
  final String matchId;
  final String sport;
  final String mode;
  final String location;
  final DateTime date;
  final String opponent;
  final bool won;

  RecentMatch({
    required this.matchId,
    required this.sport,
    required this.mode,
    required this.location,
    required this.date,
    required this.opponent,
    required this.won,
  });

  factory RecentMatch.fromMap(Map<String, dynamic> map) {
    return RecentMatch(
      matchId: map['matchId'] ?? '',
      sport: map['sport'] ?? '',
      mode: map['mode'] ?? '',
      location: map['location'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      opponent: map['opponent'] ?? '',
      won: map['won'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'sport': sport,
      'mode': mode,
      'location': location,
      'date': Timestamp.fromDate(date),
      'opponent': opponent,
      'won': won,
    };
  }
}

// Add this to your user registration process:
Future<void> initializePlayerStatistics(String userId) async {
  final batch = FirebaseFirestore.instance.batch();

  // Initialize overall stats
  final overallStatsRef = FirebaseFirestore.instance
      .collection('player_stats')
      .doc(userId)
      .collection('overall')
      .doc('stats');

  batch.set(overallStatsRef, {
    'totalMatchesPlayed': 0,
    'totalMatchesWon': 0,
    'winPercentage': 0.0,
  });

  // Initialize badminton stats
  final badmintonRef = FirebaseFirestore.instance
      .collection('player_stats')
      .doc(userId)
      .collection('sports')
      .doc('badminton');

  batch.set(badmintonRef, {'played': 0, 'won': 0, 'winPercentage': 0.0});

  // Initialize table tennis stats
  final tableTennisRef = FirebaseFirestore.instance
      .collection('player_stats')
      .doc(userId)
      .collection('sports')
      .doc('table_tennis');

  batch.set(tableTennisRef, {'played': 0, 'won': 0, 'winPercentage': 0.0});

  // Commit all the writes
  await batch.commit();
}
