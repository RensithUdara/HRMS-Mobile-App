class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  // Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'this field'}';
    }
    return null;
  }

  // Phone number validation (Sri Lankan)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check Sri Lankan phone number patterns
    // Mobile: 07XXXXXXXX (10 digits) or +947XXXXXXXX (12 digits)
    // Landline: 0XXXXXXXXX (11 digits) or +94XXXXXXXXXX (13 digits)
    
    if (digitsOnly.startsWith('947') && digitsOnly.length == 12) {
      // International format mobile
      return null;
    } else if (digitsOnly.startsWith('94') && digitsOnly.length == 13) {
      // International format landline
      return null;
    } else if (digitsOnly.startsWith('07') && digitsOnly.length == 10) {
      // Local format mobile
      return null;
    } else if (digitsOnly.startsWith('0') && digitsOnly.length == 11) {
      // Local format landline
      return null;
    }
    
    return 'Please enter a valid Sri Lankan phone number';
  }

  // Name validation
  static String? name(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldName ?? 'name'}';
    }
    
    if (value.trim().length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters long';
    }
    
    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
      return '${fieldName ?? 'Name'} can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Employee ID validation
  static String? employeeId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter employee ID';
    }
    
    final cleanValue = value.trim().toUpperCase();
    
    // Sri Lankan company employee ID pattern (e.g., EMP001, HR2024001, etc.)
    if (!RegExp(r'^[A-Z]{2,4}\d{3,6}$').hasMatch(cleanValue)) {
      return 'Employee ID must be in format: ABC123 (2-4 letters followed by 3-6 digits)';
    }
    
    return null;
  }

  // NIC validation (Sri Lankan)
  static String? nic(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter NIC number';
    }
    
    final cleanValue = value.trim().toUpperCase();
    
    // Old format: 9 digits + V/X (e.g., 123456789V)
    // New format: 12 digits (e.g., 199812345678)
    
    if (RegExp(r'^\d{9}[VX]$').hasMatch(cleanValue)) {
      // Old format validation
      return null;
    } else if (RegExp(r'^\d{12}$').hasMatch(cleanValue)) {
      // New format validation
      return null;
    }
    
    return 'Please enter a valid Sri Lankan NIC number';
  }

  // EPF number validation
  static String? epfNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter EPF number';
    }
    
    final cleanValue = value.trim();
    
    // EPF number is typically 7-8 digits
    if (!RegExp(r'^\d{7,8}$').hasMatch(cleanValue)) {
      return 'EPF number must be 7-8 digits';
    }
    
    return null;
  }

  // Salary validation
  static String? salary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter salary amount';
    }
    
    final amount = double.tryParse(value.trim().replaceAll(',', ''));
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount < 0) {
      return 'Salary cannot be negative';
    }
    
    if (amount > 10000000) {
      return 'Salary amount seems too high';
    }
    
    return null;
  }

  // Date validation
  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a date';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Age validation
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter age';
    }
    
    final ageValue = int.tryParse(value.trim());
    if (ageValue == null) {
      return 'Please enter a valid age';
    }
    
    if (ageValue < 18) {
      return 'Employee must be at least 18 years old';
    }
    
    if (ageValue > 100) {
      return 'Please enter a valid age';
    }
    
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}
