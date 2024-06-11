import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _image;
  late String imageName = '';
  var pickedFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageName = pickedFile.name;
        print('Image name: $imageName');
      });
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      imageName = '';
    });
  }

  Future<void> _uploadImage(XFile pickedFile) async {
    final file = File(pickedFile.path);

    final request = http.MultipartRequest(
        'POST', Uri.parse('http://your-api-url/upload-profile-image'));

    final multipartFile =
        await http.MultipartFile.fromPath('profileImage', file.path);
    request.files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully!');
    } else {
      print('Error uploading image: ${response.statusCode}');
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        imageName.isEmpty) {
      if (imageName.isEmpty) {
        popupMessage(context, "Alert", "Please select an image");
      } else {
        popupMessage(context, "Alert", "Please fill up all fields!");
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final profileData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'profileImage': imageName,
    };

    final response = await http.post(
      Uri.parse('http://your-api-url/save-profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profileData),
    );

    if (response.statusCode == 201) {
      if (pickedFile != null) {
        await _uploadImage(pickedFile);
      }
      popupMessage(context, "Success", "Profile updated successfully!");
    } else {
      print('Error saving profile: ${response.statusCode}');
      popupMessage(context, "Error", "Error saving profile!");
    }
  }

  void popupMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.grey.shade900,
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 50,
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLoading = true;
                        });
                        _saveProfile(context).then((_) {
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isLoading ? Colors.grey.shade300 : Colors.orange,
                  foregroundColor: _isLoading ? Colors.white70 : Colors.white,
                  textStyle: _isLoading
                      ? const TextStyle(fontWeight: FontWeight.w300)
                      : const TextStyle(fontWeight: FontWeight.normal),
                ),
                child:
                    Text('Save Profile', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
