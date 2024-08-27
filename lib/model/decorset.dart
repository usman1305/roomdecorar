import 'package:cloud_firestore/cloud_firestore.dart';

class DecorSet {
  final String id;
  final String name;
  final String description;
  final List<String> items; // List of item IDs or references
  final String dimension; // New field for dimensions

  DecorSet({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
    required this.dimension, // Include dimension in constructor
  });

  factory DecorSet.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Print data to debug type issues
    print('Document data: $data');

    // Handle 'items' field with a more flexible approach
    List<String> items;
    if (data['items'] is List) {
      items = List<String>.from(data['items']);
    } else if (data['items'] is String) {
      // If 'items' is a single string, split it (assuming it's comma-separated)
      items = (data['items'] as String).split(',');
    } else {
      items = [];
    }

    return DecorSet(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      items: items,
      dimension: data['dimension'] ?? '', // Handle dimension field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'items': items,
      'dimension': dimension, // Include dimension in map
    };
  }
}
