import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/account.dart';
import '../utils/ui_utils.dart';
import '../utils/app_utils.dart';

/// Controller for managing account operations
class AccountController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _error;
  List<Account> _accounts = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Account> get accounts => List.unmodifiable(_accounts);

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
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

  /// Add or update an account
  Future<bool> saveAccount({
    required String subcategoryId,
    required String name,
    required String username,
    required String password,
    String? authKey,
    String? notes,
    String? accountId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Validate required fields
      if (StringUtils.isNullOrEmpty(name)) {
        throw Exception('Account name is required');
      }
      if (StringUtils.isNullOrEmpty(username)) {
        throw Exception('Username is required');
      }
      if (StringUtils.isNullOrEmpty(password)) {
        throw Exception('Password is required');
      }

      // Validate auth key if provided
      if (authKey != null && authKey.isNotEmpty) {
        final cleanKey = QRUtils.cleanAuthKey(authKey);
        final validationError = ValidationUtils.validateAuthKey(cleanKey);
        if (validationError != null) {
          throw Exception(validationError);
        }
      }

      final accountData = {
        'name': StringUtils.normalize(name),
        'username': StringUtils.normalize(username),
        'password': password,
        'authKey': authKey != null ? QRUtils.cleanAuthKey(authKey) : null,
        'notes': notes?.trim(),
        'lastModified': FieldValue.serverTimestamp(),
      };

      if (accountId != null) {
        // Update existing account
        await _firestore
            .collection('subcategories')
            .doc(subcategoryId)
            .collection('accounts')
            .doc(accountId)
            .update(accountData);
      } else {
        // Create new account
        accountData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore
            .collection('subcategories')
            .doc(subcategoryId)
            .collection('accounts')
            .add(accountData);
      }

      await loadAccounts(subcategoryId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load accounts for a subcategory
  Future<void> loadAccounts(String subcategoryId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('subcategories')
          .doc(subcategoryId)
          .collection('accounts')
          .orderBy('name')
          .get();

      _accounts = querySnapshot.docs.map((doc) {
        return Account.fromFirestore(doc);
      }).toList();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an account
  Future<bool> deleteAccount(String subcategoryId, String accountId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore
          .collection('subcategories')
          .doc(subcategoryId)
          .collection('accounts')
          .doc(accountId)
          .delete();

      // Remove from local list
      _accounts.removeWhere((account) => account.id == accountId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get account by ID
  Account? getAccountById(String accountId) {
    try {
      return _accounts.firstWhere((account) => account.id == accountId);
    } catch (e) {
      return null;
    }
  }

  /// Search accounts by name
  List<Account> searchAccounts(String query) {
    if (StringUtils.isNullOrEmpty(query)) return _accounts;

    final lowercaseQuery = query.toLowerCase();
    return _accounts.where((account) {
      return account.name.toLowerCase().contains(lowercaseQuery) ||
             account.username.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Validate account data before saving
  Map<String, String?> validateAccountData({
    required String name,
    required String username,
    required String password,
    String? authKey,
  }) {
    final errors = <String, String?>{};

    errors['name'] = ValidationUtils.validateRequired(name, fieldName: 'Account name');
    errors['username'] = ValidationUtils.validateRequired(username, fieldName: 'Username');
    errors['password'] = ValidationUtils.validateRequired(password, fieldName: 'Password');

    if (authKey != null && authKey.isNotEmpty) {
      errors['authKey'] = ValidationUtils.validateAuthKey(authKey);
    }

    // Remove null entries
    errors.removeWhere((key, value) => value == null);

    return errors;
  }

  /// Process QR code data for authentication key
  String? processQRData(String qrData) {
    try {
      final authKey = QRUtils.extractAuthKeyFromQR(qrData);
      if (authKey != null) {
        return QRUtils.formatAuthKey(authKey);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Copy account data to clipboard
  void copyAccountData(BuildContext context, Account account, String dataType) {
    String textToCopy = '';
    String successMessage = '';

    switch (dataType.toLowerCase()) {
      case 'username':
        textToCopy = account.username;
        successMessage = 'Username copied to clipboard';
        break;
      case 'password':
        textToCopy = account.password;
        successMessage = 'Password copied to clipboard';
        break;
      case 'authkey':
        if (account.authKey != null) {
          textToCopy = account.authKey!;
          successMessage = 'Authentication key copied to clipboard';
        } else {
          UIUtils.showErrorSnackBar(context, 'No authentication key available');
          return;
        }
        break;
      default:
        UIUtils.showErrorSnackBar(context, 'Invalid data type');
        return;
    }

    UIUtils.copyToClipboard(context, textToCopy, successMessage: successMessage);
  }
}
