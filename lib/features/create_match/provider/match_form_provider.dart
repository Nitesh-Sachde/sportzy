import 'package:flutter_riverpod/flutter_riverpod.dart';

final matchFormProvider =
    StateNotifierProvider<MatchFormNotifier, MatchFormState>((ref) {
      return MatchFormNotifier();
    });

class MatchFormState {
  final String sport;
  final String mode; // "Singles" or "Doubles"
  final int sets;
  final int points;
  final String location;

  MatchFormState({
    this.sport = 'Badminton',
    this.mode = 'Singles',
    this.sets = 3,
    this.points = 21,
    this.location = '',
  });

  bool get isDoubles => mode.toLowerCase() == 'doubles';

  MatchFormState copyWith({
    String? sport,
    String? mode,
    int? sets,
    int? points,
    String? location,
  }) {
    return MatchFormState(
      sport: sport ?? this.sport,
      mode: mode ?? this.mode,
      sets: sets ?? this.sets,
      points: points ?? this.points,
      location: location ?? this.location,
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
}
