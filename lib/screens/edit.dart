import 'package:flutter/material.dart';
import 'package:daily_grace_devotional/models/devotion-model.dart';

import '../models/note-model.dart';

class EditScreen extends StatefulWidget {
  final String? id;
  const EditScreen({super.key, required this.id});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    if (widget.id != null) {
      _idController = TextEditingController(text: widget.id);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.all(0),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(.8),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ))
            ],
          ),
          Expanded(
              child: ListView(
            children: [
              TextField(
                controller: _idController,
                style: const TextStyle(color: Colors.white, fontSize: 30),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 30)),
              ),
              // TextField(
              //   controller: _contentController,
              //   style: const TextStyle(
              //     color: Colors.white,
              //   ),
              //   maxLines: null,
              //   decoration: const InputDecoration(
              //       border: InputBorder.none,
              //       hintText: 'Type something here',
              //       hintStyle: TextStyle(
              //         color: Colors.grey,
              //       )),
              // ),
            ],
          ))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, [_idController.text]);
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade800,
        child: const Icon(Icons.save),
      ),
    );
  }
}
