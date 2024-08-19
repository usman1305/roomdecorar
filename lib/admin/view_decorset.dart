import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roomdecorar/model/decorset.dart';
import 'package:roomdecorar/admin/add_decorset.dart';
import '../ar_measure.dart';
import 'package:roomdecorar/Multiple3dObjectPlacement/decorSetMultiplePlacementAR.dart';

class ViewDecorSet extends StatefulWidget {
  const ViewDecorSet({super.key});

  @override
  State<ViewDecorSet> createState() => _ViewDecorSetState();
}

class _ViewDecorSetState extends State<ViewDecorSet> {
  List<DecorSet> fetchedItems = [];

  Future<void> _fetchData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('decor_sets').get();
      final fetchedItems = snapshot.docs.map((doc) => DecorSet.fromDocument(doc)).toList();
      setState(() {
        this.fetchedItems = fetchedItems;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _showMeasurementChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Measurement Method'),
          content: const Text('Would you like to add dimensions manually or use AR?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddDecorSet(
                      id: '',
                      name: '',
                      desc: '',
                      distances: [], // Pass an empty list or provide default distances
                    ),
                  ),
                ).then((_) {
                  _fetchData();
                });
              },
              child: const Text('Manual'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ARMeasurePage()),
                );
              },
              child: const Text('AR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(String docId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this decor set?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await FirebaseFirestore.instance
                      .collection('decor_sets')
                      .doc(docId)
                      .delete();

                  // Use post-frame callback to ensure ScaffoldMessenger is properly initialized
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Decor Set deleted successfully'),
                      ),
                    );
                  });

                  _fetchData(); // Refresh the data after deletion
                } catch (e) {
                  // Use post-frame callback to ensure ScaffoldMessenger is properly initialized
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Decor Set',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Expanded(
                  child: fetchedItems.isEmpty
                      ? const Center(
                    child: Text(
                      'No decor sets available',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : ListView.builder(
                    itemCount: fetchedItems.length,
                    itemBuilder: (context, index) {
                      final item = fetchedItems[index];
                      return GestureDetector(
                        onLongPress: () => _showDeleteConfirmationDialog(item.id),
                        child: Container(
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
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Dimensions: ${item.dimension}', // Displaying dimensions
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddDecorSet(
                                            id: item.id,
                                            name: item.name,
                                            desc: item.description,
                                            distances: [], // Pass an empty list or provide default distances
                                          ),
                                        ),
                                      ).then((_) {
                                        _fetchData();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 119, 119, 119),
                                    ),
                                    child: const Text(
                                      'Update Set',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Multiple3DItemPlacement(
                                            decorSet: fetchedItems[index], // Pass the suggestionSet object
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 119, 119, 119),
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 70,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _showMeasurementChoiceDialog(context),
              child: const Icon(Icons.add),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
