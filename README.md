# 🔐 Three Ace Pass Manager

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

**A secure, feature-rich password manager built with Flutter**

*Safeguard your digital life with biometric authentication and encrypted storage*

</div>

## 🌟 Features

### 🔒 **Security First**
- **Biometric Authentication** - Fingerprint, Face ID, or device PIN/Pattern
- **Firebase Authentication** - Secure user account management
- **Encrypted Storage** - Your passwords are safely encrypted
- **Auto-logout** - Session management for enhanced security

### 📱 **User Experience**
- **Intuitive UI** - Clean, modern interface with dark theme
- **Hierarchical Organization** - Master Branches → Subcategories → Accounts
- **Custom Fields** - Add any additional information to accounts
- **QR Code Scanner** - Quick setup for 2FA and account details
- **Search & Filter** - Find your accounts instantly

### ⚡ **Smart Features**
- **Password Generator** - Create strong, unique passwords
- **Secure Sharing** - QR codes for safe password sharing
- **Backup & Sync** - Cloud synchronization via Firebase
- **Cross-Platform** - Available on Android and iOS

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1+)
- Dart SDK
- Android Studio / Xcode
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/hamdiqbal/pass_manager.git
   cd pass_manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add your Android/iOS apps to the project
   - Download and place configuration files:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)

4. **Run the application**
   ```bash
   flutter run
   ```

### 🏗️ Build Release APK

Use the included optimized build script:

```bash
./build_release.sh
```

This will create: `ThreeAcePassManager-v1.0.0+1-release.apk`

**Build Features:**
- Code obfuscation for security
- Tree-shaking for smaller size
- Debug symbols separation
- Optimized performance

## 📱 App Structure

```
Three Ace Pass Manager
├── 🏠 Home Dashboard
│   ├── 📁 Master Branches (Categories)
│   │   ├── 📂 Subcategories  
│   │   │   └── 🔐 Individual Accounts
│   │   └── ➕ Add New Items
│   └── ⚙️ Settings & Profile
├── 🔐 Biometric Authentication
├── 👤 Login/Signup System  
└── 📱 QR Scanner Integration
```

## 🛠️ Technology Stack

| Component | Technology |
|-----------|------------|
| **Framework** | Flutter 3.8.1+ |
| **Language** | Dart |
| **Backend** | Firebase (Auth, Firestore) |
| **Authentication** | Firebase Auth + Local Biometrics |
| **Database** | Cloud Firestore |
| **Local Storage** | SharedPreferences |
| **Biometrics** | local_auth package |
| **QR Scanner** | mobile_scanner package |

## 🔧 Configuration

### Android Permissions
The app requires these permissions (already configured):
- `USE_BIOMETRIC` / `USE_FINGERPRINT` - Biometric authentication
- `CAMERA` - QR code scanning

### iOS Capabilities
- Face ID / Touch ID usage description
- Camera usage for QR scanning

## 📦 Key Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0  
  cloud_firestore: ^5.6.12
  local_auth: ^2.3.0
  mobile_scanner: ^5.2.3
  shared_preferences: ^2.4.12
  # ... and more
```

## 🎯 App Versions

- **Current Version**: v1.0.0+1
- **Minimum Android SDK**: 23 (Android 6.0)
- **Target Android SDK**: Latest
- **iOS Deployment Target**: 12.0+

## 🔐 Security Features

- ✅ Biometric authentication required
- ✅ Secure Firebase authentication
- ✅ Encrypted cloud storage
- ✅ Code obfuscation in release builds
- ✅ No sensitive data in logs
- ✅ Auto-logout on app backgrounding

## 📸 Screenshots

*Coming Soon - App screenshots will be added*

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

**Hamd Iqbal** - [@hamdiqbal](https://github.com/hamdiqbal)

---

## 🚀 Quick Start Commands

```bash
# Development
flutter run

# Release Build
./build_release.sh

# Clean Build
flutter clean && flutter pub get

# Analyze Code
flutter analyze

# Run Tests
flutter test
```

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

*Built with ❤️ using Flutter*

</div>
