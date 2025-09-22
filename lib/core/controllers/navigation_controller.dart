import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/master_branch.dart';
import '../../models/subcategory.dart';
import '../constants/app_constants.dart';
import '../utils/ui_utils.dart';
import '../utils/app_utils.dart';

/// Controller for managing navigation and data flow between pages
class NavigationController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _error;
  List<MasterBranch> _masterBranches = [];
  List<Subcategory> _subcategories = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MasterBranch> get masterBranches => List.unmodifiable(_masterBranches);
  List<Subcategory> get subcategories => List.unmodifiable(_subcategories);

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

  /// Load master branches
  Future<void> loadMasterBranches() async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('master_branches')
          .orderBy('name')
          .get();

      _masterBranches = querySnapshot.docs.map((doc) {
        return MasterBranch.fromFirestore(doc);
      }).toList();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load subcategories for a master branch
  Future<void> loadSubcategories(String masterBranchId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('master_branches')
          .doc(masterBranchId)
          .collection('subcategories')
          .orderBy('name')
          .get();

      _subcategories = querySnapshot.docs.map((doc) {
        return Subcategory.fromFirestore(doc);
      }).toList();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new master branch
  Future<bool> addMasterBranch(String name) async {
    try {
      _setLoading(true);
      _setError(null);

      // Validate input
      final validationError = ValidationUtils.validateRequired(name, fieldName: 'Master branch name');
      if (validationError != null) {
        throw Exception(validationError);
      }

      // Check for duplicates
      final normalizedName = StringUtils.normalize(name);
      final exists = _masterBranches.any((branch) => 
          branch.name.toLowerCase() == normalizedName.toLowerCase());
      
      if (exists) {
        throw Exception('A master branch with this name already exists');
      }

      await _firestore.collection('master_branches').add({
        'name': normalizedName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastModified': FieldValue.serverTimestamp(),
      });

      await loadMasterBranches();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new subcategory
  Future<bool> addSubcategory(String masterBranchId, String name) async {
    try {
      _setLoading(true);
      _setError(null);

      // Validate input
      final validationError = ValidationUtils.validateRequired(name, fieldName: 'Subcategory name');
      if (validationError != null) {
        throw Exception(validationError);
      }

      // Check for duplicates within the master branch
      final normalizedName = StringUtils.normalize(name);
      final exists = _subcategories.any((subcategory) => 
          subcategory.name.toLowerCase() == normalizedName.toLowerCase());
      
      if (exists) {
        throw Exception('A subcategory with this name already exists in this master branch');
      }

      await _firestore
          .collection('master_branches')
          .doc(masterBranchId)
          .collection('subcategories')
          .add({
        'name': normalizedName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastModified': FieldValue.serverTimestamp(),
      });

      await loadSubcategories(masterBranchId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a master branch
  Future<bool> deleteMasterBranch(String masterBranchId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Delete all subcategories and their accounts first
      final subcategoriesSnapshot = await _firestore
          .collection('master_branches')
          .doc(masterBranchId)
          .collection('subcategories')
          .get();

      // Delete accounts in each subcategory
      for (final subcategoryDoc in subcategoriesSnapshot.docs) {
        final accountsSnapshot = await _firestore
            .collection('subcategories')
            .doc(subcategoryDoc.id)
            .collection('accounts')
            .get();

        for (final accountDoc in accountsSnapshot.docs) {
          await accountDoc.reference.delete();
        }

        await subcategoryDoc.reference.delete();
      }

      // Delete the master branch
      await _firestore
          .collection('master_branches')
          .doc(masterBranchId)
          .delete();

      // Remove from local list
      _masterBranches.removeWhere((branch) => branch.id == masterBranchId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a subcategory
  Future<bool> deleteSubcategory(String subcategoryId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Delete all accounts in the subcategory first
      final accountsSnapshot = await _firestore
          .collection('subcategories')
          .doc(subcategoryId)
          .collection('accounts')
          .get();

      for (final accountDoc in accountsSnapshot.docs) {
        await accountDoc.reference.delete();
      }

      // Delete the subcategory from master branch collection
      final subcategoryRef = _firestore
          .collection('subcategories')
          .doc(subcategoryId);
      
      await subcategoryRef.delete();

      // Remove from local list
      _subcategories.removeWhere((subcategory) => subcategory.id == subcategoryId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get master branch by ID
  MasterBranch? getMasterBranchById(String id) {
    try {
      return _masterBranches.firstWhere((branch) => branch.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get subcategory by ID
  Subcategory? getSubcategoryById(String id) {
    try {
      return _subcategories.firstWhere((subcategory) => subcategory.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search master branches
  List<MasterBranch> searchMasterBranches(String query) {
    if (StringUtils.isNullOrEmpty(query)) return _masterBranches;

    final lowercaseQuery = query.toLowerCase();
    return _masterBranches.where((branch) {
      return branch.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Search subcategories
  List<Subcategory> searchSubcategories(String query) {
    if (StringUtils.isNullOrEmpty(query)) return _subcategories;

    final lowercaseQuery = query.toLowerCase();
    return _subcategories.where((subcategory) {
      return subcategory.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Refresh data for a specific context
  Future<void> refreshData({
    String? masterBranchId,
    bool refreshMasterBranches = false,
  }) async {
    if (refreshMasterBranches) {
      await loadMasterBranches();
    }
    
    if (masterBranchId != null) {
      await loadSubcategories(masterBranchId);
    }
  }

  /// Navigate with result handling
  Future<T?> navigateWithResult<T>(
    BuildContext context,
    Widget destination, {
    bool fullscreenDialog = false,
  }) async {
    if (!context.mounted) return null;

    final result = await Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (context) => destination,
        fullscreenDialog: fullscreenDialog,
      ),
    );

    return result;
  }

  /// Show add item dialog
  Future<String?> showAddItemDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    String? initialValue,
  }) async {
    String inputValue = initialValue ?? '';
    
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppConstants.backgroundColor,
          title: Text(
            title,
            style: AppConstants.subheadingStyle,
          ),
          content: TextField(
            onChanged: (value) => inputValue = value,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppConstants.primaryColor),
              ),
            ),
            autofocus: true,
            controller: TextEditingController(text: initialValue),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                AppConstants.cancel,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                if (inputValue.trim().isNotEmpty) {
                  Navigator.pop(context, inputValue.trim());
                }
              },
              child: const Text(
                AppConstants.add,
                style: TextStyle(color: AppConstants.primaryColor),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
      },
    );

    return result;
  }
}
