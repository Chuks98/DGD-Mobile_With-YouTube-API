import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'login.dart';
import 'dialog.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  bool _isObscure = true;
  bool _isConfirmObscure = true;

  bool _isPasswordValid = false;

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

  void _register() {
    if((emailController.text.isEmpty) || _usernameController.text.isEmpty || _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      popupMessage(context, 'Hi', 'Please fill up all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text('Register', style: TextStyle(color: Colors.white)),
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
                onPressed: _isPasswordValid ? _register : null,
                child: Text('Register', style: TextStyle(color: Colors.white, fontSize: 15)),
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
                  text: 'Already has an account? ',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(color: const Color.fromARGB(255, 236, 147, 12)),
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
          ],
        ),
      ),
    );
  }
}