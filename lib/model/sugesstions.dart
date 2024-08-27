import 'package:cloud_firestore/cloud_firestore.dart';

class Sugesstions {
  final String id;
  final String description;
  final String dimension;
  final List<String> items; // Change items to List<String>
  final String name;

  Sugesstions({
    required this.id,
    required this.description,
    required this.dimension,
    required this.items,
    required this.name,
  });

  factory Sugesstions.fromDocument(DocumentSnapshot doc) {
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
      items = []; // Default to an empty list if 'items' is neither
    }

    return Sugesstions(
      id: doc.id,
      description: data['description'] ?? '',
      dimension: data['dimension'] ?? '', // Handle dimension field
      items: items, // Pass items as List<String>
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'items': items.join(','), // Convert List<String> back to a single string
      'dimension': dimension, // Include dimension in map
    };
  }
}
