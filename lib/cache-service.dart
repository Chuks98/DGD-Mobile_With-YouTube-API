import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String user = "user";
  static const String admin = "admin";

  // Function to save user data
  Future<void> saveUser(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(user, data);
  }

  // Function to retrieve user data
  Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(user);
  }

  // Function to clear user data
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(user);
  }

  // Similar functions for admin data using a different key (_adminKey)
  Future<void> saveAdmin(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(admin, data);
  }

  Future<String?> getAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(admin);
  }

  Future<void> clearAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(admin);
  }
}
