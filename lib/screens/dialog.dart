import 'package:flutter/material.dart';

Future<void> popupMessage(BuildContext context, String title, String message) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.orange,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey.shade900, // Grey background color
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, // Orange background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Rounded corners
              ),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                color: Colors.white, // White text color
              ),
            ),
          ),
        ],
      );
    },
  );
}
