import 'package:daily_grace_devotional/cache-service.dart';
import 'package:daily_grace_devotional/main.dart';
import 'package:daily_grace_devotional/screens/admin-login.dart';
import 'package:daily_grace_devotional/screens/dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logout extends StatefulWidget {
  final VoidCallback onLogout;

  Logout({required this.onLogout});

  @override
  _LogoutState createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  bool _isAdminLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAdminLoginStatus();
  }

  Future<void> _checkAdminLoginStatus() async {
    final admin = await CacheService().getAdmin();
    setState(() {
      _isAdminLoggedIn = admin != null;
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await popupMessage(context, "Logged out", "Logged out successfully!");

    widget.onLogout(); // Trigger the login status check in MainApp
    // Navigate to MainApp
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  void _navigateToAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AdminLogin(
                onLoginSuccess: () {},
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Logout', style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isAdminLoggedIn)
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _navigateToAdminLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    child: Text('Admin Login',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x44FFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
