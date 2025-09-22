import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late MobileScannerController controller;
  String? scannedData;
  bool hasPermission = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        hasPermission = true;
      });
    } else {
      final result = await Permission.camera.request();
      setState(() {
        hasPermission = result.isGranted;
      });
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && scannedData == null) {
      setState(() {
        isProcessing = true;
        scannedData = barcodes.first.rawValue;
      });
      _extractAuthKey(barcodes.first.rawValue ?? '');
    }
  }

  void _extractAuthKey(String qrData) {
    String authKey = '';
    
    try {
      // Common QR code formats for 2FA/TOTP:
      // 1. otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example
      // 2. Plain secret key
      
      if (qrData.startsWith('otpauth://')) {
        // Parse otpauth URL
        final uri = Uri.parse(qrData);
        authKey = uri.queryParameters['secret'] ?? '';
      } else {
        // Assume it's a plain secret key
        authKey = qrData.replaceAll(RegExp(r'[^A-Z2-7]'), ''); // Clean base32 characters
      }
      
      if (authKey.isNotEmpty) {
        // Return the extracted key
        Navigator.pop(context, authKey);
      } else {
        _showErrorDialog('Invalid QR Code', 'Could not extract authentication key from the QR code.');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to process QR code: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F5F5),
          title: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to previous page
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF3E2411)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3E2411),
          title: const Text(
            'QR Code Scanner',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Camera Permission Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please grant camera permission to scan QR codes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2411),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),
                // Custom overlay for scanning frame
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF3E2411),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const SizedBox.shrink(),
                  ),
                ),
                // Corner decorations for scanning frame
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      children: [
                        // Top-left corner
                        Positioned(
                          top: -3,
                          left: -3,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF3E2411), width: 6),
                                left: BorderSide(color: Color(0xFF3E2411), width: 6),
                              ),
                            ),
                          ),
                        ),
                        // Top-right corner
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF3E2411), width: 6),
                                right: BorderSide(color: Color(0xFF3E2411), width: 6),
                              ),
                            ),
                          ),
                        ),
                        // Bottom-left corner
                        Positioned(
                          bottom: -3,
                          left: -3,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF3E2411), width: 6),
                                left: BorderSide(color: Color(0xFF3E2411), width: 6),
                              ),
                            ),
                          ),
                        ),
                        // Bottom-right corner
                        Positioned(
                          bottom: -3,
                          right: -3,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF3E2411), width: 6),
                                right: BorderSide(color: Color(0xFF3E2411), width: 6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 36,
                    color: Color(0xFF3E2411),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Position the QR code within the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isProcessing ? 'Processing...' : 'Scanning for authentication key...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
