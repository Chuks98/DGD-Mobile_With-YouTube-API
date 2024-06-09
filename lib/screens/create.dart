import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../env.dart';
import '../models/devotion-model.dart';
import "./dialog.dart";
import 'package:intl/intl.dart'; // Import the intl package

class NewDevotionScreen extends StatefulWidget {
  @override
  _NewDevotionScreenState createState() => _NewDevotionScreenState();
}

class _NewDevotionScreenState extends State<NewDevotionScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();
  File? _image;
  DateTime _selectedDate = DateTime.now();

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  bool _isLoading = false;
  late String imageName = '';
  var pickedFile;
  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        // Extract the image name from the path
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

  Future<void> _uploadThumbnail(XFile pickedFile) async {
    final file = File(pickedFile.path);

    // Create a multipart request
    final request = await http.MultipartRequest(
        'POST', Uri.parse('${EnvironmentVariables.apiUrl}/upload-thumbnail'));

    // Await the Future and extract the MultipartFile
    final multipartFile =
        await http.MultipartFile.fromPath('thumbnail', file.path);
    request.files.add(multipartFile);

    // Send the request to your backend
    final response = await request.send();

    // Handle response
    if (response.statusCode == 200) {
      print('Devotion saved successfully!');
      popupMessage(context, "Hi", "Devotion saved successfully!");
    } else {
      print('Error uploading image: ${response.statusCode}');
      popupMessage(context, "Hi",
          "Devotion saved successfully but thumbnail not uploaded!");
    }
  }

  // Create a Devotion object to hold data
  Devotion? _devotion;
  void _saveDevotion() async {
    if (_topicController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        imageName.isEmpty ||
        _youtubeLinkController.text.isEmpty) {
      if (imageName.isEmpty) {
        popupMessage(context, "Hi", "Please select an image");
        setState(() {
          _isLoading = false;
        });
        return;
      }
      popupMessage(context, "Hi", "Please fill up all fields!");
      return;
    }

    // Create a Devotion object from form data
    _devotion = Devotion(
      topic: _topicController.text,
      description: _descriptionController.text,
      youtubeLink: _youtubeLinkController.text,
      thumbnail: imageName,
      selectedDate: _formatDate(_selectedDate),
    );

    final response = await http.post(
      Uri.parse('${EnvironmentVariables.apiUrl}/create-devotion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_devotion),
    );

    if (response.statusCode == 201) {
      _uploadThumbnail(pickedFile);
    } else if (response.statusCode == 302) {
      popupMessage(context, "Duplicate",
          "Devotion already exists. Change the topic and try again.");
      setState(() {
        _isLoading = false;
      });
    } else if (response.statusCode == 501) {
      popupMessage(context, "Error", "internal server error!");
      setState(() {
        _isLoading = false;
      });
    } else {
      // Handle error (e.g., show error message)
      print('Error saving devotion: ${response.statusCode}');
      popupMessage(context, "Error", "Error saving devotion!");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Create New Devotion', style: TextStyle(color: Colors.white)),
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
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: 'Enter Topic',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Enter Description',
                labelStyle: TextStyle(color: Colors.white),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 30.0),
            Row(
              children: [
                SizedBox(
                  width: 200, // Set the width as per your requirement
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: _uploadImage,
                    child: Text('Select Thumbnail',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 10),
                if (_image != null)
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: _clearImage,
                  ),
                Expanded(
                  child: _image != null
                      ? Container(
                          height: 200,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
            SizedBox(height: 30.0),
            ListTile(
              title: Text('Select Date', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                _formatDate(_selectedDate), // Use the formatted date
                style: TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _youtubeLinkController,
              decoration: InputDecoration(
                labelText: 'Enter YouTube Id',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveDevotion,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isLoading ? Colors.grey.shade300 : Colors.orange,
                  foregroundColor: _isLoading ? Colors.white70 : Colors.white,
                  textStyle: _isLoading
                      ? const TextStyle(fontWeight: FontWeight.w300)
                      : const TextStyle(fontWeight: FontWeight.normal),
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
