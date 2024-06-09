import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:daily_grace_devotional/screens/dialog.dart';
import '../env.dart';
import 'package:http/http.dart' as http;
import 'package:daily_grace_devotional/models/devotion-model.dart'; // Import your Devotion model

List<Devotion> devotions = [];
List filteredDevotions = [];
bool isLoading = false;

Future<List<Devotion>> getAllDevotions(BuildContext context) async {
  final url = Uri.parse('${EnvironmentVariables.apiUrl}/get-all-devotions');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      devotions = data.map((item) => Devotion.fromJson(item)).toList();
      return devotions;
    } else if (response.statusCode == 500) {
      popupMessage(
          context, 'Hi', 'Internal server error. Error fetching devotions');
      return []; // Return empty list on error
    } else {
      // Handle error (e.g., print message, throw exception)
      print('Error fetching devotions: ${response.statusCode}');
      popupMessage(
          context, 'Hi', 'Error fetching devotions: ${response.statusCode}');
      return []; // Return empty list on error
    }
  } catch (error) {
    // Handle network or other errors
    popupMessage(context, "Hi", "Error fetching devotions!");
    print('Error fetching devotions: $error');
    return []; // Return empty list on error
  }
}
