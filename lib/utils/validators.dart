// lib/utils/validators.dart
// Input validation utilities

class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
  
  // Password validation (min 8 chars, 1 uppercase, 1 lowercase, 1 number)
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasDigit;
  }
  
  // OTP validation (6 digits)
  static bool isValidOTP(String otp) {
    final otpRegex = RegExp(r'^\d{6}$');
    return otpRegex.hasMatch(otp);
  }
  
  // Age validation from birthdate
  static bool isValidAge(DateTime birthdate) {
    final now = DateTime.now();
    final age = now.year - birthdate.year;
    
    // Check if birthday hasn't occurred this year yet
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      return age - 1 >= 13 && age - 1 <= 120;
    }
    
    return age >= 13 && age <= 120;
  }
  
  // Calculate age from birthdate
  static int calculateAge(DateTime birthdate) {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    
    return age;
  }
  
  // Name validation (2-50 chars, letters and spaces only)
  static bool isValidName(String name) {
    if (name.trim().length < 2 || name.trim().length > 50) return false;
    
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    return nameRegex.hasMatch(name.trim());
  }
  
  // File size validation
  static bool isValidFileSize(int fileSizeBytes, int maxSizeBytes) {
    return fileSizeBytes <= maxSizeBytes;
  }
  
  // File extension validation
  static bool isValidFileExtension(String filename, List<String> allowedExtensions) {
    final extension = filename.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }
  
  // Phone number validation (10 digits)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }
  
  // Date range validation
  static bool isDateInRange(DateTime date, DateTime minDate, DateTime maxDate) {
    return date.isAfter(minDate) && date.isBefore(maxDate);
  }
  
  // Birthdate validation (between 1900 and today)
  static bool isValidBirthdate(DateTime birthdate) {
    final minDate = DateTime(1900, 1, 1);
    final maxDate = DateTime.now();
    
    return birthdate.isAfter(minDate) && 
           birthdate.isBefore(maxDate) && 
           isValidAge(birthdate);
  }
}
