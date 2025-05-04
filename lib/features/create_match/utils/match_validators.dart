class MatchValidators {
  static String? validateMatchLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a location';
    } else if (value.length < 3) {
      return 'Location name is too short';
    } else if (value.length > 100) {
      return 'Location name is too long';
    } else if (!RegExp(r'^[a-zA-Z0-9\s,.-]+$').hasMatch(value)) {
      return 'Please enter a valid location';
    }
    return null;
  }

  static String? validateTeamName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Team name cannot be empty';
    } else if (value.length < 2) {
      return 'Team name should be at least 2 characters';
    } else if (value.length > 20) {
      return 'Team name is too long (max 20 characters)';
    } else if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Team name should only contain letters, numbers and spaces';
    }
    return null;
  }

  static String? validatePlayerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Player name cannot be empty';
    } else if (value.length < 2) {
      return 'Player name should be at least 2 characters';
    } else if (value.length > 30) {
      return 'Player name is too long (max 30 characters)';
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Player name should only contain letters and spaces';
    }
    return null;
  }

  static String? validatePoints(int? value) {
    if (value == null) {
      return 'Points must be specified';
    } else if (value < 1) {
      return 'Points must be greater than 0';
    } else if (value > 100) {
      return 'Points should not exceed 100';
    }
    return null;
  }

  static String? validateSets(int? value) {
    if (value == null) {
      return 'Set count must be specified';
    } else if (value < 1) {
      return 'Set count must be at least 1';
    } else if (value > 9) {
      return 'Set count should not exceed 9';
    } else if (value % 2 == 0) {
      return 'Set count should be an odd number';
    }
    return null;
  }

  // Validate date and time (ensure match is not scheduled in the past)
  static String? validateDateTime(DateTime? value) {
    if (value == null) {
      return 'Please select a date and time';
    }

    final now = DateTime.now();
    if (value.isBefore(now)) {
      return 'Cannot schedule a match in the past';
    }

    return null;
  }
}
