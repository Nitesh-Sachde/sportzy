// lib/features/create_match/model/match_model.dart
class MatchModel {
  final String matchId;
  final String sport;
  final String mode;
  final int sets;
  final int points;
  final String team1Name;
  final String team2Name;
  final List<String> team1Players;
  final List<String> team2Players;
  final String location;
  final String status;
  final DateTime createdAt;
  final List<String> keywords;

  MatchModel({
    required this.matchId,
    required this.sport,
    required this.mode,
    required this.sets,
    required this.points,
    required this.team1Name,
    required this.team2Name,
    required this.team1Players,
    required this.team2Players,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.keywords,
  });

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'sport': sport,
      'mode': mode,
      'sets': sets,
      'points': points,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Players': team1Players,
      'team2Players': team2Players,
      'location': location,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'keywords': keywords,
    };
  }
}
