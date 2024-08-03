import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roomdecorar/Global.dart';
import 'package:roomdecorar/model/item.dart';
import 'package:roomdecorar/model/sugesstions.dart';


class Customersuggestionsscreen extends StatefulWidget {
  const Customersuggestionsscreen({super.key});

  @override
  State<Customersuggestionsscreen> createState() => _ViewSuggestionState();
}

class _ViewSuggestionState extends State<Customersuggestionsscreen> {
  List<Sugesstions> fetchedItems = [];

  Future<void> _fetchData() async {
    final snapshot = await FirebaseFirestore.instance.collection('suggestions').get();
    final fetchedItems = snapshot.docs.map((doc) => Sugesstions.fromDocument(doc)).toList();
    setState(() {
      this.fetchedItems = fetchedItems;
      print('fetchedItems ${fetchedItems.length}');
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Suggestion Set',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Expanded(
                  child: fetchedItems.isEmpty
                      ? Center(
                    child: Text('No suggestions available', style: TextStyle(color: Colors.white)),
                  )
                      : ListView.builder(
                    itemCount: fetchedItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 33, 33, 33),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fetchedItems[index].name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              fetchedItems[index].desc,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {

                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(const Color.fromARGB(255, 119, 119, 119)),
                                  ),
                                  child: const Text(
                                    'View',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {

                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(const Color.fromARGB(255, 119, 119, 119)),
                                  ),
                                  child: const Text(
                                    'AR View',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
}
