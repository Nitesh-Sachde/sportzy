class Validators {
  // Validates Name Format
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required";
    } else if (value.length < 3 || value.length > 12) {
      return "Enter a name between 3 and 12 characters";
    }
    return null; // Valid email
  }

  // Validates Email Format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    } else if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null; // Valid email
  }

  //  Sign-In Password Validation
  static String? validateSignInPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    return null;
  }

  // Validates Password Strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    } else if (!RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
    ).hasMatch(value)) {
      return "Password must contain letters and numbers";
    }
    return null; // Valid password
  }

  // Validates Confirm Password (Matches Original Password)
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Confirm Password is required";
    } else if (value != password) {
      return "Passwords do not match";
    }
    return null; // Valid confirm password
  }
}
