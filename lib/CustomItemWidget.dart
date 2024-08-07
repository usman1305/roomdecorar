import 'package:flutter/material.dart';

class CustomItemWidget extends StatelessWidget {
  final String imageSrc;
  final String itemName;
  final VoidCallback onPressed;

  const CustomItemWidget({
    Key? key,
    required this.imageSrc,
    required this.itemName,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Card(
        color: Color.fromRGBO(33, 33, 33, 1),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with error handling
              Image.network(
                imageSrc,
                height: 150,
                width: 170,
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
                    height: 150,
                    width: 170,
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
}
