import 'package:daily_grace_devotional/auth_service.dart';
import 'package:daily_grace_devotional/cache-service.dart';
import 'package:daily_grace_devotional/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user-model.dart';
import 'package:daily_grace_devotional/env.dart';
import 'login.dart';
import 'display.dart';
import 'dialog.dart';
import '../cache-service.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isPasswordValid = false;
  bool _isLoading = false; // Added loading state
  GoogleAuthService googleAuthService = GoogleAuthService();
  bool _isAuthorized = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmObscure = !_isConfirmObscure;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _isPasswordValid = value.isNotEmpty && value.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
    // _checkGoogleAccount();
  }

  Future<void> _checkLoggedInUser() async {
    final username = await CacheService().getUser();
    if (username != null) {
      await popupMessage(context, "Alert", "You are already logged in");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyApp()));
    }
  }

  // Future<void> _checkGoogleAccount() async {
  //   final googleUser = await googleAuthService.signInSilently();
  //   if (googleUser != null) {
  //     setState(() {
  //       _isAuthorized = true;
  //     });
  //     await _registerWithGoogle();
  //   }
  // }

  void _register() async {
    if (emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      popupMessage(context, 'Hi', 'Please fill up all the fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      popupMessage(context, 'Error', 'Passwords do not match');
      return;
    }

    final user = User(
      email: emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    final Map<String, dynamic> requestData = user.toMap();
    final String url = '${EnvironmentVariables.apiUrl}/register';

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await popupMessage(context, 'Success', 'Registration successful');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyApp()));
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        popupMessage(context, 'Error', '${responseData['message']}');
      }
    } catch (e) {
      popupMessage(context, 'Error', 'An error occurred: $e');
    }
  }

  Future<void> _registerWithGoogle() async {
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

    Map<String, dynamic>? user;
    try {
      user = await googleAuthService.signInWithGoogle();
    } catch (e) {
      print("Error during Google sign-in: $e");
    } finally {
      if (mounted) {
        Navigator.pop(context); // Hide loading indicator
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      String? username = user['username'];
      String? email = user['email'];
      String? profilePicture = user['profilePicture'];

      final requestData = User(
        email: email ?? '',
        username: username ?? '',
        profilePicture: profilePicture ?? '',
      );

      final String url = '${EnvironmentVariables.apiUrl}/register';

      try {
        final http.Response response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestData.toMap()), // Ensure toMap() is used
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await CacheService().saveUser(username!);
          await popupMessage(
              context, 'Success', 'Google registration successful');
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyApp()));
        } else {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          popupMessage(context, 'Error', '${responseData['message']}');
        }
      } catch (e) {
        popupMessage(context, 'Error', 'An error occurred: $e');
      }
    } else {
      popupMessage(context, "Error", "Google registration failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text('Register',
            style: TextStyle(color: Colors.white, fontSize: 20)),
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
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (!EmailValidator.validate(value ?? '')) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
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
              onChanged: _validatePassword,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmObscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: _toggleConfirmPasswordVisibility,
                ),
              ),
              style: TextStyle(color: Colors.white),
              obscureText: _isConfirmObscure,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                child: Text('Register',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 236, 147, 12)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "or",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: _registerWithGoogle,
              child: Container(
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
                      'Register with Google',
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
