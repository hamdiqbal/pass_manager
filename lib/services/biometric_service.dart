import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      print('Biometric check - canCheckBiometrics: $isAvailable, isDeviceSupported: $isDeviceSupported');
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
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

  // Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      // First check if device supports biometrics
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        print('Device does not support biometric authentication');
        return false;
      }

      // Check if biometrics can be checked
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        print('Cannot check biometrics on this device');
        return false;
      }

      // Get available biometrics
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        print('No biometrics enrolled on device');
        return false;
      }

      print('Available biometrics: $availableBiometrics');

      // Attempt authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your password vault',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
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

  // Get biometric type string for display
  String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }

  // Check if device supports any biometric authentication
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
