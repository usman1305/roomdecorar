import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String imageUrl;
  final String name;
  final String category;
  final String height;
  final String width;
  int counter;

  Item({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.height,
    required this.width,
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
    );
  }
}
