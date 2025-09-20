import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/master_branch.dart';
import '../models/subcategory.dart';
import '../models/account.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Collection references
  CollectionReference get _masterBranchesCollection =>
      _firestore.collection('users').doc(currentUserId).collection('master_branches');

  // Master Branch Operations
  Future<void> saveMasterBranch(MasterBranch masterBranch) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      await _masterBranchesCollection.doc(masterBranch.id).set(masterBranch.toJson());
    } catch (e) {
      throw Exception('Failed to save master branch: $e');
    }
  }

  Future<List<MasterBranch>> getMasterBranches() async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      QuerySnapshot snapshot = await _masterBranchesCollection
          .orderBy('createdAt', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => MasterBranch.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load master branches: $e');
    }
  }

  Future<void> updateMasterBranch(MasterBranch masterBranch) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      await _masterBranchesCollection.doc(masterBranch.id).update(masterBranch.toJson());
    } catch (e) {
      throw Exception('Failed to update master branch: $e');
    }
  }

  Future<void> deleteMasterBranch(String masterBranchId) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      await _masterBranchesCollection.doc(masterBranchId).delete();
    } catch (e) {
      throw Exception('Failed to delete master branch: $e');
    }
  }

  // Subcategory Operations (within a master branch)
  Future<void> addSubcategoryToMasterBranch(String masterBranchId, Subcategory subcategory) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      // Get the current master branch
      DocumentSnapshot doc = await _masterBranchesCollection.doc(masterBranchId).get();
      if (!doc.exists) throw Exception('Master branch not found');
      
      MasterBranch masterBranch = MasterBranch.fromJson(doc.data() as Map<String, dynamic>);
      
      // Add the new subcategory
      List<Subcategory> updatedSubcategories = [...masterBranch.subcategories, subcategory];
      MasterBranch updatedMasterBranch = masterBranch.copyWith(subcategories: updatedSubcategories);
      
      // Save the updated master branch
      await updateMasterBranch(updatedMasterBranch);
    } catch (e) {
      throw Exception('Failed to add subcategory: $e');
    }
  }

  Future<void> updateSubcategoryInMasterBranch(String masterBranchId, Subcategory updatedSubcategory) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      // Get the current master branch
      DocumentSnapshot doc = await _masterBranchesCollection.doc(masterBranchId).get();
      if (!doc.exists) throw Exception('Master branch not found');
      
      MasterBranch masterBranch = MasterBranch.fromJson(doc.data() as Map<String, dynamic>);
      
      // Find and update the subcategory
      List<Subcategory> updatedSubcategories = masterBranch.subcategories.map((sub) {
        return sub.id == updatedSubcategory.id ? updatedSubcategory : sub;
      }).toList();
      
      MasterBranch updatedMasterBranch = masterBranch.copyWith(subcategories: updatedSubcategories);
      
      // Save the updated master branch
      await updateMasterBranch(updatedMasterBranch);
    } catch (e) {
      throw Exception('Failed to update subcategory: $e');
    }
  }

  Future<void> deleteSubcategoryFromMasterBranch(String masterBranchId, String subcategoryId) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      // Get the current master branch
      DocumentSnapshot doc = await _masterBranchesCollection.doc(masterBranchId).get();
      if (!doc.exists) throw Exception('Master branch not found');
      
      MasterBranch masterBranch = MasterBranch.fromJson(doc.data() as Map<String, dynamic>);
      
      // Remove the subcategory
      List<Subcategory> updatedSubcategories = masterBranch.subcategories
          .where((sub) => sub.id != subcategoryId)
          .toList();
      
      MasterBranch updatedMasterBranch = masterBranch.copyWith(subcategories: updatedSubcategories);
      
      // Save the updated master branch
      await updateMasterBranch(updatedMasterBranch);
    } catch (e) {
      throw Exception('Failed to delete subcategory: $e');
    }
  }

  // Account Operations (within a subcategory)
  Future<void> addAccountToSubcategory(String masterBranchId, String subcategoryId, Account account) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      // Get the current master branch
      DocumentSnapshot doc = await _masterBranchesCollection.doc(masterBranchId).get();
      if (!doc.exists) throw Exception('Master branch not found');
      
      MasterBranch masterBranch = MasterBranch.fromJson(doc.data() as Map<String, dynamic>);
      
      // Find and update the subcategory with the new account
      List<Subcategory> updatedSubcategories = masterBranch.subcategories.map((sub) {
        if (sub.id == subcategoryId) {
          List<Account> updatedAccounts = [...sub.accounts, account];
          return sub.copyWith(accounts: updatedAccounts);
        }
        return sub;
      }).toList();
      
      MasterBranch updatedMasterBranch = masterBranch.copyWith(subcategories: updatedSubcategories);
      
      // Save the updated master branch
      await updateMasterBranch(updatedMasterBranch);
    } catch (e) {
      throw Exception('Failed to add account: $e');
    }
  }

  Future<void> updateAccountInSubcategory(String masterBranchId, String subcategoryId, Account updatedAccount) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      // Get the current master branch
      DocumentSnapshot doc = await _masterBranchesCollection.doc(masterBranchId).get();
      if (!doc.exists) throw Exception('Master branch not found');
      
      MasterBranch masterBranch = MasterBranch.fromJson(doc.data() as Map<String, dynamic>);
      
      // Find and update the account within the subcategory
      List<Subcategory> updatedSubcategories = masterBranch.subcategories.map((sub) {
        if (sub.id == subcategoryId) {
          List<Account> updatedAccounts = sub.accounts.map((acc) {
            return acc.id == updatedAccount.id ? updatedAccount : acc;
          }).toList();
          return sub.copyWith(accounts: updatedAccounts);
        }
        return sub;
      }).toList();
      
      MasterBranch updatedMasterBranch = masterBranch.copyWith(subcategories: updatedSubcategories);
      
      // Save the updated master branch
      await updateMasterBranch(updatedMasterBranch);
    } catch (e) {
      throw Exception('Failed to update account: $e');
    }
  }

  Future<void> deleteAccountFromSubcategory(String masterBranchId, String subcategoryId, String accountId) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    try {
      // Get the current master branch
      DocumentSnapshot doc = await _masterBranchesCollection.doc(masterBranchId).get();
      if (!doc.exists) throw Exception('Master branch not found');
      
      MasterBranch masterBranch = MasterBranch.fromJson(doc.data() as Map<String, dynamic>);
      
      // Find and remove the account from the subcategory
      List<Subcategory> updatedSubcategories = masterBranch.subcategories.map((sub) {
        if (sub.id == subcategoryId) {
          List<Account> updatedAccounts = sub.accounts
              .where((acc) => acc.id != accountId)
              .toList();
          return sub.copyWith(accounts: updatedAccounts);
        }
        return sub;
      }).toList();
      
      MasterBranch updatedMasterBranch = masterBranch.copyWith(subcategories: updatedSubcategories);
      
      // Save the updated master branch
      await updateMasterBranch(updatedMasterBranch);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Stream for real-time updates
  Stream<List<MasterBranch>> getMasterBranchesStream() {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    return _masterBranchesCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MasterBranch.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Utility method to check if user is authenticated
  bool get isUserAuthenticated => currentUserId != null;
}
