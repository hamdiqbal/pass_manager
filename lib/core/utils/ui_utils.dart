import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

/// Utility class for common UI operations and helpers
class UIUtils {
  // Private constructor to prevent instantiation
  UIUtils._();

  /// Show a success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
      ),
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
      ),
    );
  }

  /// Show an info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
      ),
    );
  }

  /// Show a confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = AppConstants.confirm,
    String cancelText = AppConstants.cancel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppConstants.backgroundColor,
          title: Text(
            title,
            style: AppConstants.subheadingStyle,
          ),
          content: Text(
            content,
            style: AppConstants.bodyStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                cancelText,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                confirmText,
                style: const TextStyle(color: AppConstants.primaryColor),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
      },
    );
    return result ?? false;
  }

  /// Show a loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppConstants.backgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
              if (message != null) ...[
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  message,
                  style: AppConstants.bodyStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
      },
    );
  }

  /// Hide the loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Copy text to clipboard and show feedback
  static void copyToClipboard(BuildContext context, String text, {String? successMessage}) {
    Clipboard.setData(ClipboardData(text: text));
    showSuccessSnackBar(
      context,
      successMessage ?? 'Copied to clipboard',
    );
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return const EdgeInsets.all(AppConstants.paddingExtraLarge);
    } else {
      return const EdgeInsets.all(AppConstants.paddingLarge);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Base width (iPhone 8)
    return baseFontSize * scaleFactor.clamp(0.8, 1.2);
  }

  /// Safe navigation - prevents navigation if context is not mounted
  static void safeNavigate(BuildContext context, Widget destination) {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  /// Safe pop - prevents pop if context is not mounted
  static void safePop(BuildContext context, [dynamic result]) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }
}

/// Utility class for form validation
class ValidationUtils {
  // Private constructor to prevent instantiation
  ValidationUtils._();

  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!UIUtils.isValidEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validate authentication key (base32 format)
  static String? validateAuthKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Authentication key is required';
    }
    
    final cleanValue = value.trim().replaceAll(' ', '').toUpperCase();
    
    // Check if it's valid base32 (A-Z, 2-7)
    if (!RegExp(r'^[A-Z2-7]+$').hasMatch(cleanValue)) {
      return 'Invalid authentication key format';
    }
    
    // Typical TOTP keys are 16 or 32 characters
    if (cleanValue.length < 16) {
      return 'Authentication key is too short';
    }
    
    return null;
  }

  /// Validate field length
  static String? validateLength(
    String? value, {
    required String fieldName,
    int? minLength,
    int? maxLength,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final length = value.trim().length;

    if (minLength != null && length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (maxLength != null && length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }
}
