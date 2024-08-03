import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String imageUrl;
  final String name;
  final String category;
  final String height;
  final String width;
  final String modelUrl; // Add this field for model source
  int counter;

  Item({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.height,
    required this.width,
    required this.modelUrl, // Make sure to initialize this field
    this.counter = 0,
  });

  factory Item.fromDocument(DocumentSnapshot doc) {
    return Item(
      id: doc.id,
      imageUrl: doc['imageUrl'],
      name: doc['objectName'],
      category: doc['category'],
      height: doc['height'],
      width: doc['width'],
      modelUrl: doc['modelUrl'] ?? "", // Ensure modelSrc is fetched from Firestore
    );
  }
}
