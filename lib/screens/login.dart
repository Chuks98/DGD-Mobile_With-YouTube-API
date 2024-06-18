import 'package:daily_grace_devotional/screens/register.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:daily_grace_devotional/env.dart';
import 'package:daily_grace_devotional/cache-service.dart';
import './dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'package:daily_grace_devotional/auth_service.dart'; // Import GoogleAuthService

class Login extends StatefulWidget {
  final VoidCallback? onLogin;

  Login({this.onLogin});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleAuthService googleAuthService = GoogleAuthService();

  bool _isObscure = true;
  bool _isLoading = false; // Added loading state

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _checkLoggedInUser();
  // }

  // Future<void> _checkLoggedInUser() async {
  //   final username = await CacheService().getUser();
  //   if (username != null && mounted) {
  //     await popupMessage(context, "Alert", "You are already logged in");
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => MyApp()));
  //   }
  // }

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      popupMessage(context, "Error", "Username and password cannot be empty.");
      return;
    }

    final response = await http.post(
      Uri.parse('${EnvironmentVariables.apiUrl}/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Successful login
      await CacheService().saveUser(username);
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      await popupMessage(context, "Success", responseData['message']);

      // Navigate to MainApp
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } else {
      // Handle different error responses
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      popupMessage(context, "Error", responseData['message']);
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    Map<String, dynamic>? user = await googleAuthService.signInWithGoogle();

    if (mounted) {
      Navigator.pop(context); // Hide loading indicator
      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        // Retrieve user profile information
        String? username = user['username'];
        String? email = user['email'];

        // Store user information in the database
        final response = await http.post(
          Uri.parse('${EnvironmentVariables.apiUrl}/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': username ?? '',
            'email': email ?? '',
          }),
        );

        if (response.statusCode == 200) {
          // Successful login
          await CacheService().saveUser(username!);
          await popupMessage(
              context, "Success", "Logged in with Google successfully!");

          // Navigate to MainApp
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        } else {
          // Handle error response
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          popupMessage(context, "Error", responseData['message']);
        }
      } else {
        popupMessage(context, "Error", "Google login failed.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title:
            Text('Login', style: TextStyle(color: Colors.white, fontSize: 20)),
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
                labelText: 'Username',
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
            Container(
              height: 50.0,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: Text('Login',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: RichText(
                text: TextSpan(
                  text: 'Do not have an account? ',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Register',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 236, 147, 12)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Register()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'or',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white)),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _loginWithGoogle,
              child: Container(
                height: 50.0,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/google_icon.png',
                      height: 20.0,
                      width: 20.0,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Login with Google',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
