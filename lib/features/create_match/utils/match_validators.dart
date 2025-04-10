class MatchValidators {
  static String? validateMatchLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a valid location';
    }
    return null;
  }

  static String? validateTeamName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Team name cannot be empty';
    }
    return null;
  }

  static String? validatePlayerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Player name cannot be empty';
    }
    return null;
  }

  static String? validatePoints(int? value) {
    if (value == null || value < 1) {
      return 'Points must be greater than 0';
    }
    return null;
  }

  static String? validateSets(int? value) {
    if (value == null || value < 1) {
      return 'Set count must be at least 1';
    }
    return null;
  }
}
