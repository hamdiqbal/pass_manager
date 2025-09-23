import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pass_manager/services/biometric_service.dart';
import 'package:pass_manager/services/auth_service.dart';

class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({super.key});

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  final BiometricService _biometricService = BiometricService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _showEnableBiometric = false;
  String _biometricType = 'Biometric';
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _checkBiometricAvailability();
    } else {
      // No user, shouldn't happen but go to login
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _checkBiometricAvailability() async {
    if (_currentUserId == null) return;
    
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final hasEnrolled = await _biometricService.hasEnrolledBiometrics();
      final setupCompleted = await _biometricService.isBiometricSetupCompleted(_currentUserId!);
      final isEnabled = await _biometricService.isBiometricEnabled(_currentUserId!);
      
      print('User: $_currentUserId - Authentication available: $isAvailable, enrolled: $hasEnrolled, setup completed: $setupCompleted, enabled: $isEnabled');
      
      if (!isAvailable || !hasEnrolled) {
        print('Device authentication not available or not enrolled, proceeding to home');
        await _biometricService.setBiometricSetupCompleted(_currentUserId!, true);
        await _biometricService.setBiometricEnabled(_currentUserId!, false);
        _proceedToHome();
        return;
      }
      
      // Get authentication description for better user experience
      final authDescription = await _biometricService.getAuthenticationDescription();
      final types = await _biometricService.getAvailableBiometrics();
      
      setState(() {
        _biometricType = _biometricService.getBiometricTypeString(types);
        _showEnableBiometric = !setupCompleted || !isEnabled;
      });
      
      if (setupCompleted && isEnabled) {
        // Automatically prompt for authentication if already enabled
        _authenticateWithBiometric();
      }
    } catch (e) {
      print('Error checking authentication availability: $e');
      _proceedToHome();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting device authentication...');
      final bool authenticated = await _biometricService.authenticateWithBiometrics();
      
      if (authenticated) {
        print('Device authentication successful');
        _proceedToHome();
      } else {
        print('Device authentication failed or cancelled - retrying...');
        // Don't show error, immediately retry authentication
        setState(() {
          _isLoading = false;
        });
        // Small delay to prevent immediate retry
        await Future.delayed(const Duration(milliseconds: 500));
        _authenticateWithBiometric();
        return;
      }
    } catch (e) {
      print('Exception during device authentication: $e');
      // Don't show error, immediately retry authentication
      setState(() {
        _isLoading = false;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      _authenticateWithBiometric();
      return;
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enableBiometricAndAuthenticate() async {
    if (_currentUserId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('Enabling and authenticating with device security...');
      final bool authenticated = await _biometricService.authenticateWithBiometrics();
      
      if (authenticated) {
        print('Device authentication successful, enabling authentication');
        await _biometricService.setBiometricEnabled(_currentUserId!, true);
        await _biometricService.setBiometricSetupCompleted(_currentUserId!, true);
        _proceedToHome();
      } else {
        print('Device authentication failed or cancelled during enable - retrying...');
        // Don't show error, immediately retry authentication
        setState(() {
          _isLoading = false;
        });
        await Future.delayed(const Duration(milliseconds: 500));
        _enableBiometricAndAuthenticate();
        return;
      }
    } catch (e) {
      print('Exception during device authentication enable: $e');
      // Don't show error, immediately retry authentication
      setState(() {
        _isLoading = false;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      _enableBiometricAndAuthenticate();
      return;
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _proceedToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showBiometricError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Authentication failed. Please try again.'),
        backgroundColor: Colors.red[600],
        action: SnackBarAction(
          label: 'Try Again',
          textColor: Colors.white,
          onPressed: _authenticateWithBiometric,
        ),
      ),
    );
  }

  void _showNoBiometricDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'No Device Security Found',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'Please set up a screen lock (fingerprint, face recognition, pattern, PIN, or password) in your device settings to secure the app.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedToHome();
              },
              child: const Text(
                'Continue',
                style: TextStyle(color: Color(0xFF3E2411)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  void _skipBiometric() async {
    if (_currentUserId == null) return;
    
    await _biometricService.setBiometricEnabled(_currentUserId!, false);
    await _biometricService.setBiometricSetupCompleted(_currentUserId!, true);
    _proceedToHome();
  }

  IconData _getAuthenticationIcon() {
    switch (_biometricType) {
      case 'Face ID':
        return Icons.face;
      case 'Fingerprint':
        return Icons.fingerprint;
      case 'Device Security':
        return Icons.lock;
      default:
        return Icons.security;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Security Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E2411),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3E2411).withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Secure Access',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                _showEnableBiometric 
                    ? 'Enable ${_biometricType == 'Device Security' ? 'device security' : _biometricType} for quick and secure access'
                    : 'Use ${_biometricType == 'Device Security' ? 'your device security' : _biometricType} to access your vault',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Authentication Icon - choose appropriate icon based on type
              Icon(
                _getAuthenticationIcon(),
                color: const Color(0xFF3E2411),
                size: 80,
              ),
              
              const SizedBox(height: 48),
              
              // Main Action Button
              if (!_isLoading) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _showEnableBiometric 
                        ? _enableBiometricAndAuthenticate 
                        : _authenticateWithBiometric,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E2411),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getAuthenticationIcon(),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _showEnableBiometric 
                              ? 'Enable ${_biometricType == 'Device Security' ? 'Device Security' : _biometricType}'
                              : 'Authenticate',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Skip Button
                TextButton(
                  onPressed: _skipBiometric,
                  child: const Text(
                    'Skip Authentication',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Sign Out Button
                TextButton(
                  onPressed: _signOut,
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Color(0xFF3E2411),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                // Loading Indicator
                const CircularProgressIndicator(
                  color: Color(0xFF3E2411),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Authenticating...',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ), // Close Column
        ), // Close ConstrainedBox
      ), // Close SingleChildScrollView  
    ), // Close SafeArea
    ), // Close Scaffold
    ); // Close PopScope
  }
}
