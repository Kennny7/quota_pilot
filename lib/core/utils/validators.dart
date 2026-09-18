// lib/core/utils/validators.dart

class Validators {
  Validators._();

  static String? requiredField(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? emailOrLabel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account email or label is required';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String message = 'Enter a valid positive number']) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a number';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return message;
    }
    return null;
  }

  static String? percentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a percentage';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0 || parsed > 100) {
      return 'Percentage must be between 0 and 100';
    }
    return null;
  }
}
