import 'package:flutter_riverpod/flutter_riverpod.dart';

final matchFormProvider =
    StateNotifierProvider<MatchFormNotifier, MatchFormState>((ref) {
      return MatchFormNotifier();
    });

class MatchFormState {
  final String sport;
  final String mode;
  final int sets;
  final int points;
  final String location;
  final String team1Name;
  final String team2Name;

  MatchFormState({
    this.sport = 'Badminton',
    this.mode = 'singles',
    this.sets = 3,
    this.points = 21,
    this.location = '',
    this.team1Name = '',
    this.team2Name = '',
  });

  MatchFormState copyWith({
    String? sport,
    String? mode,
    int? sets,
    int? points,
    String? location,
    String? team1Name,
    String? team2Name,
  }) {
    return MatchFormState(
      sport: sport ?? this.sport,
      mode: mode ?? this.mode,
      sets: sets ?? this.sets,
      points: points ?? this.points,
      location: location ?? this.location,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
    );
  }
}

class MatchFormNotifier extends StateNotifier<MatchFormState> {
  MatchFormNotifier() : super(MatchFormState());

  void updateSport(String sport) => state = state.copyWith(sport: sport);
  void updateMode(String mode) => state = state.copyWith(mode: mode);
  void updateSets(int sets) => state = state.copyWith(sets: sets);
  void updatePoints(int points) => state = state.copyWith(points: points);
  void updateLocation(String location) =>
      state = state.copyWith(location: location);
  void updateTeamName(int team, String name) {
    if (team == 1) {
      state = state.copyWith(team1Name: name);
    } else {
      state = state.copyWith(team2Name: name);
    }
  }
}
