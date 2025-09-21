import 'package:flutter/material.dart';
import '../models/subcategory.dart';
import '../models/account.dart';
import '../models/master_branch.dart';
import '../models/custom_field.dart';
import '../services/firebase_service.dart';
import 'add_account_page.dart';
import 'account_detail_page.dart';
import 'subcategory_page.dart';

class SubcategoryDetailPage extends StatefulWidget {
  final Subcategory subcategory;
  final String masterBranchId;
  final MasterBranch? masterBranch;

  const SubcategoryDetailPage({
    super.key,
    required this.subcategory,
    required this.masterBranchId,
    this.masterBranch,
  });

  @override
  State<SubcategoryDetailPage> createState() => _SubcategoryDetailPageState();
}

class _SubcategoryDetailPageState extends State<SubcategoryDetailPage> {
  late Subcategory currentSubcategory;
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, bool> hiddenFieldVisibility = {}; // Track visibility of hidden fields

  @override
  void initState() {
    super.initState();
    currentSubcategory = widget.subcategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2411),
        elevation: 0,
        title: Text(
          currentSubcategory.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, currentSubcategory),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editSubcategory,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subcategory Info Card
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E2411).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.category,
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
                                  currentSubcategory.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentSubcategory.additionalField,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentSubcategory.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      
                      // Custom Fields Display
                      if (currentSubcategory.customFields.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Custom Fields',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...currentSubcategory.customFields.map((field) => _buildCustomFieldDisplay(field)).toList(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Add Account Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToAddAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E2411),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Accounts List
                if (currentSubcategory.accounts.isNotEmpty) ...[
                  const Text(
                    'Accounts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentSubcategory.accounts.length,
                    itemBuilder: (context, index) {
                      final account = currentSubcategory.accounts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          color: const Color(0xFFF5F5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E2411).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.account_circle,
                                color: Color(0xFF3E2411),
                              ),
                            ),
                            title: Text(
                              account.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              account.username,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF3E2411),
                              size: 16,
                            ),
                            onTap: () => _showAccountDetails(account),
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
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
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          color: Colors.grey[600],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Accounts Yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first account to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAccountPage(),
      ),
    );

    if (result != null && result is Account) {
      try {
        // Save to Firebase
        await _firebaseService.addAccountToSubcategory(
          widget.masterBranchId,
          currentSubcategory.id,
          result,
        );
        
        // Update local state
        setState(() {
          currentSubcategory = currentSubcategory.copyWith(
            accounts: [...currentSubcategory.accounts, result],
          );
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account saved successfully!'),
              backgroundColor: Color(0xFF3E2411),
            ),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving account: $e'),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      }
    }
  }

  Future<void> _loadSubcategory() async {
    try {
      final masterBranches = await _firebaseService.getMasterBranches();
      final masterBranch = masterBranches.firstWhere(
        (mb) => mb.id == widget.masterBranchId,
      );
      final updatedSubcategory = masterBranch.subcategories.firstWhere(
        (sub) => sub.id == widget.subcategory.id,
      );
      
      setState(() {
        currentSubcategory = updatedSubcategory;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading subcategory: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAccountDetails(Account account) async {
    MasterBranch? masterBranch = widget.masterBranch;
    
    // If masterBranch is not provided, fetch it
    if (masterBranch == null) {
      try {
        final masterBranches = await _firebaseService.getMasterBranches();
        masterBranch = masterBranches.firstWhere(
          (mb) => mb.id == widget.masterBranchId,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading master branch: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountDetailPage(
          account: account,
          subcategory: widget.subcategory,
          masterBranch: masterBranch!,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Account was updated/deleted, refresh the page
        _loadSubcategory();
      }
    });
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F5F5),
          title: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
          content: Text(
            content,
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF3E2411)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _deleteAccount(Account account) async {
    final confirmed = await _showDeleteConfirmation(
      context,
      'Delete Account',
      'Are you sure you want to delete "${account.name}"? This action cannot be undone.',
    );

    if (confirmed) {
      try {
        // Delete from Firebase
        await FirebaseService().deleteAccountFromSubcategory(
          widget.masterBranchId,
          currentSubcategory.id,
          account.id,
        );
        
        // Update local state
        setState(() {
          currentSubcategory = currentSubcategory.copyWith(
            accounts: currentSubcategory.accounts
                .where((acc) => acc.id != account.id)
                .toList(),
          );
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Show error message
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
  }

  Widget _buildCustomFieldDisplay(CustomField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
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
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  hiddenFieldVisibility[field.id] = !isVisible;
                });
              },
            ),
          ],
        );
      case 'linked':
      case 'text':
      default:
        return Text(
          field.value?.toString() ?? '',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
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

  void _editSubcategory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubcategoryPage(
          masterBranch: widget.masterBranch ?? MasterBranch(
            id: widget.masterBranchId,
            name: '',
            additionalField: '',
            description: '',
          ),
          subcategory: currentSubcategory,
        ),
      ),
    );

    if (result != null && result is Subcategory) {
      try {
        // Preserve existing accounts when updating
        final updatedSubcategory = result.copyWith(accounts: currentSubcategory.accounts);
        
        // Save to Firebase by updating the subcategory in the master branch
        await _firebaseService.updateSubcategoryInMasterBranch(
          widget.masterBranchId, 
          updatedSubcategory
        );
        
        // Update local state
        setState(() {
          currentSubcategory = updatedSubcategory;
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subcategory updated successfully!'),
              backgroundColor: Color(0xFF3E2411),
            ),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update subcategory: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteSubcategory() async {
    // First confirmation popup
    final firstConfirmed = await _showDeleteConfirmation(
      context,
      'Delete Subcategory',
      'Are you sure you want to delete "${currentSubcategory.name}"?',
    );

    if (!firstConfirmed) return;

    // Count accounts for second confirmation
    int accountCount = currentSubcategory.accounts.length;
    
    // Second confirmation popup with account count
    final secondConfirmed = await _showDeleteConfirmation(
      context,
      'Warning: Delete All Data',
      'You have $accountCount ${accountCount == 1 ? 'account' : 'accounts'} in this subcategory. All accounts will also be deleted. This action cannot be undone.',
    );

    if (!secondConfirmed) return;

    try {
      // Delete from Firebase
      await _firebaseService.deleteSubcategoryFromMasterBranch(
        widget.masterBranchId,
        currentSubcategory.id,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subcategory deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to master branch detail page
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting subcategory: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
}
