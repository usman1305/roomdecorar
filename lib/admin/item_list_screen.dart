import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roomdecorar/Global.dart';
import '../model/item.dart';

class ItemListScreen extends StatefulWidget {
  final String? dimensions;
  final Map<Item, int>? initialItems;

  ItemListScreen({Key? key, required this.dimensions, this.initialItems})
      : super(key: key);

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<Item> items = [];
  double totalHeight = 0.0;
  double totalWidth = 0.0;
  bool isDisabled = false;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _parseRoomDimensions();
  }

  void _parseRoomDimensions() {
    if (widget.dimensions != null && widget.dimensions!.contains('x')) {
      List<String> roomDims = widget.dimensions!.split('x');
      if (roomDims.length == 2) {
        totalHeight = double.tryParse(roomDims[0]) ?? 0.0;
        totalWidth = double.tryParse(roomDims[1]) ?? 0.0;
      }
    }
  }

  Future<void> _fetchItems() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('models').get();

      if (snapshot.docs.isEmpty) {
        print('No items found in Firestore.');
        setState(() {
          items = [];
        });
      } else {
        final fetchedItems = snapshot.docs.map((doc) {
          try {
            Item item = Item.fromDocument(doc);

            // Check if item is a Ceiling Design
            if (item.category == 'Ceiling Designs') {
              // Only include if ceiling design matches selected dimensions
              if (widget.dimensions != null && item.name.contains(widget.dimensions!)) {
                return item;
              } else {
                return null; // Exclude this item
              }
            } else {
              // For other items, check height and width against room dimensions
              double itemHeight = double.tryParse(item.height) ?? 0.0;
              double itemWidth = double.tryParse(item.width) ?? 0.0;
              List<String> roomDims = widget.dimensions!.split('x');
              double roomHeight = double.tryParse(roomDims[0]) ?? 0.0;
              double roomWidth = double.tryParse(roomDims[1]) ?? 0.0;

              // Include the item if it fits within room dimensions
              if (itemHeight <= roomHeight && itemWidth <= roomWidth) {
                return item;
              } else {
                return null; // Exclude this item
              }
            }
          } catch (e) {
            print('Error parsing item from document: ${doc.id}, error: $e');
            return null;
          }
        }).where((item) => item != null).toList();

        setState(() {
          items = fetchedItems.cast<Item>();
        });
      }
    } catch (e) {
      print('Error fetching items from Firestore: $e');
      setState(() {
        items = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }



  void _incrementCounter(int index) {
    setState(() {
      items[index].counter++;
      _updateGlobalCart();
    });
  }

  void _decrementCounter(int index) {
    setState(() {
      if (items[index].counter > 0) {
        items[index].counter--;
        _updateGlobalCart();
      }
    });
  }

  bool _canAddItem(double itemHeight, double itemWidth) {
    return totalHeight >= itemHeight && totalWidth >= itemWidth;
  }

  void _updateGlobalCart() {
    Global.cart.clear();
    for (var item in items) {
      if (item.counter > 0) {
        Global.cart[item] = item.counter;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Objects',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final itemHeight = double.tryParse(item.height) ?? 0.0;
                final itemWidth = double.tryParse(item.width) ?? 0.0;

                return ListTile(
                  textColor: Colors.white,
                  leading: Image.network(item.imageUrl),
                  title: Text(item.name),
                  subtitle: Text(item.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          _decrementCounter(index);
                          _adjustRoomDimensions(itemHeight, itemWidth, add: true);
                        },
                      ),
                      Text('${item.counter}'),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          if (_canAddItem(itemHeight, itemWidth)) {
                            _incrementCounter(index);
                            _adjustRoomDimensions(itemHeight, itemWidth, add: false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item exceeds room dimensions'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                isDisabled
                    ? Container()
                    : ElevatedButton(
                  onPressed: () {
                    _updateGlobalCart();
                    Navigator.of(context).pop("value");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Add 3D Objects',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The room dimensions are ${widget.dimensions}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _adjustRoomDimensions(double itemHeight, double itemWidth, {required bool add}) {
    setState(() {
      if (add) {
        totalHeight += itemHeight;
        totalWidth += itemWidth;
      } else {
        totalHeight -= itemHeight;
        totalWidth -= itemWidth;
      }
      isDisabled = totalWidth < 0 || totalHeight < 0;
    });
  }
}
