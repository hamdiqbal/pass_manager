import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pass_manager/pages/login_page.dart';
import 'package:pass_manager/pages/home_page.dart';
import 'package:pass_manager/pages/biometric_auth_page.dart';
import 'package:pass_manager/services/biometric_service.dart';
import 'package:pass_manager/services/user_session_service.dart';

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
          final user = snapshot.data!;
          return FutureBuilder<bool>(
            future: _shouldShowBiometricAuth(user.uid),
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
              
              // Show biometric auth if needed for this user
              if (biometricSnapshot.data == true) {
                return const BiometricAuthPage();
              }
              
              // Go directly to home if biometric not needed
              return const HomePage();
            },
          );
        }
        
        // User is not signed in - show stored user if available
        return FutureBuilder<bool>(
          future: _hasStoredUser(),
          builder: (context, storedUserSnapshot) {
            if (storedUserSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF0F1419),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4A90E2),
                  ),
                ),
              );
            }
            
            // Always show login page when not authenticated
            return const LoginPage();
          },
        );
      },
    );
  }

  Future<bool> _shouldShowBiometricAuth(String userId) async {
    final biometricService = BiometricService();
    
    // Check if biometric is available on device
    final isAvailable = await biometricService.isBiometricAvailable();
    if (!isAvailable) return false;
    
    // Check if user has enrolled biometrics
    final hasEnrolled = await biometricService.hasEnrolledBiometrics();
    if (!hasEnrolled) return false;
    
    // Check if this user has completed biometric setup
    final setupCompleted = await biometricService.isBiometricSetupCompleted(userId);
    
    // If setup not completed, show biometric page to let user choose
    // If setup completed and enabled, show biometric auth
    // If setup completed but disabled, go directly to home
    if (!setupCompleted) {
      return true; // Show biometric setup page
    }
    
    // Check if biometric is enabled for this user
    final isEnabled = await biometricService.isBiometricEnabled(userId);
    return isEnabled;
  }

  Future<bool> _hasStoredUser() async {
    final sessionService = UserSessionService();
    return await sessionService.hasStoredUser();
  }
}
