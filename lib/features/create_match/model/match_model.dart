import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final String sport;
  final String mode;
  final int sets;
  final int points;
  final String team1Name;
  final String team2Name;
  final List<String> team1Players;
  final List<String> team1PlayerName;
  final List<String> team2Players;
  final List<String> team2PlayerName;
  final String location;
  final String status;
  final DateTime createdAt;
  final String createdBy;
  final List<String> keywords;
  final List<List<int>> scores;
  final int currentSetIndex;

  MatchModel({
    required this.matchId,
    required this.sport,
    required this.mode,
    required this.sets,
    required this.points,
    required this.team1Name,
    required this.team2Name,
    required this.team1Players,
    required this.team1PlayerName,
    required this.team2Players,
    required this.team2PlayerName,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    required this.keywords,
    required this.scores,
    required this.currentSetIndex,
  });

  Map<String, dynamic> toMap() {
    // Generate keywords for searching
    final List<String> generateKeywords = [];

    // Add ID
    generateKeywords.add(matchId.toLowerCase());

    // Add team names
    team1Name.toLowerCase().split(' ').forEach((word) {
      if (word.isNotEmpty) generateKeywords.add(word);
    });

    team2Name.toLowerCase().split(' ').forEach((word) {
      if (word.isNotEmpty) generateKeywords.add(word);
    });

    // Add player names
    for (var name in team1PlayerName) {
      name.toLowerCase().split(' ').forEach((word) {
        if (word.isNotEmpty) generateKeywords.add(word);
      });
    }

    for (var name in team2PlayerName) {
      name.toLowerCase().split(' ').forEach((word) {
        if (word.isNotEmpty) generateKeywords.add(word);
      });
    }

    // Add location
    location.toLowerCase().split(' ').forEach((word) {
      if (word.isNotEmpty) generateKeywords.add(word);
    });

    // Add sport and mode
    generateKeywords.add(sport.toLowerCase());
    generateKeywords.add(mode.toLowerCase());

    // Add status
    generateKeywords.add(status.toLowerCase());

    // Remove duplicates
    final keywords = generateKeywords.toSet().toList();

    final Map<String, List<int>> scoresMap = {
      for (int i = 0; i < scores.length; i++) 'set_$i': scores[i],
    };

    return {
      'matchId': matchId,
      'sport': sport,
      'mode': mode,
      'sets': sets,
      'points': points,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Players': team1Players,
      'team1PlayerName': team1PlayerName,
      'team2Players': team2Players,
      'team2PlayerName': team2PlayerName,
      'location': location,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'keywords': keywords,
      'scoresMap': scoresMap, // Save as map
      'currentSetIndex': currentSetIndex,
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    try {
      final Map<String, dynamic> scoresMap = Map<String, dynamic>.from(
        map['scoresMap'] ?? {},
      );

      List<List<int>> scoresList = [];

      // Handle empty scores case
      if (scoresMap.isEmpty) {
        // Initialize with default scores based on sets
        final sets = map['sets'] ?? 3;
        scoresList = List.generate(sets, (_) => [0, 0]);
      } else {
        // Convert map to ordered list of sets
        final sortedKeys =
            scoresMap.keys.toList()..sort(
              (a, b) => int.parse(
                a.split('_')[1],
              ).compareTo(int.parse(b.split('_')[1])),
            );

        for (final key in sortedKeys) {
          final value = scoresMap[key];
          if (value is List && value.length == 2) {
            scoresList.add([value[0] as int, value[1] as int]);
          }
        }
      }

      // Always ensure we have at least one set
      if (scoresList.isEmpty) {
        scoresList.add([0, 0]);
      }

      // Use null-aware access and default values for everything
      return MatchModel(
        matchId: map['matchId'] ?? '',
        sport: map['sport'] ?? '',
        mode: map['mode'] ?? '',
        sets: map['sets'] ?? 3,
        points: map['points'] ?? 21,
        team1Name: map['team1Name'] ?? '',
        team2Name: map['team2Name'] ?? '',
        team1Players: List<String>.from(map['team1Players'] ?? []),
        team1PlayerName: List<String>.from(map['team1PlayerName'] ?? []),
        team2Players: List<String>.from(map['team2Players'] ?? []),
        team2PlayerName: List<String>.from(map['team2PlayerName'] ?? []),
        location: map['location'] ?? '',
        status: map['status'] ?? '',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdBy: (map['createdBy'] ?? ''),
        keywords: List<String>.from(map['keywords'] ?? []),
        scores: scoresList,
        currentSetIndex: map['currentSetIndex'] ?? 0,
      );
    } catch (e) {
      print('Error parsing match data: $e');
      // Return a "fallback" model in case of error
      return MatchModel(
        matchId: map['matchId'] ?? 'error',
        sport: 'Unknown',
        mode: 'singles',
        sets: 3,
        points: 21,
        team1Name: 'Team 1',
        team2Name: 'Team 2',
        team1Players: [],
        team1PlayerName: [],
        team2Players: [],
        team2PlayerName: [],
        location: 'Unknown',
        status: 'unknown',
        createdAt: DateTime.now(),
        createdBy: '',
        keywords: [],
        scores: [
          [0, 0],
        ],
        currentSetIndex: 0,
      );
    }
  }
}
