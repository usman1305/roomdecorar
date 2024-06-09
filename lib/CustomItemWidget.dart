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
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
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
                    // Display an error icon if image loading fails
                    return Icon(Icons.error, color: Colors.red);
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
      ),
    );
  }
}
