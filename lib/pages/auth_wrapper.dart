import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pass_manager/pages/login_page.dart';
import 'package:pass_manager/pages/home_page.dart';
import 'package:pass_manager/pages/biometric_auth_page.dart';
import 'package:pass_manager/services/biometric_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F1419),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4A90E2),
              ),
            ),
          );
        }
        
        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<bool>(
            future: _shouldShowBiometricAuth(),
            builder: (context, biometricSnapshot) {
              if (biometricSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF0F1419),
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                );
              }
              
              // Show biometric auth if available and not already authenticated
              if (biometricSnapshot.data == true) {
                return const BiometricAuthPage();
              }
              
              // Go directly to home if biometric not needed
              return const HomePage();
            },
          );
        }
        
        // User is not signed in
        return const LoginPage();
      },
    );
  }

  Future<bool> _shouldShowBiometricAuth() async {
    final biometricService = BiometricService();
    
    // Check if biometric is available on device
    final isAvailable = await biometricService.isBiometricAvailable();
    if (!isAvailable) return false;
    
    // Check if user has enrolled biometrics
    final hasEnrolled = await biometricService.hasEnrolledBiometrics();
    if (!hasEnrolled) return false;
    
    // Always show biometric auth if available (for security)
    // User can choose to enable/disable it from the biometric page
    return true;
  }
}
