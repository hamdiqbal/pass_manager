import 'package:flutter/material.dart';
import '../models/master_branch.dart';
import '../models/subcategory.dart';
import '../models/custom_field.dart';
import '../services/firebase_service.dart';
import 'subcategory_page.dart';
import 'subcategory_detail_page.dart';
import 'master_branch_page.dart';

class MasterBranchDetailPage extends StatefulWidget {
  final MasterBranch masterBranch;

  const MasterBranchDetailPage({
    super.key,
    required this.masterBranch,
  });

  @override
  State<MasterBranchDetailPage> createState() => _MasterBranchDetailPageState();
}

class _MasterBranchDetailPageState extends State<MasterBranchDetailPage> {
  late MasterBranch currentMasterBranch;
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, bool> hiddenFieldVisibility = {}; // Track visibility of hidden fields

  @override
  void initState() {
    super.initState();
    currentMasterBranch = widget.masterBranch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2411),
        elevation: 0,
        title: Text(
          currentMasterBranch.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, currentMasterBranch),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                              Icons.folder,
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
                                  currentMasterBranch.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentMasterBranch.additionalField,
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
                    ),
                    // Edit button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3E2411),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: _editMasterBranch,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
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
                Container(
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
                  child: Text(
                    currentMasterBranch.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
                
                // Custom Fields Display
                if (currentMasterBranch.customFields.isNotEmpty) ...[
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
                  ...currentMasterBranch.customFields.map((field) => _buildCustomFieldDisplay(field)).toList(),
                ],
                const SizedBox(height: 32),
                
                // Divider line
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: 32,
                ),
                
                // Subcategories Heading with Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subcategories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _navigateToSubcategoryPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E2411),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Add Subcategory',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (currentMasterBranch.subcategories.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentMasterBranch.subcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = currentMasterBranch.subcategories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => _navigateToSubcategoryDetail(subcategory),
                          onLongPress: () => _showSubcategoryOptions(subcategory),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E2411).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.category,
                              color: Color(0xFF3E2411),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            subcategory.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${subcategory.accounts.length} accounts',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF3E2411),
                            size: 16,
                          ),
                        ),
                      );
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No subcategories present',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSubcategoryPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubcategoryPage(masterBranch: currentMasterBranch),
      ),
    );

    if (result != null && result is Subcategory) {
      try {
        // Save to Firebase
        await _firebaseService.addSubcategoryToMasterBranch(currentMasterBranch.id, result);
        
        // Update local state
        setState(() {
          currentMasterBranch = currentMasterBranch.copyWith(
            subcategories: [...currentMasterBranch.subcategories, result],
          );
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subcategory saved successfully!'),
              backgroundColor: Color(0xFF3E2411),
            ),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving subcategory: $e'),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      }
    }
  }

  void _navigateToSubcategoryDetail(Subcategory subcategory) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubcategoryDetailPage(
          subcategory: subcategory,
          masterBranchId: currentMasterBranch.id,
          masterBranch: currentMasterBranch,
        ),
      ),
    );

    // If the subcategory was updated, replace it in the list and save to Firebase
    if (result != null && result is Subcategory) {
      try {
        // Save to Firebase
        await _firebaseService.updateSubcategoryInMasterBranch(currentMasterBranch.id, result);
        
        // Update local state
        setState(() {
          final subcategoryIndex = currentMasterBranch.subcategories.indexWhere((s) => s.id == result.id);
          if (subcategoryIndex != -1) {
            final updatedSubcategories = [...currentMasterBranch.subcategories];
            updatedSubcategories[subcategoryIndex] = result;
            currentMasterBranch = currentMasterBranch.copyWith(
              subcategories: updatedSubcategories,
            );
          }
        });
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating subcategory: $e'),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      }
    }
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

  Future<void> _deleteSubcategory(Subcategory subcategory) async {
    final confirmed = await _showDeleteConfirmation(
      context,
      'Delete Subcategory',
      'Are you sure you want to delete "${subcategory.name}"? This will also delete all accounts within it. This action cannot be undone.',
    );

    if (confirmed) {
      try {
        // Delete from Firebase
        await _firebaseService.deleteSubcategoryFromMasterBranch(currentMasterBranch.id, subcategory.id);
        
        // Update local state
        setState(() {
          currentMasterBranch = currentMasterBranch.copyWith(
            subcategories: currentMasterBranch.subcategories
                .where((sub) => sub.id != subcategory.id)
                .toList(),
          );
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subcategory deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
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

  void _editMasterBranch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MasterBranchPage(masterBranch: currentMasterBranch),
      ),
    );

    if (result != null && result is MasterBranch) {
      try {
        // Save to Firebase
        await _firebaseService.updateMasterBranch(result);
        
        // Update local state
        setState(() {
          currentMasterBranch = result;
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Master branch updated successfully!'),
              backgroundColor: Color(0xFF3E2411),
            ),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update master branch: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showSubcategoryOptions(Subcategory subcategory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              subcategory.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Subcategory', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteSubcategory(subcategory);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _editSubcategory(Subcategory subcategory) async {
    print('🔸 Edit subcategory called with: ${subcategory.id}');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubcategoryPage(
          masterBranch: currentMasterBranch,
          subcategory: subcategory,
        ),
      ),
    );

    print('🔸 Edit subcategory result: $result');
    print('🔸 Result type: ${result.runtimeType}');

    if (result == 'deleted') {
      // Subcategory was deleted, force refresh the state
      print('Subcategory deleted, forcing state refresh...');
      
      // Force remove the subcategory from local state immediately
      setState(() {
        final updatedSubcategories = currentMasterBranch.subcategories
            .where((s) => s.id != subcategory.id)
            .toList();
        currentMasterBranch = currentMasterBranch.copyWith(subcategories: updatedSubcategories);
      });
      
      // Also try to refresh from Firebase in the background
      try {
        final updatedMasterBranch = await _firebaseService.getMasterBranchById(currentMasterBranch.id);
        if (updatedMasterBranch != null) {
          print('Successfully reloaded master branch with ${updatedMasterBranch.subcategories.length} subcategories');
          setState(() {
            currentMasterBranch = updatedMasterBranch;
          });
        }
      } catch (e) {
        print('Error reloading master branch: $e');
        // Local state update already happened above
      }
    } else if (result != null && result is Subcategory) {
      try {
        // Update the subcategory in Firebase
        await _firebaseService.updateSubcategoryInMasterBranch(
          currentMasterBranch.id, 
          result
        );
        
        // Update local state
        setState(() {
          final index = currentMasterBranch.subcategories.indexWhere((s) => s.id == subcategory.id);
          if (index != -1) {
            final updatedSubcategories = List<Subcategory>.from(currentMasterBranch.subcategories);
            updatedSubcategories[index] = result;
            currentMasterBranch = currentMasterBranch.copyWith(subcategories: updatedSubcategories);
          }
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

  Future<void> _deleteMasterBranch() async {
    // First confirmation popup
    final firstConfirmed = await _showDeleteConfirmation(
      context,
      'Delete Master Branch',
      'Are you sure you want to delete "${currentMasterBranch.name}"?',
    );

    if (!firstConfirmed) return;

    // Count subcategories for second confirmation
    int subcategoryCount = currentMasterBranch.subcategories.length;
    
    // Second confirmation popup with subcategory count
    final secondConfirmed = await _showDeleteConfirmation(
      context,
      'Warning: Delete All Data',
      'You have $subcategoryCount ${subcategoryCount == 1 ? 'category' : 'categories'} in this branch. All subcategories and their accounts will also be deleted. This action cannot be undone.',
    );

    if (!secondConfirmed) return;

    try {
      // Delete from Firebase
      await _firebaseService.deleteMasterBranch(currentMasterBranch.id);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master branch deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to previous screen (likely master branch list)
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // Pop twice to go back to main screen
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting master branch: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
}
