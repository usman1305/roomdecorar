class Model3d {
  final String category;
  final String objectName;
  final String description;
  final String? imageUrl;
  final String? modelUrl;

  Model3d({
    required this.category,
    required this.objectName,
    required this.description,
    this.imageUrl,
    this.modelUrl,
  });

  // Factory constructor to create an instance from a map
  factory Model3d.fromMap(Map<String, dynamic> map) {
    return Model3d(
      category: map['category'] ?? '',
      objectName: map['objectName'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      modelUrl: map['modelUrl'],
    );
  }

  String? get id => null;

  // Method to convert an instance to a map
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'objectName': objectName,
      'description': description,
      'imageUrl': imageUrl,
      'modelUrl': modelUrl,
    };
  }
}
