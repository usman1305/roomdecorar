import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roomdecorar/Global.dart';
import 'package:roomdecorar/model/item.dart';
import '../model/sugesstions.dart';
import 'add_suggestion.dart';

class ViewSuggestion extends StatefulWidget {
  const ViewSuggestion({super.key});

  @override
  State<ViewSuggestion> createState() => _ViewSuggestionState();
}

class _ViewSuggestionState extends State<ViewSuggestion> {
  List<Sugesstions> fetchedItems = [];

  Future<void> _fetchData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('suggestions').get();
    final fetchedItems =
        snapshot.docs.map((doc) => Sugesstions.fromDocument(doc)).toList();
    setState(() {
      this.fetchedItems = fetchedItems;
      print('fetchedItems ${fetchedItems.length}');
    });
  }

  Future<void> _fetchAndPrintModelDetails(String items) async {
    List<String> itemIds = items.split(',');
    for (String itemId in itemIds) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('models')
          .doc(itemId)
          .get();
      if (doc.exists) {
        Item item = Item.fromDocument(doc);
        print('Model ID: ${item.id}');
        print('Model Name: ${item.name}');
        print('Model Category: ${item.category}');
        print('Model Height: ${item.height}');
        print('Model Width: ${item.width}');
        print('Model Image URL: ${item.imageUrl}');
        print('Counter: ${item.counter}');
        print('-----------------------------');
      } else {
        print('No such document with ID: $itemId');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Suggestion Set',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Expanded(
                  child: fetchedItems.isEmpty
                      ? Center(
                          child: Text('No suggestions available',
                              style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                          itemCount: fetchedItems.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 14),
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
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('suggestions')
                                              .doc(fetchedItems[index].id)
                                              .delete()
                                              .then((_) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Suggestion deleted successfully'),
                                              ),
                                            );
                                            _fetchData();
                                          }).catchError((e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(e.toString()),
                                              ),
                                            );
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  const Color.fromARGB(
                                                      255, 119, 119, 119)),
                                        ),
                                        child: const Text(
                                          'Delete Set',
                                          style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddSuggestion(
                                                id: fetchedItems[index].id,
                                                name: fetchedItems[index].name,
                                                desc: fetchedItems[index].desc,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  const Color.fromARGB(
                                                      255, 119, 119, 119)),
                                        ),
                                        child: const Text(
                                          'Update Set',
                                          style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
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
          Positioned(
            bottom:
                70, // Adjust this value to position the button higher or lower
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                Global.cart.clear();
                String value = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSuggestion(
                      id: '',
                      name: '',
                      desc: '',
                    ),
                  ),
                );
                setState(() {
                  _fetchData();
                });
              },
              child: const Icon(Icons.add),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
