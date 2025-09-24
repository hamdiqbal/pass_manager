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
      await _checkBiometricAvailability();
    } else {
      // No user, go to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  Future<void> _checkBiometricAvailability() async {
    if (_currentUserId == null) return;
    
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final hasEnrolled = await _biometricService.hasEnrolledBiometrics();
      final setupCompleted = await _biometricService.isBiometricSetupCompleted(_currentUserId!);
      final isEnabled = await _biometricService.isBiometricEnabled(_currentUserId!);
      
      if (!isAvailable || !hasEnrolled) {
        // No biometric available, skip to home
        _proceedToHome();
        return;
      }

      // Get biometric type for display
      final biometrics = await _biometricService.getAvailableBiometrics();
      if (biometrics.isNotEmpty) {
        _biometricType = biometrics.first.toString().split('.').last;
      }

      if (mounted) {
        setState(() {
          _showEnableBiometric = !isEnabled && !setupCompleted;
        });
      }

      // If already enabled, authenticate immediately
      if (isEnabled) {
        await _authenticateWithBiometric();
      }
    } catch (e) {
      print('Error checking biometric availability: $e');
      // On error, proceed to home
      _proceedToHome();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_currentUserId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final isAuthenticated = await _biometricService.authenticateWithBiometrics();

      if (isAuthenticated) {
        _proceedToHome();
      } else {
        _showBiometricError();
      }
    } catch (e) {
      print('Authentication error: $e');
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
      final isAuthenticated = await _biometricService.authenticateWithBiometrics();

      if (isAuthenticated) {
        // Enable biometric and mark setup as completed
        await _biometricService.setBiometricEnabled(_currentUserId!, true);
        await _biometricService.setBiometricSetupCompleted(_currentUserId!, true);
        
        _proceedToHome();
      } else {
        _showBiometricError();
      }
    } catch (e) {
      print('Enable biometric error: $e');
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
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showBiometricError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Authentication failed. Please try again.'),
          backgroundColor: Colors.red[600],
          action: SnackBarAction(
            label: 'Try Again',
            textColor: Colors.white,
            onPressed: _authenticateWithBiometric,
          ),
        ),
      );
    }
  }

  Future<void> _skipBiometricSetup() async {
    if (_currentUserId == null) return;

    await _biometricService.setBiometricEnabled(_currentUserId!, false);
    await _biometricService.setBiometricSetupCompleted(_currentUserId!, true);
    _proceedToHome();
  }

  String _getBiometricIcon() {
    switch (_biometricType.toLowerCase()) {
      case 'face':
      case 'faceid':
        return '👤';
      case 'fingerprint':
      case 'touchid':
        return '👆';
      case 'iris':
        return '👁️';
      default:
        return '🔐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // App Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.security,
                  color: Color(0xFF4CAF50),
                  size: 50,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // App Title
              const Text(
                'Three Ace Pass Manager',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              const Text(
                'Secure Password Management',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Biometric Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4CAF50),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getBiometricIcon(),
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Instructions
              Text(
                _showEnableBiometric
                    ? 'Enable $_biometricType for quick and secure access'
                    : 'Use $_biometricType to access your vault',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Your passwords are protected with biometric authentication',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Action Buttons
              Column(
                children: [
                  if (!_isLoading) ...[
                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _showEnableBiometric
                            ? _enableBiometricAndAuthenticate
                            : _authenticateWithBiometric,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getBiometricIcon(),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _showEnableBiometric
                                  ? 'Enable $_biometricType'
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
                    
                    const SizedBox(height: 16),
                    
                    // Skip Button (only show during setup)
                    if (_showEnableBiometric)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: TextButton(
                          onPressed: _skipBiometricSetup,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ] else ...[
                    // Loading State
                    const SizedBox(
                      height: 52,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
