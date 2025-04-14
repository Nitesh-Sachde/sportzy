// lib/features/create_match/services/match_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/match_model.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateMatchId(String sport, String mode) {
    final prefix =
        sport.toLowerCase() == "table tennis" ? "TT" : "BM"; // TT or BM
    final type = mode.toLowerCase() == "singles" ? "1" : "2";
    final randomDigits = Random().nextInt(9000) + 1000; // 4-digit random
    return "$prefix$type$randomDigits";
  }

  List<String> generateKeywords(String value) {
    final lowercase = value.toLowerCase();
    return List.generate(
      lowercase.length,
      (i) => lowercase.substring(0, i + 1),
    );
  }

  Future<void> createMatch(MatchModel match) async {
    await _firestore
        .collection("matches")
        .doc(match.matchId)
        .set(match.toMap());
  }

  MatchModel buildMatchFromForm({
    required String sport,
    required String mode,
    required int sets,
    required int points,
    required String team1Name,
    required String team2Name,
    required List<String> team1Players,
    required List<String> team2Players,
    required String location,
  }) {
    final matchId = _generateMatchId(sport, mode);

    final keywords = [
      ...generateKeywords(matchId),
      ...generateKeywords(team1Name),
      ...generateKeywords(team2Name),
      ...generateKeywords(location),
    ];

    return MatchModel(
      matchId: matchId,
      sport: sport,
      mode: mode,
      sets: sets,
      points: points,
      team1Name: team1Name,
      team2Name: team2Name,
      team1Players: team1Players,
      team2Players: team2Players,
      location: location,
      status: 'upcoming',
      createdAt: DateTime.now(),
      keywords: keywords.toSet().toList(), // remove duplicates
    );
  }
}
