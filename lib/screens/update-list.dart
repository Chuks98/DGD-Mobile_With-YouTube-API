import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/constants/colors.dart';
import 'package:note_app/models/devotion.dart'; // Import your Devotion model
import 'package:note_app/screens/edit.dart';

class UpdateList extends StatefulWidget {
  const UpdateList({Key? key}) : super(key: key);

  @override
  State<UpdateList> createState() => _UpdateListState();
}

class _UpdateListState extends State<UpdateList> {
  List<Devotion> filteredDevotions = [];
  bool sorted = false;

  @override
  void initState() {
    super.initState();
    filteredDevotions = sampleNotes;
  }

  List<Devotion> sortDevotionsByModifiedTime(List<Devotion> devotions) {
    if (sorted) {
      devotions.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      devotions.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    }

    sorted = !sorted;

    return devotions;
  }

  // getRandomColor() {
  //   Random random = Random();
  //   return backgroundColors[random.nextInt(backgroundColors.length)];
  // }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredDevotions = sampleNotes
          .where((devotion) =>
              devotion.description.toLowerCase().contains(searchText.toLowerCase()) ||
              devotion.topic.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void deleteDevotion(int index) {
    setState(() {
      Devotion devotion = filteredDevotions[index];
      sampleNotes.remove(devotion);
      filteredDevotions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
      ),
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        filteredDevotions = sortDevotionsByModifiedTime(filteredDevotions);
                      });
                    },
                    padding: const EdgeInsets.all(0),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(.8),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.sort,
                        color: Colors.white,
                      ),
                    ))
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: onSearchTextChanged,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "Search by topic...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                fillColor: Colors.grey.shade800,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 30),
                itemCount: filteredDevotions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    color: const Color(0xFFFFFFFF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  EditScreen(devotion: filteredDevotions[index]),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              int originalIndex = sampleNotes.indexOf(filteredDevotions[index]);

                              sampleNotes[originalIndex] = Devotion(
                                id: sampleNotes[originalIndex].id,
                                topic: result[0],
                                description: result[1],
                                modifiedTime: DateTime.now(), 
                                thumbnail: ''
                              );

                              filteredDevotions[index] = Devotion(
                                id: filteredDevotions[index].id,
                                topic: result[0],
                                description: result[1],
                                modifiedTime: DateTime.now(), 
                                thumbnail: ''
                              );
                            });
                          }
                        },
                        leading: Container(
                          width: 80,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            filteredDevotions[index].thumbnail, // Use the thumbnail from the Devotion model
                            fit: BoxFit.cover, // Adjust the fit as per your requirement
                          ),
                        ),
                        title: Text(
                          filteredDevotions[index].topic,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEE MMM d, yyyy h:mm a').format(filteredDevotions[index].modifiedTime),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade800),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(
                                  ' (${filteredDevotions[index].reviews})',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            final result = await confirmDialog(context);
                            if (result != null && result) {
                              deleteDevotion(index);
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const EditScreen(),
            ),
          );

          if (result != null) {
            setState(() {
              sampleNotes.add(Devotion(
                  id: sampleNotes.length,
                  topic: result[0],
                  description: result[1],
                  modifiedTime: DateTime.now(), thumbnail: ''));
              filteredDevotions = sampleNotes;
            });
          }
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade800,
        child: const Icon(
          Icons.add,
          size: 38,
        ),
      ),
    );
  }

  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade900,
            icon: const Icon(
              Icons.info,
              color: Colors.grey,
            ),
            title: const Text(
              'Are you sure you want to delete?',
              style: TextStyle(color: Colors.white),
            ),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'Yes',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'No',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ]),
          );
        });
  }
}
