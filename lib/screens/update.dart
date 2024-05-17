import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Import the intl package

class UpdateDevotion extends StatefulWidget {
  @override
  _UpdateDevotionState createState() => _UpdateDevotionState();
}

class _UpdateDevotionState extends State<UpdateDevotion> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();
  File? _image;
  DateTime _selectedDate = DateTime.now();

  String _formatDate(DateTime date) {
    // Format the date using the desired format
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Devotion', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: Text('Select Thumbnail'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _image != null
                      ? Container(
                          height: 100,
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
                labelText: 'Enter YouTube Link',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Implement logic to save the devotion
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
