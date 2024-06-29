import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomdecorar/item_model_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String appBarTitle =
        user != null ? "Welcome back ${user.displayName} 👋" : "Room Decor AR";

    return Scaffold(
      backgroundColor: Colors.black,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              title: Text(
                appBarTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
            ),
            const SectionTitle(title: 'Furniture items'),
            const SizedBox(height: 250, child: FurnitureItems()),
            const SectionTitle(title: 'Wallart Designs'),
            const SizedBox(height: 250, child: DecorItem())
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigation(),
    );
  }
}

class FurnitureItems extends StatelessWidget {
  const FurnitureItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('models')
          .where('category', isEqualTo: 'Furniture')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return CustomItemWidget(
              imageSrc: item['imageUrl'] ?? '',
              itemName: item['objectName'] ?? 'No name',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemModelView(
                      modelSrc: item['modelUrl'] ?? '',
                      itemName: item['objectName'] ?? 'No name',
                      alt: '',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class DecorItem extends StatelessWidget {
  const DecorItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('models')
          .where('category', isEqualTo: 'Wallpaper')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return CustomItemWidget(
              imageSrc: item['imageUrl'] ?? '',
              itemName: item['objectName'] ?? 'No name',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemModelView(
                      modelSrc: item['modelUrl'] ?? '',
                      itemName: item['objectName'] ?? 'No name',
                      alt: '',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

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
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
