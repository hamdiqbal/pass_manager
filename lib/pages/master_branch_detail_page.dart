import 'package:flutter/material.dart';
import '../models/master_branch.dart';
import '../models/subcategory.dart';
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

  @override
  void initState() {
    super.initState();
    currentMasterBranch = widget.masterBranch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editMasterBranch,
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
                // Master Branch Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F2E),
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
                              color: const Color(0xFF4A90E2).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.folder,
                              color: Color(0xFF4A90E2),
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
                                    color: Colors.white,
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
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentMasterBranch.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[300],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Add Subcategory Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToSubcategoryPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add Subcategory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Subcategories List
                if (currentMasterBranch.subcategories.isNotEmpty) ...[
                  const Text(
                    'Subcategories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: currentMasterBranch.subcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = currentMasterBranch.subcategories[index];
                      return GestureDetector(
                        onTap: () => _navigateToSubcategoryDetail(subcategory),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1F2E),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A90E2).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.category,
                                      color: Color(0xFF4A90E2),
                                      size: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                    onPressed: () => _deleteSubcategory(subcategory),
                                    padding: const EdgeInsets.all(2),
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subcategory.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subcategory.additionalField,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${subcategory.accounts.length} accounts',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                              ),
                            ],
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
                      color: const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: Colors.grey[600],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Subcategories Yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first subcategory to get started',
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
              backgroundColor: Color(0xFF4A90E2),
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
          backgroundColor: const Color(0xFF1A1F2E),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
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
                style: TextStyle(color: Color(0xFF4A90E2)),
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

  void _editMasterBranch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MasterBranchPage(masterBranch: currentMasterBranch),
      ),
    );

    if (result != null && result is MasterBranch) {
      setState(() {
        currentMasterBranch = result;
      });
    }
  }
}
