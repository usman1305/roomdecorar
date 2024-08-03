import 'package:flutter/material.dart';

class CategorizedObjectWidget extends StatelessWidget {
  final String imageSrc;
  final String itemName;
  final VoidCallback onPressed;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CategorizedObjectWidget({
    Key? key,
    required this.imageSrc,
    required this.itemName,
    required this.onPressed,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        _showOptionsDialog(context);
      },
      child: Card(
        color: const Color.fromRGBO(33, 33, 33, 1),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                imageSrc,
                height: 120,
                width: double.infinity,
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
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        const SizedBox(height: 8),
                        const Text(
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
                onTap: onPressed,
                child: const Row(
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

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(itemName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // Close the dialog before editing
                onEdit();
              },
              child: Row(
                children: const [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _confirmDelete(context),
              child: Row(
                children: const [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $itemName?'),
        content: Text('Are you sure you want to delete $itemName?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the confirmation dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the confirmation dialog
              onDelete();
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
