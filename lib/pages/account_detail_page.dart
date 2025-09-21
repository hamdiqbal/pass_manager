import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account.dart';
import '../models/subcategory.dart';
import '../models/master_branch.dart';
import '../services/firebase_service.dart';
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
  bool _isPasswordVisible = false;
  bool _isAuthKeyVisible = false;
  late Account currentAccount;

  @override
  void initState() {
    super.initState();
    currentAccount = widget.account;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF3E2411)),
            onPressed: () => _editAccount(),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteAccount(),
          ),
        ],
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
                  color: Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                color: Colors.white,
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
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account Information
            const Text(
              'Account Information',
              style: TextStyle(
                color: Colors.white,
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
              onVisibilityToggle: () {
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
            
            // Additional Space
            if (currentAccount.additionalSpace.isNotEmpty)
              _buildInfoCard(
                'Additional Information',
                currentAccount.additionalSpace,
                Icons.note,
                copyable: true,
                isMultiline: true,
              ),
            
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
          color: Colors.grey[800]!,
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
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (hasVisibilityToggle)
                IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
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
                    color: Colors.grey[400],
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
              color: value.isNotEmpty ? Colors.white : Colors.grey[500],
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

  void _editAccount() {
    // Navigate to edit account page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountPage(
          account: currentAccount, // Pass account for editing
        ),
      ),
    ).then((result) {
      if (result != null && result is Account) {
        // Account was updated, save it and go back to refresh parent
        _updateAccount(result);
      }
    });
  }

  Future<void> _updateAccount(Account updatedAccount) async {
    try {
      // Update the account in Firebase
      await _firebaseService.updateAccountInSubcategory(
        widget.masterBranch.id,
        widget.subcategory.id,
        updatedAccount,
      );
      
      // Update the local state
      setState(() {
        currentAccount = updatedAccount;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteAccount() async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed) {
      try {
        await _firebaseService.deleteAccountFromSubcategory(
          widget.masterBranch.id,
          widget.subcategory.id,
          currentAccount.id,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      } catch (e) {
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
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${currentAccount.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]),
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
}
