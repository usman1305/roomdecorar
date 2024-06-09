class Model3d {
  String category;
  String objectName;
  String description;
  String? imageUrl;
  String? modelUrl;

  Model3d({
    required this.category,
    required this.objectName,
    required this.description,
    this.imageUrl,
    this.modelUrl,
  });

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
