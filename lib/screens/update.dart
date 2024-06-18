import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../env.dart';
import '../models/devotion-model.dart';
import "./dialog.dart";

class Update extends StatefulWidget {
  final String? id;
  Update({Key? key, this.id}) : super(key: key);

  @override
  _UpdateState createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();
  File? _image;
  DateTime _selectedDate = DateTime.now();
  String imageName = '';
  bool _isLoading = false;
  Devotion? _devotion;

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    _fetchDevotion(widget.id!);
  }

  void _fetchDevotion(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          '${EnvironmentVariables.apiUrl}/get-single-devotion?id=$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _devotion = Devotion.fromJson(data);

        setState(() {
          _topicController.text = _devotion!.topic;
          _descriptionController.text = _devotion!.description;
          _youtubeLinkController.text = _devotion!.youtubeLink;
          _selectedDate = DateTime.parse(_devotion!.selectedDate!);
          imageName = _devotion!.thumbnail!;

          // Check if the file exists and update the image
          final imagePath = 'assets/thumbnails/$imageName';
          final file = File(imagePath);
          if (file.existsSync()) {
            _image = file;
          }

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load devotion');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching devotion: $error');
      popupMessage(context, "Error", "Error fetching devotion data!");
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageName = pickedFile.name;
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

    final request = await http.MultipartRequest(
        'POST', Uri.parse('${EnvironmentVariables.apiUrl}/upload-thumbnail'));

    final multipartFile =
        await http.MultipartFile.fromPath('thumbnail', file.path);
    request.files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Thumbnail uploaded successfully!');
    } else {
      print('Error uploading image: ${response.statusCode}');
    }
  }

  Future<void> _updateDevotion() async {
    if (_topicController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        imageName.isEmpty ||
        _youtubeLinkController.text.isEmpty) {
      popupMessage(context, "Alert", "Please fill up all fields!");
      return;
    }

    final updatedDevotion = Devotion(
      id: widget.id,
      topic: _topicController.text,
      description: _descriptionController.text,
      youtubeLink: _youtubeLinkController.text,
      thumbnail: imageName,
      selectedDate: _formatDate(_selectedDate),
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.patch(
        Uri.parse(
            '${EnvironmentVariables.apiUrl}/update-single-devotion?id=${widget.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedDevotion),
      );

      if (response.statusCode == 200) {
        if (_image != null) {
          _uploadThumbnail(XFile(_image!.path));
        }
        popupMessage(context, "Success", "Devotion updated successfully!");
      } else if (response.statusCode == 404) {
        popupMessage(context, "Error", "Devotion not found!");
      } else {
        popupMessage(context, "Error", "Failed to update devotion!");
      }
    } catch (error) {
      print('Error updating devotion: $error');
      popupMessage(context, "Error", "Error updating devotion!");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Devotion',
            style: TextStyle(color: Colors.white, fontSize: 20)),
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
                  width: 200,
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
                      : imageName.isNotEmpty
                          ? Container(
                              height: 200,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/thumbnails/$imageName'),
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
                _formatDate(_selectedDate),
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
                onPressed: _isLoading ? null : _updateDevotion,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isLoading ? Colors.grey.shade300 : Colors.orange,
                  foregroundColor: _isLoading ? Colors.white70 : Colors.white,
                  textStyle: _isLoading
                      ? const TextStyle(fontWeight: FontWeight.w300)
                      : const TextStyle(fontWeight: FontWeight.normal),
                ),
                child: Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
