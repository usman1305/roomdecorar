import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roomdecorar/Global.dart';
import '../model/item.dart';
import 'item_list_screen.dart';

class AddDecorSet extends StatefulWidget {
  final String id;
  final String name;
  final String desc;
  final List<double> distances;

  AddDecorSet({
    Key? key,
    required this.id,
    required this.name,
    required this.desc,
    required this.distances,
  }) : super(key: key);

  @override
  State<AddDecorSet> createState() => _AddDecorSetState();
}

class _AddDecorSetState extends State<AddDecorSet> {
  List<String> dimension = ['10x10', '15x15', '10x15', '20x20'];
  String? selectedType;
  final _formKey = GlobalKey<FormState>();
  TextEditingController objectName = TextEditingController();
  TextEditingController description = TextEditingController();
  String btn = 'Create';

  @override
  void initState() {
    super.initState();
    if (widget.id.isNotEmpty) {
      btn = 'Update';
      _fetchData();
    }

    // Use distances here if provided
    if (widget.distances.isNotEmpty) {
      // Generate dimension from distances, assuming distances are [width, height]
      String dimensionFromDistances = '${widget.distances[0].toStringAsFixed(2)}x${widget.distances[1].toStringAsFixed(2)}';
      if (!dimension.contains(dimensionFromDistances)) {
        dimension.add(dimensionFromDistances);
      }
      selectedType = dimensionFromDistances;
    }
    print('Received distances: ${widget.distances}');
  }

  Future<void> _fetchData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('decor_sets')
        .doc(widget.id)
        .get();
    final fetchedItems = snapshot.data();
    setState(() {
      objectName.text = fetchedItems!['name'];
      description.text = fetchedItems['description'];
      selectedType = fetchedItems['dimension'];
      List<String> itemIds = fetchedItems['items'].split(',');
      itemIds.forEach((element) {
        FirebaseFirestore.instance
            .collection('models')
            .doc(element)
            .get()
            .then((value) {
          Global.cart[Item.fromDocument(value)] = int.parse(fetchedItems[element] ?? '1');
          setState(() {});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Global.cart.clear();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Decor Set',
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Room Dimension',
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AbsorbPointer(
                    absorbing: widget.id.isNotEmpty, // Absorb input if updating
                    child: DropdownButtonFormField<String>(
                      dropdownColor: Colors.black,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      hint: const Text(
                        'Select Room Dimension',
                        style: TextStyle(color: Colors.white38),
                      ),
                      value: selectedType,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: dimension.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        // Allow changing value only if not updating
                        if (widget.id.isEmpty) {
                          setState(() {
                            selectedType = value;
                          });
                        }
                      },
                      validator: (value) =>
                      value == null ? 'Please select room dimension' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: objectName,
                  style: const TextStyle(color: Colors.white70),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Decor Set Name',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter decor set name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: description,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white70),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Description',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter description' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Add ',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    InkWell(
                      onTap: () async {
                        if (selectedType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select room dimension'),
                            ),
                          );
                          return;
                        }
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemListScreen(
                              dimensions: selectedType,
                              initialItems: Global.cart,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      child: const Text(
                        '3D Object',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Global.cart.isNotEmpty
                    ? Container(
                  height: 200,
                  child: ListView.builder(
                    itemCount: Global.cart.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          Global.cart.keys.elementAt(index).name,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          Global.cart.values.elementAt(index).toString(),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  ),
                )
                    : Container(),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final decorSetData = {
                          'name': objectName.text,
                          'description': description.text,
                          'dimension': selectedType,
                          'items': Global.cart.keys
                              .map((e) => e.id)
                              .toList()
                              .join(','),
                        };
                        if (widget.id.isNotEmpty) {
                          FirebaseFirestore.instance
                              .collection('decor_sets')
                              .doc(widget.id)
                              .update(decorSetData)
                              .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Decor Set updated successfully'),
                              ),
                            );
                            Global.cart.clear();
                            Navigator.of(context).pop("value");
                          }).catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                              ),
                            );
                          });
                        } else {
                          FirebaseFirestore.instance
                              .collection('decor_sets')
                              .add(decorSetData)
                              .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Decor Set created successfully'),
                              ),
                            );
                            Global.cart.clear();
                            Navigator.of(context).pop("value");
                          }).catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                              ),
                            );
                          });
                        }
                      }
                    },
                    child: Text(btn),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
