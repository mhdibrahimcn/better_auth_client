/// Input validation utilities for Better Auth.
///
/// This class provides static methods for validating common input fields
/// used in authentication forms.
///
/// ## Usage
///
/// ```dart
/// final emailError = Validators.validateEmail(emailController.text);
/// final passwordError = Validators.validatePassword(passwordController.text);
///
/// if (emailError == null && passwordError == null) {
///   // Form is valid, proceed with submission
/// }
/// ```
class Validators {
  /// Validates an email address.
  ///
  /// Returns null if valid, or an error message if invalid.
  ///
  /// [email] The email to validate. Can be null.
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    // Basic email validation regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a password.
  ///
  /// Returns null if valid, or an error message if invalid.
  ///
  /// [password] The password to validate. Can be null.
  /// [minLength] Minimum password length (default: 8).
  static String? validatePassword(String? password, {int minLength = 8}) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates that a confirmation password matches the original.
  ///
  /// Returns null if passwords match, or an error message if they don't.
  ///
  /// [password] The original password.
  /// [confirmation] The password confirmation. Can be null.
  static String? validatePasswordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmation) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates a name.
  ///
  /// Returns null if valid, or an error message if invalid.
  ///
  /// [name] The name to validate. Can be null.
  /// [minLength] Minimum name length (default: 2).
  /// [maxLength] Maximum name length (default: 50).
  static String? validateName(String? name, {int minLength = 2, int maxLength = 50}) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    if (name.length > maxLength) {
      return 'Name must be less than $maxLength characters';
    }
    return null;
  }
}
