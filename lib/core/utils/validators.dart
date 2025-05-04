class Validators {
  // Validates Name Format
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required";
    } else if (value.length < 3) {
      return "Name should be at least 3 characters";
    } else if (value.length > 50) {
      return "Name is too long (max 50 characters)";
    } else if (!RegExp(r'^[a-zA-Z]+(?: [a-zA-Z]+)*$').hasMatch(value)) {
      return "Name should contain only letters and spaces";
    }
    return null; // Valid name
  }

  // Validates Username Format
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username is required";
    } else if (value.length < 3) {
      return "Username should be at least 3 characters";
    } else if (value.length > 20) {
      return "Username is too long (max 20 characters)";
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return "Username should contain only letters, numbers, and underscores";
    }
    return null; // Valid username
  }

  // Validates Full Name Format
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return "Full name is required";
    } else if (value.length < 3) {
      return "Full name should be at least 3 characters";
    } else if (value.length > 100) {
      return "Full name is too long (max 100 characters)";
    } else if (!RegExp(r'^[a-zA-Z]+(?: [a-zA-Z]+)*$').hasMatch(value)) {
      return "Full name should contain only letters and spaces";
    }
    return null; // Valid full name
  }

  // Validates Email Format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    } else if (!RegExp(
      r'^[a-zA-Z][a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null; // Valid email
  }

  // Simple Sign-In Password Validation (just checks if it's empty)
  static String? validateSignInPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    return null; // Valid password for sign-in
  }

  // Strong Password Validation for Registration
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    } else if (value.length < 8) {
      return "Password must be at least 8 characters";
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must contain at least one uppercase letter";
    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Password must contain at least one lowercase letter";
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must contain at least one number";
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password must contain at least one special character";
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

  // Validates Phone Number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Please enter a valid 10-digit phone number";
    }
    return null; // Valid phone
  }

  // Validates Age
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Age is optional
    }

    final age = int.tryParse(value);
    if (age == null) {
      return "Age must be a number";
    } else if (age < 5 || age > 120) {
      return "Please enter a valid age between 5 and 120";
    }
    return null; // Valid age
  }

  // Validates Bio (optional)
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    } else if (value.length > 300) {
      return "Bio is too long (max 300 characters)";
    }
    return null; // Valid bio
  }

  // Validates City
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return null; // City is optional
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "City should contain only letters and spaces";
    } else if (value.length > 50) {
      return "City name too long";
    }
    return null; // Valid city
  }

  // Validates State
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return null; // State is optional
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "State should contain only letters and spaces";
    } else if (value.length > 50) {
      return "State name too long";
    }
    return null; // Valid state
  }

  // Validates Country
  static String? validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Country is optional
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Country should contain only letters and spaces";
    } else if (value.length > 50) {
      return "Country name too long";
    }
    return null; // Valid country
  }

  // Validates Pincode/Zip
  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Pincode is optional
    } else if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return "Please enter a valid 6-digit pincode";
    }
    return null; // Valid pincode
  }
}
