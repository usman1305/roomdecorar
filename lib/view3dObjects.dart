import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomdecorar/AddObjectScreen.dart';
import 'item_model_view.dart';
import 'package:roomdecorar/Model3d.dart';
import 'package:roomdecorar/CustomItemWidget.dart';

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
            const SizedBox(
                height: 250, child: ModelsList(category: 'Furniture')),
            const SectionTitle(title: 'Wallart Designs'),
            const SizedBox(
                height: 250, child: ModelsList(category: 'Wallpaper'))
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('models').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddObjectScreen()),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.black,
            );
          }
          return Container(); // Return an empty container if no models exist
        },
      ),
    );
  }
}

class ModelsList extends StatelessWidget {
  final String category;

  const ModelsList({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('models')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddObjectScreen()),
                );
              },
              child: Text('Add 3D Model'),
            ),
          );
        }

        final models = snapshot.data!.docs
            .map((doc) => Model3d.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: models.length,
          itemBuilder: (context, index) {
            final model = models[index];
            return CustomItemWidget(
              imageSrc: model.imageUrl ?? 'assets/placeholder.png',
              itemName: model.objectName,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemModelView(
                      modelSrc: model.modelUrl!,
                      alt: model.objectName,
                      itemName: model.objectName,
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