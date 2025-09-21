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
      
      print('User: $_currentUserId - Biometric available: $isAvailable, enrolled: $hasEnrolled, setup completed: $setupCompleted, enabled: $isEnabled');
      
      if (!isAvailable || !hasEnrolled) {
        print('Biometric not available or not enrolled, proceeding to home');
        await _biometricService.setBiometricSetupCompleted(_currentUserId!, true);
        await _biometricService.setBiometricEnabled(_currentUserId!, false);
        _proceedToHome();
        return;
      }
      
      final types = await _biometricService.getAvailableBiometrics();
      setState(() {
        _biometricType = _biometricService.getBiometricTypeString(types);
        _showEnableBiometric = !setupCompleted || !isEnabled;
      });
      
      if (setupCompleted && isEnabled) {
        // Automatically prompt for biometric if already enabled
        _authenticateWithBiometric();
      }
    } catch (e) {
      print('Error checking biometric availability: $e');
      _proceedToHome();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting biometric authentication...');
      final bool authenticated = await _biometricService.authenticateWithBiometrics();
      
      if (authenticated) {
        print('Biometric authentication successful');
        _proceedToHome();
      } else {
        print('Biometric authentication failed');
        _showBiometricError();
      }
    } catch (e) {
      print('Exception during biometric authentication: $e');
      _showBiometricError();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _enableBiometricAndAuthenticate() async {
    if (_currentUserId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('Enabling and authenticating with biometric...');
      final bool authenticated = await _biometricService.authenticateWithBiometrics();
      
      if (authenticated) {
        print('Biometric authentication successful, enabling biometric');
        await _biometricService.setBiometricEnabled(_currentUserId!, true);
        await _biometricService.setBiometricSetupCompleted(_currentUserId!, true);
        _proceedToHome();
      } else {
        print('Biometric authentication failed during enable');
        _showBiometricError();
      }
    } catch (e) {
      print('Exception during biometric enable: $e');
      _showBiometricError();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _proceedToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showBiometricError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_biometricType authentication failed'),
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
          backgroundColor: const Color(0xFFF5F5F5),
          title: const Text(
            'No Biometric Authentication Found',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Please set up fingerprint or face recognition in your device settings to use biometric authentication.',
            style: TextStyle(color: Colors.grey),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Secure Access',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                _showEnableBiometric 
                    ? 'Enable $_biometricType for quick and secure access'
                    : 'Use $_biometricType to access your vault',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Biometric Icon
              Icon(
                _biometricType == 'Face ID' 
                    ? Icons.face 
                    : Icons.fingerprint,
                color: const Color(0xFF3E2411),
                size: 80,
              ),
              
              const SizedBox(height: 60),
              
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
                          _biometricType == 'Face ID' 
                              ? Icons.face 
                              : Icons.fingerprint,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _showEnableBiometric 
                              ? 'Enable $_biometricType'
                              : 'Authenticate with $_biometricType',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Skip Button
                TextButton(
                  onPressed: _skipBiometric,
                  child: Text(
                    'Skip Biometric Authentication',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
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
                const SizedBox(height: 24),
                Text(
                  'Authenticating...',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
