import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomdecorar/Model3d.dart';
import 'package:roomdecorar/item_model_view.dart';
import 'package:roomdecorar/AddObjectScreen.dart';

class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({Key? key}) : super(key: key);

  @override
  _AdminSearchScreenState createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Admin Search',
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: 'Search for models...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('models').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!.docs
                    .map((doc) =>
                        Model3d.fromMap(doc.data() as Map<String, dynamic>))
                    .toList();

                final filteredItems = items.where((item) {
                  final name = (item.objectName as String).toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final model = filteredItems[index];
                    return GestureDetector(
                      onLongPress: () => _showAdminOptions(context, model),
                      child: CustomItemWidget(
                        imageSrc: model.imageUrl ?? 'assets/placeholder.png',
                        itemName: model.objectName,
                        itemDescription: model.description ?? '',
                        modelUrl: model.modelUrl ?? '',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminOptions(BuildContext context, Model3d model) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddObjectScreen(objectName: model.objectName),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, model.objectName);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String objectName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $objectName?'),
        content: Text('Are you sure you want to delete $objectName?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the confirmation dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the confirmation dialog
              try {
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('models')
                    .where('objectName', isEqualTo: objectName)
                    .get();

                for (var doc in querySnapshot.docs) {
                  await doc.reference.delete();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Object(s) deleted successfully')),
                );
              } catch (e) {
                debugPrint('Error deleting object: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error deleting object: ${e.toString()}')),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomItemWidget extends StatelessWidget {
  final String imageSrc;
  final String itemName;
  final String itemDescription;
  final String modelUrl;

  const CustomItemWidget({
    Key? key,
    required this.imageSrc,
    required this.itemName,
    required this.itemDescription,
    required this.modelUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemModelView(
              modelSrc: modelUrl,
              itemName: itemName,
              itemDescription: itemDescription,
              imageUrl: imageSrc,
            ),
          ),
        );
      },
      child: Card(
        color: Color.fromRGBO(33, 33, 33, 1),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  imageSrc,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    String errorMessage = 'Failed to load image';
                    if (error is Exception) {
                      errorMessage = error.toString();
                    } else if (error is String) {
                      errorMessage = error;
                    }
                    debugPrint('Error loading image: $errorMessage');
                    return Container(
                      color: Colors.grey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(height: 8),
                          Text(
                            'Image failed to load',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                itemName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemModelView(
                        modelSrc: modelUrl,
                        itemName: itemName,
                        itemDescription: itemDescription,
                        imageUrl: imageSrc,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'View Model',
                      style: TextStyle(color: Colors.white60),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color.fromRGBO(96, 218, 94, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
