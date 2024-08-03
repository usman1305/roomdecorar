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
    List<String> roomDims = widget.dimensions!.split('x');
    totalHeight = double.parse(roomDims[0]);
    totalWidth = double.parse(roomDims[1]);
  }

  Future<void> _fetchItems() async {
    final snapshot = await FirebaseFirestore.instance.collection('models').get();
    final fetchedItems = snapshot.docs.map((doc) => Item.fromDocument(doc)).toList();
    setState(() {
      items = fetchedItems;

      // Initialize item counters from initialItems
      if (widget.initialItems != null) {
        for (var item in items) {
          if (widget.initialItems!.containsKey(item)) {
            item.counter = widget.initialItems![item]!;
          } else {
            item.counter = 0;
          }
        }
      }
    });
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
        title: Text(
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
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  textColor: Colors.white,
                  leading: Image.network(items[index].imageUrl),
                  title: Text(items[index].name),
                  subtitle: Text(items[index].category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          _decrementCounter(index);
                          double itemHeight = double.parse(items[index].height);
                          double itemWidth = double.parse(items[index].width);

                          if (itemHeight != -1 && itemWidth != -1) {
                            totalHeight += itemHeight;
                            totalWidth += itemWidth;
                          }
                          if (totalWidth >= 0 && totalHeight >= 0) {
                            isDisabled = false;
                          }
                        },
                      ),
                      Text('${items[index].counter}'),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          double itemHeight = double.parse(items[index].height);
                          double itemWidth = double.parse(items[index].width);

                          if (_canAddItem(itemHeight, itemWidth)) {
                            _incrementCounter(index);
                            if (itemHeight != -1 && itemWidth != -1) {
                              totalHeight -= itemHeight;
                              totalWidth -= itemWidth;
                            }

                            if (totalWidth < 0 || totalHeight < 0) {
                              isDisabled = true;
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
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
                    for (int i = 0; i < items.length; i++) {
                      if (items[i].counter > 0) {
                        Global.cart[items[i]] = items[i].counter;
                      }
                    }
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
                    'Update 3D Objects',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text('The room dimensions are ${widget.dimensions}', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
