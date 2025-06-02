/// Utility functions for formatting and validating phone numbers
class PhoneFormatter {
  /// Formats a phone number string to the standard US format: (123) 456-7890
  /// 
  /// This function strips all non-digit characters from the input,
  /// then formats the result according to the US phone number standard.
  /// 
  /// If the input doesn't contain exactly 10 digits after stripping,
  /// it returns the original input unchanged.
  static String formatPhone(String phone) {
    // Strip all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    
    // If we don't have exactly 10 digits, return the original string
    if (digitsOnly.length != 10) {
      return phone;
    }
    
    // Format as (XXX) XXX-XXXX
    return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  }
  
  /// Formats the phone number as the user types
  /// 
  /// This is useful for TextFields with onChanged handlers
  static String formatPhoneWhileTyping(String phone) {
    // Strip all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    
    // Format based on the length of the input
    if (digitsOnly.isEmpty) {
      return '';
    } else if (digitsOnly.length < 4) {
      return '($digitsOnly';
    } else if (digitsOnly.length < 7) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3)}';
    } else {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6, min(10, digitsOnly.length))}';
    }
  }
  
  /// Extracts only the digits from a phone number string
  static String extractDigitsOnly(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }
  
  /// Validates if a phone number has exactly 10 digits after stripping non-digits
  static bool isValidPhone(String phone) {
    final digitsOnly = extractDigitsOnly(phone);
    return digitsOnly.length == 10;
  }
  
  /// Returns the minimum between two integers
  static int min(int a, int b) => a < b ? a : b;
}
