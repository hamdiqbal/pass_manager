import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import '../utils/ui_utils.dart';
import '../utils/app_utils.dart';

/// Controller for QR code scanning operations
class QRScannerController extends ChangeNotifier {
  MobileScannerController? _scannerController;
  bool _isScanning = false;
  bool _hasPermission = false;
  String? _error;
  bool _flashOn = false;
  CameraFacing _cameraFacing = CameraFacing.back;

  // Getters
  MobileScannerController? get scannerController => _scannerController;
  bool get isScanning => _isScanning;
  bool get hasPermission => _hasPermission;
  String? get error => _error;
  bool get flashOn => _flashOn;
  CameraFacing get cameraFacing => _cameraFacing;

  /// Initialize scanner
  Future<bool> initializeScanner() async {
    try {
      _setError(null);
      
      // Request camera permission
      final permissionStatus = await _requestCameraPermission();
      if (!permissionStatus) {
        _setError('Camera permission is required to scan QR codes');
        return false;
      }

      _hasPermission = true;
      
      // Initialize scanner controller
      _scannerController = MobileScannerController(
        facing: _cameraFacing,
        torchEnabled: _flashOn,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to initialize scanner: ${e.toString()}');
      return false;
    }
  }

  /// Request camera permission
  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status == PermissionStatus.granted) {
        return true;
      }

      if (status == PermissionStatus.denied) {
        final requestResult = await Permission.camera.request();
        return requestResult == PermissionStatus.granted;
      }

      if (status == PermissionStatus.permanentlyDenied) {
        // Open app settings for user to manually grant permission
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Start scanning
  void startScanning() {
    if (_scannerController != null && !_isScanning) {
      _isScanning = true;
      _scannerController!.start();
      notifyListeners();
    }
  }

  /// Stop scanning
  void stopScanning() {
    if (_scannerController != null && _isScanning) {
      _isScanning = false;
      _scannerController!.stop();
      notifyListeners();
    }
  }

  /// Toggle flash
  Future<void> toggleFlash() async {
    if (_scannerController != null) {
      try {
        _flashOn = !_flashOn;
        await _scannerController!.toggleTorch();
        notifyListeners();
      } catch (e) {
        _setError('Failed to toggle flash: ${e.toString()}');
      }
    }
  }

  /// Switch camera
  Future<void> switchCamera() async {
    if (_scannerController != null) {
      try {
        _cameraFacing = _cameraFacing == CameraFacing.back 
            ? CameraFacing.front 
            : CameraFacing.back;
        
        await _scannerController!.switchCamera();
        notifyListeners();
      } catch (e) {
        _setError('Failed to switch camera: ${e.toString()}');
      }
    }
  }

  /// Process scanned data
  String? processScannedData(String rawData) {
    try {
      // Extract authentication key from QR data
      final authKey = QRUtils.extractAuthKeyFromQR(rawData);
      
      if (authKey != null) {
        // Format the key for display
        return QRUtils.formatAuthKey(authKey);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Validate scanned data
  bool isValidScanData(String data) {
    return QRUtils.isValidAuthQR(data);
  }

  /// Handle scan result
  void handleScanResult(
    BuildContext context,
    BarcodeCapture capture, {
    required Function(String) onSuccess,
    Function(String)? onError,
  }) {
    final barcodes = capture.barcodes;
    
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;

    if (rawValue == null || rawValue.isEmpty) {
      final errorMessage = 'No data found in QR code';
      onError?.call(errorMessage);
      UIUtils.showErrorSnackBar(context, errorMessage);
      return;
    }

    // Process the scanned data
    final processedData = processScannedData(rawValue);
    
    if (processedData != null) {
      // Valid authentication key found
      stopScanning();
      onSuccess(processedData);
      UIUtils.showSuccessSnackBar(context, 'Authentication key scanned successfully');
    } else {
      // Invalid or unrecognized format
      final errorMessage = 'Invalid QR code format. Please scan a valid authentication QR code.';
      onError?.call(errorMessage);
      UIUtils.showErrorSnackBar(context, errorMessage);
    }
  }

  /// Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _setError(null);
  }

  /// Check if scanner is ready
  bool get isReady => _scannerController != null && _hasPermission;

  /// Get scanner widget
  Widget buildScannerWidget({
    required Function(BarcodeCapture) onDetect,
    Widget? overlay,
  }) {
    if (!isReady) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: onDetect,
        ),
        if (overlay != null) overlay,
      ],
    );
  }

  /// Build scanner overlay with corner indicators
  Widget buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
      ),
      child: Stack(
        children: [
          // Center scanning area
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Corner indicators
                  ...List.generate(4, (index) {
                    return Positioned(
                      top: index < 2 ? 0 : null,
                      bottom: index >= 2 ? 0 : null,
                      left: index % 2 == 0 ? 0 : null,
                      right: index % 2 == 1 ? 0 : null,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            top: index < 2
                                ? const BorderSide(color: AppConstants.primaryColor, width: 4)
                                : BorderSide.none,
                            bottom: index >= 2
                                ? const BorderSide(color: AppConstants.primaryColor, width: 4)
                                : BorderSide.none,
                            left: index % 2 == 0
                                ? const BorderSide(color: AppConstants.primaryColor, width: 4)
                                : BorderSide.none,
                            right: index % 2 == 1
                                ? const BorderSide(color: AppConstants.primaryColor, width: 4)
                                : BorderSide.none,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium,
              ),
              child: Text(
                'Position the QR code within the frame to scan',
                style: AppConstants.bodyStyle.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dispose resources
  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }
}
