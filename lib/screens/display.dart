import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:daily_grace_devotional/screens/dialog.dart';
import 'dart:convert';
import '../env.dart';
import 'package:daily_grace_devotional/models/devotion-model.dart';
import 'package:daily_grace_devotional/functions/get-all.dart';
import 'package:url_launcher/url_launcher.dart';

class Display extends StatefulWidget {
  final String? id;
  final String? selectedDate;
  Display({Key? key, this.id, this.selectedDate}) : super(key: key);

  @override
  _DisplayState createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  late Future<Devotion> futureDevotion;
  List<Devotion> devotions = []; // List to hold all devotions
  var formattedDate;
  bool couldntFindDevotion = false;

  // Convert date to the right format to send to the database.
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Fetch a single devotion from the backend by ID
  Future<Devotion> fetchDevotionById(String id) async {
    final response = await http.get(
        Uri.parse('${EnvironmentVariables.apiUrl}/get-single-devotion?id=$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Devotion.fromJson(data);
    } else if (response.statusCode == 404) {
      popupMessage(context, 'Hi', 'Devotion not found${response.body}');
      throw Exception('Devotion not found${response.body}');
    } else {
      popupMessage(
          context, 'Hi', 'Internal server error. Failed to load devotion');
      throw Exception('Internal server error. Failed to load devotion');
    }
  }

  // Fetch a single devotion from the backend by date
  Future<Devotion> fetchDevotionByDate(
      BuildContext context, String dateString) async {
    try {
      print("Formatted Date: ${dateString}");

      if (formattedDate != null) {
        final response = await http.get(Uri.parse(
            '${EnvironmentVariables.apiUrl}/get-devotion-by-date?date=$dateString'));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          return Devotion.fromJson(data);
        } else if (response.statusCode == 404) {
          popupMessage(
              context, "Error", "Sorry! There's no devotion available today");
          couldntFindDevotion = true;
          throw Exception('Sorry! There\'s no devotion available today');
        } else {
          popupMessage(context, "Error", "Internal Server error");
          throw Exception('Internal server error');
        }
      } else {
        // Handle the case where date parsing fails (shouldn't reach here)
        throw Exception('Unexpected error: Failed to parse date.');
      }
    } catch (e) {
      print('Error parsing date string: $e');
      throw Exception('Invalid date format. Please use YYYY-MM-DD format.');
    }
  }

  // Fetch a single devotion from the backend by today's date if ID is empty
  Future<Devotion> fetchDevotionByToday() async {
    final today = DateTime.now();
    formattedDate = await _formatDate(today); // Formats to Jun 1, 2024
    return fetchDevotionByDate(context, formattedDate);
  }

  Future<void> loadDevotions() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    try {
      final fetchedDevotions = await getAllDevotions(context);
      setState(() {
        devotions = fetchedDevotions; // Update the state with fetched devotions
      });
    } catch (error) {
      print('Error fetching devotions: $error');
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureDevotion = _fetchDevotion();
    loadDevotions();
  }

  Future<Devotion> _fetchDevotion() async {
    if (widget.id != null && widget.id!.isNotEmpty) {
      // Fetch devotion by ID if provided
      return fetchDevotionById(widget.id!);
    } else if (widget.selectedDate != null) {
      // Fetch devotion by date from routing if provided
      return fetchDevotionByDate(context, widget.selectedDate!);
    } else {
      // Fetch devotion by today's date if no ID or date provided
      return fetchDevotionByToday();
    }
  }

  Future<void> _launchYouTube(String url) async {
    final Uri youtubeAppUri =
        Uri.parse('vnd.youtube://www.youtube.com/watch?v=$url');
    final Uri youtubeWebUri = Uri.parse('https://www.youtube.com/watch?v=$url');

    if (await canLaunchUrl(youtubeAppUri)) {
      // YouTube app is installed, launch the app
      await launchUrl(youtubeAppUri);
    } else if (await canLaunchUrl(youtubeWebUri)) {
      // YouTube app is not installed, launch the URL in a browser
      await launchUrl(youtubeWebUri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Set the preferred height
        child: AppBar(
          automaticallyImplyLeading:
              false, // Ensure the leading widget remains at the left
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF663399), // Deep Violet
                  Color(0xFF9966CC), // Medium Violet
                  Color(0xFFF07BFF), // Light Pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Text('Welcome',
                        style: TextStyle(color: Colors.white, fontSize: 20.0)),
                  ],
                ),
              ),
            ),
          ),
          elevation: 0, // Remove elevation to make it flat
          backgroundColor:
              Colors.transparent, // Make the background transparent
        ),
      ),
      body: FutureBuilder<Devotion>(
        future: futureDevotion,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());

            // } else if (snapshot.hasError) {
            //   return Center(
            //       child: Text('Error: ${snapshot.error}',
            //           style: TextStyle(color: Colors.white)));
          } else if (couldntFindDevotion || snapshot.data == null) {
            return Center(
                child: Text("Sorry! There's no devotion available today",
                    style: TextStyle(color: Colors.white)));
          } else {
            final devotion = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => _launchYouTube(devotion.youtubeLink),
                    child: Container(
                      height: 250,
                      margin: EdgeInsets.only(top: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            child: Image.asset(
                              'assets/thumbnails/${devotion.thumbnail!}',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.9),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 100, // Adjust the width as needed
                              height: 60, // Adjust the height as needed
                              decoration: BoxDecoration(
                                color: Color(0xFFE53935), // YouTube red color
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40, // Adjust the icon size as needed
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          devotion.topic,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          devotion.selectedDate != null
                              ? DateFormat('EEE, MMM d, yyyy').format(
                                  DateTime.parse(devotion.selectedDate!))
                              : '',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                devotion.description,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recommended Devotions',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                  height:
                                      5), // Adjust the height between text and line as needed
                              Container(
                                height: 1,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey, // Color of the line
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey
                                          .withOpacity(0.5), // Shadow color
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 2), // Shadow position
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 170, // Adjust the height as needed
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: devotions.length,
                            itemBuilder: (context, index) {
                              final devotion = devotions[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Display(id: devotion.id),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 200,
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 30),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          "assets/thumbnails/${devotion.thumbnail}" ??
                                              '',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.black
                                              .withOpacity(0.5), // Dark overlay
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                devotion.topic,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      12, // Adjust the font size as needed
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                DateFormat('MMM d, yyyy')
                                                    .format(
                                                  DateTime.parse(
                                                      devotion.selectedDate!),
                                                ),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10, // Adjust the font size as needed
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
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
