import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomdecorar/item_model_view.dart';
import 'package:roomdecorar/ar_measure.dart';
import 'package:roomdecorar/admin/view_decorset.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String appBarTitle = user != null ? "Welcome ${user.displayName} 👋" : "Room Decor AR";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          appBarTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(96, 218, 94, 1), // Background color of the button
              borderRadius: BorderRadius.circular(16), // Rounded corners
            ),
            child: IconButton(
              icon: Icon(Icons.auto_awesome, color: Colors.white), // Change this to your desired icon
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewDecorSet()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Furniture items'),
            const SizedBox(height: 250, child: FurnitureItems()),
            const SectionTitle(title: 'Wallpaper Designs'),
            const SizedBox(height: 250, child: Wallpapers()),
            const SectionTitle(title: 'Wallart Designs'), //update this
            const SizedBox(height: 250, child: Wallarts()),
            const SectionTitle(title: 'Ceilling Designs'),
            const SizedBox(height: 250, child: Ceilings()),
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
              itemDescription: item['description'] ?? 'No description',
              modelUrl: item['modelUrl'] ?? '',
            );
          },
        );
      },
    );
  }
}

class Wallpapers extends StatelessWidget {
  const Wallpapers({Key? key}) : super(key: key);

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
              itemDescription: item['description'] ?? 'No description',
              modelUrl: item['modelUrl'] ?? '',
            );
          },
        );
      },
    );
  }
}


class Wallarts extends StatelessWidget {
  const Wallarts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('models')
          .where('category', isEqualTo: 'Wallarts')
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
              itemDescription: item['description'] ?? 'No description',
              modelUrl: item['modelUrl'] ?? '',
            );
          },
        );
      },
    );
  }
}
class Ceilings extends StatelessWidget {
  const Ceilings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('models')
          .where('category', isEqualTo: 'Ceiling')
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
              itemDescription: item['description'] ?? 'No description',
              modelUrl: item['modelUrl'] ?? '',
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
  final String itemDescription;
  final String modelUrl;

  const CustomItemWidget({
    Key? key,
    required this.imageSrc,
    required this.itemName,
    required this.itemDescription,
    required this.modelUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemModelView(
              modelSrc: modelUrl,
              itemName: itemName,
              itemDescription: itemDescription,
              imageUrl: imageSrc,
            ),
          ),
        );
      },
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemModelView(
                          modelSrc: modelUrl,
                          itemName: itemName,
                          itemDescription: itemDescription,
                          imageUrl: imageSrc,
                        ),
                      ),
                    );
                  },
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
