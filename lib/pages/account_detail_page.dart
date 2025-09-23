import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account.dart';
import '../models/subcategory.dart';
import '../models/master_branch.dart';
import '../models/custom_field.dart';
import '../services/firebase_service.dart';
import '../services/biometric_service.dart';
import 'add_account_page.dart';

class AccountDetailPage extends StatefulWidget {
  final Account account;
  final Subcategory subcategory;
  final MasterBranch masterBranch;

  const AccountDetailPage({
    super.key,
    required this.account,
    required this.subcategory,
    required this.masterBranch,
  });

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final BiometricService _biometricService = BiometricService();
  bool _isPasswordVisible = false;
  bool _isAuthKeyVisible = false;
  late Account currentAccount;
  Map<String, bool> hiddenFieldVisibility = {}; // Track visibility of hidden fields

  @override
  void initState() {
    super.initState();
    currentAccount = widget.account;
    
    // Initialize hidden field visibility
    for (var field in currentAccount.customFields) {
      if (field.type == 'hidden') {
        hiddenFieldVisibility[field.id] = false; // Hidden by default
      }
    }
  }

  Future<bool> _authenticateForSensitiveData() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        return true; // If biometric not available, allow access
      }
      
      return await _biometricService.authenticateWithBiometrics();
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2411),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with edit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E2411).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_circle,
                                color: Color(0xFF3E2411),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentAccount.name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Created: ${_formatDate(currentAccount.createdAt)}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account Information
            const Text(
              'Account Information',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Username
            _buildInfoCard(
              'Username',
              currentAccount.username,
              Icons.person,
              copyable: true,
            ),
            
            const SizedBox(height: 12),
            
            // Password
            _buildInfoCard(
              'Password',
              _isPasswordVisible ? currentAccount.password : '•' * currentAccount.password.length,
              Icons.lock,
              copyable: true,
              hasVisibilityToggle: true,
              isVisible: _isPasswordVisible,
              onVisibilityToggle: () async {
                if (!_isPasswordVisible) {
                  // Authenticate before showing password
                  final authenticated = await _authenticateForSensitiveData();
                  if (!authenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Authentication required to view password'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // URL
            if (currentAccount.url.isNotEmpty)
              _buildInfoCard(
                'Website URL',
                currentAccount.url,
                Icons.link,
                copyable: true,
              ),
            
            if (currentAccount.url.isNotEmpty) const SizedBox(height: 12),
            
            // Authentication Key
            if (currentAccount.authenticationKey.isNotEmpty)
              _buildInfoCard(
                'Authentication Key',
                _isAuthKeyVisible ? currentAccount.authenticationKey : '•' * currentAccount.authenticationKey.length,
                Icons.key,
                copyable: true,
                hasVisibilityToggle: true,
                isVisible: _isAuthKeyVisible,
                onVisibilityToggle: () {
                  setState(() {
                    _isAuthKeyVisible = !_isAuthKeyVisible;
                  });
                },
              ),
            
            if (currentAccount.authenticationKey.isNotEmpty) const SizedBox(height: 12),
            
            // Description
            if (currentAccount.description.isNotEmpty)
              _buildInfoCard(
                'Description',
                currentAccount.description,
                Icons.description,
                copyable: true,
                isMultiline: true,
              ),
            
            if (currentAccount.description.isNotEmpty) const SizedBox(height: 12),
            
            // Custom Fields
            if (currentAccount.customFields.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Custom Fields',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ...currentAccount.customFields.map((field) => _buildCustomFieldDisplay(field)),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon, {
    bool copyable = false,
    bool hasVisibilityToggle = false,
    bool isVisible = true,
    VoidCallback? onVisibilityToggle,
    bool isMultiline = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF3E2411),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (hasVisibilityToggle)
                IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: onVisibilityToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (copyable && value.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () => _copyToClipboard(value, label),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            value.isNotEmpty ? value : 'Not provided',
            style: TextStyle(
              color: value.isNotEmpty ? Colors.black : Colors.grey[500],
              fontSize: 16,
              height: isMultiline ? 1.5 : 1.2,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: const Color(0xFF3E2411),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleAccountDeletion() async {
    try {
      print('🔸 Account deletion requested from edit page');
      // Delete the account from Firebase
      print('🔸 Attempting to delete account from Firebase...');
      await _firebaseService.deleteAccountFromSubcategory(
        widget.masterBranch.id,
        widget.subcategory.id,
        currentAccount.id,
      );
      print('🔸 Account successfully deleted from Firebase');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to subcategory detail page with deletion result
        print('🔸 Navigating back with deletion result (true)...');
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    } catch (e) {
      print('🔸 Error deleting account: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  void _deleteAccount() async {
    print('🔸 Delete account called');
    final confirmed = await _showDeleteConfirmation();
    print('🔸 Deletion confirmed: $confirmed');
    if (confirmed) {
      try {
        print('🔸 Attempting to delete account from Firebase...');
        await _firebaseService.deleteAccountFromSubcategory(
          widget.masterBranch.id,
          widget.subcategory.id,
          currentAccount.id,
        );
        
        print('🔸 Account successfully deleted from Firebase');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          print('🔸 Navigating back with deletion result...');
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      } catch (e) {
        print('🔸 Error deleting account: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.black),
        ),
        content: Text(
          'Are you sure you want to delete "${currentAccount.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildCustomFieldDisplay(CustomField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                field.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getFieldTypeColor(field.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  field.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFieldValueDisplay(field),
        ],
      ),
    );
  }

  Widget _buildFieldValueDisplay(CustomField field) {
    switch (field.type) {
      case 'boolean':
        return Row(
          children: [
            Icon(
              field.value == true ? Icons.check_circle : Icons.cancel,
              color: field.value == true ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              field.value == true ? 'True' : 'False',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        );
      
      case 'hidden':
        final isVisible = hiddenFieldVisibility[field.id] ?? false;
        return Row(
          children: [
            Expanded(
              child: Text(
                isVisible ? (field.value?.toString() ?? '') : '••••••••',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF3E2411),
              ),
              onPressed: () async {
                if (!isVisible) {
                  // Authenticate before showing hidden field
                  final authenticated = await _authenticateForSensitiveData();
                  if (!authenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Authentication required to view hidden field'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }
                setState(() {
                  hiddenFieldVisibility[field.id] = !isVisible;
                });
              },
            ),
            if (field.value?.toString().isNotEmpty == true)
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  color: Color(0xFF3E2411),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: field.value.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${field.name} copied to clipboard'),
                      backgroundColor: const Color(0xFF3E2411),
                    ),
                  );
                },
              ),
          ],
        );
      
      case 'linked':
        return GestureDetector(
          onTap: () {
            // You can add URL launching functionality here
            _copyToClipboard(field.value?.toString() ?? '', field.name);
          },
          child: Text(
            field.value?.toString() ?? 'No link provided',
            style: TextStyle(
              fontSize: 16,
              color: field.value?.toString().isNotEmpty == true 
                  ? const Color(0xFF3E2411) 
                  : Colors.grey[500],
              decoration: field.value?.toString().isNotEmpty == true 
                  ? TextDecoration.underline 
                  : null,
            ),
          ),
        );
      
      default: // text
        return SelectableText(
          field.value?.toString() ?? 'No value provided',
          style: TextStyle(
            fontSize: 16,
            color: field.value?.toString().isNotEmpty == true 
                ? Colors.black 
                : Colors.grey[500],
          ),
        );
    }
  }

  Color _getFieldTypeColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'boolean':
        return Colors.green;
      case 'hidden':
        return Colors.orange;
      case 'linked':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
