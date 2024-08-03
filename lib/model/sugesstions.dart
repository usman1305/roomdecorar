import 'package:cloud_firestore/cloud_firestore.dart';

class Sugesstions {
  final String id;
  final String desc;
  final String dimension;
  final String items;
  final String name;

  Sugesstions({
    required this.id,
    required this.desc,
    required this.dimension,
    required this.items,
    required this.name,
  });

  factory Sugesstions.fromDocument(DocumentSnapshot doc) {
    return Sugesstions(
      id: doc.id,
      desc: doc['description'],
      dimension: doc['dimension'],
      items: doc['items'],
      name: doc['name'],
    );
  }
}
