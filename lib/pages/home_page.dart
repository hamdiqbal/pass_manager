import 'package:flutter/material.dart';
import 'package:pass_manager/services/auth_service.dart';
import 'package:pass_manager/services/firebase_service.dart';
import 'package:pass_manager/models/master_branch.dart';
import 'package:pass_manager/pages/master_branch_page.dart';
import 'package:pass_manager/pages/master_branch_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MasterBranch> masterBranches = [];
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMasterBranches();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when the page becomes active again
    if (mounted) {
      _loadMasterBranches();
    }
  }

  Future<void> _loadMasterBranches() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (!_firebaseService.isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final branches = await _firebaseService.getMasterBranches();
      setState(() {
        masterBranches = branches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2411),
        elevation: 0,
        title: const Text(
          'SecurePass',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              try {
                print('Sign out button pressed');
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3E2411),
                      ),
                    );
                  },
                );

                await authService.signOut();
                print('Sign out completed');
                
                // Close loading dialog
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                
                // Force navigation to login page
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    '/', 
                    (route) => false
                  );
                }
              } catch (e) {
                print('Sign out error: $e');
                // Close loading dialog if open
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: $e'),
                      backgroundColor: Colors.red[600],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3E2411),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadMasterBranches,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E2411),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E2411),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3E2411).withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome to SecurePass!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hello ${user?.email ?? 'User'}!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your secure vault is ready to protect your passwords.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Master Branch Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToMasterBranchPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E2411),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add Master Branch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Master Branches List
                if (masterBranches.isNotEmpty) ...[
                  const Text(
                    'Your Master Branches',
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
                    itemCount: masterBranches.length,
                    itemBuilder: (context, index) {
                      final masterBranch = masterBranches[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          color: const Color(0xFFF5F5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E2411).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.folder,
                                color: Color(0xFF3E2411),
                              ),
                            ),
                            title: Text(
                              masterBranch.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${masterBranch.subcategories.length} categories',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF3E2411),
                              size: 16,
                            ),
                            onTap: () => _navigateToMasterBranchDetail(masterBranch),
                            onLongPress: () => _showMasterBranchOptions(masterBranch),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToMasterBranchPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MasterBranchPage(),
      ),
    );

    if (result != null && result is MasterBranch) {
      try {
        // Save to Firebase
        await _firebaseService.saveMasterBranch(result);
        
        // Update local state
        setState(() {
          masterBranches.add(result);
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Master branch saved successfully!'),
              backgroundColor: Color(0xFF3E2411),
            ),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving master branch: $e'),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      }
    }
  }

  void _navigateToMasterBranchDetail(MasterBranch masterBranch) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MasterBranchDetailPage(masterBranch: masterBranch),
      ),
    );

    // Always refresh when returning from master branch detail page
    // This ensures we see any changes made to master branches or their content
    if (mounted) {
      _loadMasterBranches();
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
            style: TextStyle(color: Colors.grey[600]),
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

  Future<void> _deleteMasterBranch(MasterBranch masterBranch) async {
    final confirmed = await _showDeleteConfirmation(
      context,
      'Delete Master Branch',
      'Are you sure you want to delete "${masterBranch.name}"? This will also delete all subcategories and accounts within it. This action cannot be undone.',
    );

    if (confirmed) {
      try {
        // Delete from Firebase
        await _firebaseService.deleteMasterBranch(masterBranch.id);
        
        // Update local state
        setState(() {
          masterBranches.removeWhere((mb) => mb.id == masterBranch.id);
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Master branch deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
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

  void _showMasterBranchOptions(MasterBranch masterBranch) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                masterBranch.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Master Branch', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMasterBranch(masterBranch);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
