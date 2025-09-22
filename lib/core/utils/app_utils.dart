import 'package:flutter/material.dart';

/// Utility class for QR code operations and authentication key processing
class QRUtils {
  // Private constructor to prevent instantiation
  QRUtils._();

  /// Extract authentication key from QR code data
  static String? extractAuthKeyFromQR(String qrData) {
    try {
      // Handle Google Authenticator URI format: otpauth://totp/label?secret=key&issuer=issuer
      if (qrData.startsWith('otpauth://')) {
        final uri = Uri.parse(qrData);
        return uri.queryParameters['secret'];
      }
      
      // Handle direct key format (base32)
      final cleanData = qrData.trim().replaceAll(' ', '').toUpperCase();
      if (RegExp(r'^[A-Z2-7]+$').hasMatch(cleanData) && cleanData.length >= 16) {
        return cleanData;
      }
      
      // Handle key-value pairs like "secret=ABCD1234..."
      if (qrData.toLowerCase().contains('secret=')) {
        final match = RegExp(r'secret=([A-Z2-7]+)', caseSensitive: false).firstMatch(qrData);
        return match?.group(1);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Validate if QR data contains a valid authentication key
  static bool isValidAuthQR(String qrData) {
    return extractAuthKeyFromQR(qrData) != null;
  }

  /// Format authentication key for display (add spaces every 4 characters)
  static String formatAuthKey(String key) {
    final cleanKey = key.replaceAll(' ', '').toUpperCase();
    final formatted = StringBuffer();
    
    for (int i = 0; i < cleanKey.length; i += 4) {
      if (i > 0) formatted.write(' ');
      final end = (i + 4 < cleanKey.length) ? i + 4 : cleanKey.length;
      formatted.write(cleanKey.substring(i, end));
    }
    
    return formatted.toString();
  }

  /// Clean authentication key (remove spaces and convert to uppercase)
  static String cleanAuthKey(String key) {
    return key.replaceAll(' ', '').toUpperCase();
  }

  /// Generate a sample QR data for testing
  static String generateSampleQR(String issuer, String accountName, String secret) {
    return 'otpauth://totp/$issuer:$accountName?secret=$secret&issuer=$issuer';
  }
}

/// Utility class for string operations
class StringUtils {
  // Private constructor to prevent instantiation
  StringUtils._();

  /// Capitalize first letter of each word
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Remove extra whitespace and normalize
  static String normalize(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check if string is null or empty
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Get initials from name (first letter of each word)
  static String getInitials(String name, {int maxLength = 2}) {
    if (name.trim().isEmpty) return '';
    
    final words = name.trim().split(' ');
    final initials = words
        .where((word) => word.isNotEmpty)
        .take(maxLength)
        .map((word) => word[0].toUpperCase())
        .join();
    
    return initials;
  }

  /// Generate a random string of given length
  static String generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    
    for (int i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }

  /// Mask sensitive data (show only first and last characters)
  static String maskSensitiveData(String data, {int visibleChars = 2}) {
    if (data.length <= visibleChars * 2) return data;
    
    final start = data.substring(0, visibleChars);
    final end = data.substring(data.length - visibleChars);
    final maskedLength = data.length - (visibleChars * 2);
    
    return '$start${'*' * maskedLength}$end';
  }
}

/// Utility class for date and time operations
class DateUtils {
  // Private constructor to prevent instantiation
  DateUtils._();

  /// Format date to readable string
  static String formatDate(DateTime date, {bool includeTime = false}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (includeTime) {
        return 'Today ${_formatTime(date)}';
      }
      return 'Today';
    } else if (difference.inDays == 1) {
      if (includeTime) {
        return 'Yesterday ${_formatTime(date)}';
      }
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      if (includeTime) {
        return '${difference.inDays} days ago ${_formatTime(date)}';
      }
      return '${difference.inDays} days ago';
    } else {
      if (includeTime) {
        return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
      }
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Format time to readable string
  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
}

/// Utility class for device and platform operations
class DeviceUtils {
  // Private constructor to prevent instantiation
  DeviceUtils._();

  /// Check if device is tablet based on screen size
  static bool isTablet(context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final diagonal = (screenWidth * screenWidth + screenHeight * screenHeight);
    
    // Tablet if diagonal > 7 inches (assuming 160 DPI)
    return diagonal > (7 * 160) * (7 * 160);
  }

  /// Get screen size category
  static ScreenSize getScreenSize(context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) return ScreenSize.small;
    if (width < 900) return ScreenSize.medium;
    return ScreenSize.large;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
}

/// Enum for screen sizes
enum ScreenSize { small, medium, large }
