import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomdecorar/Model3d.dart';
import 'package:roomdecorar/item_model_view.dart';
import 'package:roomdecorar/CategorizedObjectWidget.dart';
import 'package:roomdecorar/AddObjectScreen.dart';

class CategorizedObjectsScreen extends StatelessWidget {
  final String category;

  const CategorizedObjectsScreen({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '$category Items',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('models')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No items found in this category.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final models = snapshot.data!.docs
              .map((doc) => Model3d.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return CategorizedObjectWidget(
                imageSrc: model.imageUrl ?? 'assets/placeholder.png',
                itemName: model.objectName,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemModelView(
                        modelSrc: model.modelUrl!,
                        itemName: model.objectName,
                        itemDescription: model.description ?? '',
                        imageUrl: model.imageUrl ?? 'assets/placeholder.png',
                      ),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddObjectScreen(objectName: model.objectName),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, model.objectName),
              );
            },
          );
        },
      ),
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
