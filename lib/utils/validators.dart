/// Validates that a string is not empty
String? validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }
  return null;
}

/// Validates that a string can be parsed as a positive number
String? validatePositiveNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }

  try {
    final number = double.parse(value);
    if (number < 0) {
      return 'Value must be positive';
    }
  } catch (e) {
    return 'Please enter a valid number';
  }

  return null;
}

/// Validates that a string is a valid integer
String? validateInteger(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }

  try {
    int.parse(value);
  } catch (e) {
    return 'Please enter a whole number';
  }

  return null;
}
