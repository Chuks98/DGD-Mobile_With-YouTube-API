import 'package:daily_grace_devotional/main.dart';
import 'package:flutter/material.dart';
import 'package:daily_grace_devotional/screens/login.dart';
import 'package:daily_grace_devotional/cache-service.dart';
import './dialog.dart';

class AdminLogin extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  AdminLogin({required this.onLoginSuccess});

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
    _checkLoggedInAdmin();
  }

  Future<void> _checkLoggedInUser() async {
    final username = await CacheService().getUser();
    if (username == null) {
      await popupMessage(context, "Alert", "You need to first login as a user");
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  Future<void> _checkLoggedInAdmin() async {
    final username = await CacheService().getAdmin();
    if (username != null) {
      await popupMessage(
          context, "Alert", "You are already logged in as an admin");
      widget.onLoginSuccess();
      // Navigate to MainApp
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }

  void _login(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      popupMessage(context, "Alert", "Username and password cannot be empty.");
      return;
    }

    if (username == 'admin' && password == 'Devotion@2024') {
      await CacheService().saveAdmin(username);
      await popupMessage(context, "Success", "Admin logged in successfully!");
      widget.onLoginSuccess();
      // Navigate to MainApp
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } else if (username != 'admin') {
      popupMessage(context, "Error", "Invalid admin username.");
    } else if (username == 'admin' && password != "Devotion@2024") {
      popupMessage(context, "Error", "Invalid admin password.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text('Admin Login', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Admin Username',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              style: TextStyle(color: Colors.white),
              obscureText: _isObscure,
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Admin Login',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
