import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/constants/app_constants.dart';
import '../core/controllers/qr_scanner_controller.dart';
import '../core/utils/ui_utils.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late QRScannerController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = QRScannerController();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    final success = await _controller.initializeScanner();
    if (success) {
      _controller.startScanning();
    } else {
      if (mounted) {
        UIUtils.showErrorSnackBar(
          context,
          _controller.error ?? AppConstants.errorGeneric,
        );
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    _controller.handleScanResult(
      context,
      capture,
      onSuccess: (authKey) {
        if (mounted) {
          Navigator.pop(context, authKey);
        }
      },
      onError: (error) {
        setState(() {
          _isProcessing = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: Text(
          AppConstants.scanQRCode,
          style: AppConstants.appBarTitleStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_controller.isReady) ...[
            IconButton(
              icon: Icon(
                _controller.flashOn ? Icons.flash_off : Icons.flash_on,
                color: Colors.white,
              ),
              onPressed: _controller.toggleFlash,
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: _controller.switchCamera,
            ),
          ],
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (!_controller.hasPermission) {
            return _buildPermissionView();
          }

          if (!_controller.isReady) {
            return _buildLoadingView();
          }

          return _buildScannerView();
        },
      ),
    );
  }

  Widget _buildPermissionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              AppConstants.cameraPermissionRequired,
              style: AppConstants.subheadingStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              AppConstants.grantCameraPermissionMessage,
              style: AppConstants.bodyStyle.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton(
              onPressed: _initializeScanner,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
              ),
              child: Text(
                'Grant Permission',
                style: AppConstants.buttonTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          ),
          SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Initializing camera...',
            style: AppConstants.bodyStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: _controller.buildScannerWidget(
            onDetect: _onDetect,
            overlay: _controller.buildScannerOverlay(),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 36,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  AppConstants.positionQRCode,
                  textAlign: TextAlign.center,
                  style: AppConstants.bodyStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  _isProcessing 
                      ? AppConstants.processing 
                      : AppConstants.scanningForAuthKey,
                  textAlign: TextAlign.center,
                  style: AppConstants.captionStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
