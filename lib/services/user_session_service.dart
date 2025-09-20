import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService {
  static const String _lastUserEmailKey = 'last_user_email';
  static const String _lastUserIdKey = 'last_user_id';

  // Store the last logged user information
  Future<void> storeLastUser(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUserIdKey, userId);
    await prefs.setString(_lastUserEmailKey, email);
  }

  // Get the last logged user ID
  Future<String?> getLastUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUserIdKey);
  }

  // Get the last logged user email
  Future<String?> getLastUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUserEmailKey);
  }

  // Check if there's a stored user
  Future<bool> hasStoredUser() async {
    final userId = await getLastUserId();
    final email = await getLastUserEmail();
    return userId != null && email != null;
  }

  // Clear stored user information (on sign out)
  Future<void> clearStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastUserIdKey);
    await prefs.remove(_lastUserEmailKey);
  }

  // Get stored user information as a map
  Future<Map<String, String?>> getStoredUserInfo() async {
    return {
      'userId': await getLastUserId(),
      'email': await getLastUserEmail(),
    };
  }
}
