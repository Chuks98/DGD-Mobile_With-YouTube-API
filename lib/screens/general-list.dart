import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_grace_devotional/screens/create.dart';
import 'package:daily_grace_devotional/screens/display.dart';
import 'package:daily_grace_devotional/functions/get-all.dart';

class GeneralList extends StatefulWidget {
  const GeneralList({Key? key}) : super(key: key);

  @override
  State<GeneralList> createState() => _GeneralListState();
}

class _GeneralListState extends State<GeneralList> {
  bool sorted = false;
  bool isLoading = false;
  List<dynamic> devotions = [];
  List<dynamic> filteredDevotions = [];
  DateTime? selectedDate;
  final TextEditingController _dateController = TextEditingController();

  String _formatDate(String dateString) {
    final parsedDate = DateTime.parse(dateString);
    return DateFormat('EEE MMM d, yyyy').format(parsedDate);
  }

  @override
  void initState() {
    super.initState();
    loadDevotions();
    _dateController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _dateController.removeListener(_onSearchChanged);
    _dateController.dispose();
    super.dispose();
  }

  Future<void> loadDevotions() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    try {
      final fetchedDevotions = await getAllDevotions(context);
      setState(() {
        devotions = fetchedDevotions; // Update the state with fetched devotions
        filteredDevotions =
            devotions; // Initialize filteredDevotions with all devotions
      });
    } catch (error) {
      print('Error fetching devotions: $error');
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false
      });
    }
  }

  void _filterDevotions(DateTime date) {
    setState(() {
      selectedDate = date;
      filteredDevotions = devotions.where((devotion) {
        return DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(devotion.selectedDate!)) ==
            DateFormat('yyyy-MM-dd').format(date);
      }).toList();
    });
  }

  void _onSearchChanged() {
    if (_dateController.text.isEmpty) {
      setState(() {
        filteredDevotions = devotions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('General List',
            style: TextStyle(color: Colors.white, fontSize: 15)),
        backgroundColor: Colors.grey.shade900,
      ),
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 16, 0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _filterDevotions(date);
                  _dateController.text = _formatDate(date.toIso8601String());
                }
              },
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "Search by date...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.calendar_today,
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
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(), // Show loading spinner
                    )
                  : filteredDevotions.isEmpty
                      ? Center(
                          child: Text(
                            'No match found',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 30),
                          itemCount: filteredDevotions.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              color: Color.fromRGBO(128, 128, 128, 0.5),
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
                                        builder: (context) => Display(
                                            id: filteredDevotions[index].id),
                                      ),
                                    );
                                  },
                                  leading: Container(
                                    width: 80,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.asset(
                                      'assets/thumbnails/${filteredDevotions[index].thumbnail}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    filteredDevotions[index].topic,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDate(filteredDevotions[index]
                                            .selectedDate!),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 16),
                                          Text(
                                            ' (${filteredDevotions[index].reviews})',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
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
    );
  }
}
