import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final String sport;
  final String mode;
  final String team1Name;
  final String team2Name;
  final List<String> team1Players;
  final List<String> team2Players;
  final String location;
  final DateTime createdAt;

  MatchModel({
    required this.matchId,
    required this.sport,
    required this.mode,
    required this.team1Name,
    required this.team2Name,
    required this.team1Players,
    required this.team2Players,
    required this.location,
    required this.createdAt,
  });

  factory MatchModel.fromMap(Map<String, dynamic> data) {
    return MatchModel(
      matchId: data['matchId'],
      sport: data['sport'],
      mode: data['mode'],
      team1Name: data['team1Name'],
      team2Name: data['team2Name'],
      team1Players: List<String>.from(data['team1Players']),
      team2Players: List<String>.from(data['team2Players']),
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
