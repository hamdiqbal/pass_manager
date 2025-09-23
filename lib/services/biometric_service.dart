import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling device authentication including:
/// - Biometric authentication (fingerprint, face recognition, iris)
/// - Device passcode/PIN
/// - Pattern lock
/// - Password authentication
/// 
/// This service automatically detects and uses whatever authentication
/// method the user has set up on their device.
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if any device authentication is available (biometric, pattern, PIN, password)
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      print('Authentication check - canCheckBiometrics: $isAvailable, isDeviceSupported: $isDeviceSupported');
      
      // Return true if device supports any form of authentication
      return isDeviceSupported;
    } catch (e) {
      print('Error checking authentication availability: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate using device security (biometrics, pattern, PIN, password)
  Future<bool> authenticateWithBiometrics() async {
    try {
      // First check if device supports authentication
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        print('Device does not support authentication');
        return false;
      }

      // Check if any authentication method is available
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      
      // Get available biometrics to determine what's enrolled
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      String authReason = 'Authenticate to access your password vault';
      String authMethodDescription = '';
      
      // Determine what authentication methods are available and create appropriate message
      if (availableBiometrics.isNotEmpty) {
        // Device has biometric authentication enrolled
        if (availableBiometrics.contains(BiometricType.face)) {
          authMethodDescription = 'Use Face ID or your device passcode to authenticate';
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          authMethodDescription = 'Use fingerprint or your device passcode to authenticate';
        } else if (availableBiometrics.contains(BiometricType.iris)) {
          authMethodDescription = 'Use iris scan or your device passcode to authenticate';
        } else {
          authMethodDescription = 'Use biometric authentication or your device passcode';
        }
      } else if (canCheckBiometrics) {
        // Device supports authentication but no biometrics enrolled
        authMethodDescription = 'Use your device passcode, pattern, or PIN to authenticate';
      } else {
        print('No authentication methods available on this device');
        return false;
      }

      print('Available biometrics: $availableBiometrics');
      print('Auth method description: $authMethodDescription');

      // Attempt authentication with all available methods
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: authMethodDescription.isNotEmpty ? authMethodDescription : authReason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow fallback to PIN/pattern/password
          stickyAuth: true,     // Keep the authentication dialog persistent
          useErrorDialogs: false, // Don't show system error dialogs
        ),
      );

      print('Authentication result: $didAuthenticate');
      return didAuthenticate;

    } on PlatformException catch (e) {
      print('PlatformException during authentication: ${e.code} - ${e.message}');
      
      // Handle specific error codes
      switch (e.code) {
        case 'NotAvailable':
        case 'not_available':
          print('Biometric authentication not available');
          break;
        case 'NotEnrolled':
        case 'not_enrolled':
          print('No biometric credentials enrolled');
          break;
        case 'LockedOut':
        case 'locked_out':
          print('Biometric authentication locked out');
          break;
        case 'PermanentlyLockedOut':
        case 'permanently_locked_out':
          print('Biometric authentication permanently locked out');
          break;
        default:
          print('Unknown biometric error: ${e.code}');
      }
      return false;
    } catch (e) {
      print('Unexpected error during biometric authentication: $e');
      return false;
    }
  }

  // Check if user has enabled biometric authentication for the app
  Future<bool> isBiometricEnabled(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled_$userId') ?? false;
  }

  // Enable/disable biometric authentication for specific user
  Future<void> setBiometricEnabled(String userId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled_$userId', enabled);
  }

  // Check if biometric has been set up for a specific user
  Future<bool> isBiometricSetupCompleted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_setup_completed_$userId') ?? false;
  }

  // Mark biometric setup as completed for a user
  Future<void> setBiometricSetupCompleted(String userId, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_setup_completed_$userId', completed);
  }

  // Get authentication type string for display
  String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.isNotEmpty) {
      return 'Biometric';
    } else {
      return 'Device Security'; // Covers pattern, PIN, password
    }
  }

  // Get detailed authentication description for user
  Future<String> getAuthenticationDescription() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID or device passcode';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint or device passcode';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris scan or device passcode';
      } else if (availableBiometrics.isNotEmpty) {
        return 'Biometric authentication or device passcode';
      } else if (canCheckBiometrics) {
        return 'Device passcode, pattern, or PIN';
      } else {
        return 'Device authentication';
      }
    } catch (e) {
      return 'Device authentication';
    }
  }

  // Check if device has any authentication method enrolled (biometric, pattern, PIN, password)
  Future<bool> hasEnrolledBiometrics() async {
    try {
      // Check if device supports authentication
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        return false;
      }

      // Check if authentication is available (includes device passcode/pattern)
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      
      // Get biometric-specific enrollments
      final availableBiometrics = await getAvailableBiometrics();
      
      // Return true if either biometrics are enrolled OR device passcode is set
      // canCheckBiometrics will be true if device has any form of authentication
      return canCheckBiometrics || availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Error checking enrolled authentication methods: $e');
      return false;
    }
  }
}
