import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        CustomItemWidget(
          imageSrc: 'assets/modelImg/bed1.png',
          alt: 'Bed 1',
          itemName: 'Bed 1',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ItemModelView(
                  modelSrc: 'assets/Models/Bed.glb',
                  alt: 'Bed 1',
                  itemName: 'Bed 1',
                ),
              ),
            );
          },
        ),
        CustomItemWidget(
          imageSrc: 'assets/modelImg/sofa1.png',
          alt: 'Sofa 1',
          itemName: 'Sofa 1',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ItemModelView(
                  modelSrc: 'assets/Models/Sofa.glb',
                  alt: 'Sofa 1',
                  itemName: 'Sofa 1',
                ),
              ),
            );
          },
        ),
        CustomItemWidget(
          imageSrc: 'assets/modelImg/roundTable.png',
          alt: 'Round Table 1',
          itemName: 'Round Table 1',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ItemModelView(
                  modelSrc: 'assets/Models/sidetable.glb',
                  alt: 'Round Table 1',
                  itemName: 'Round Table 1',
                ),
              ),
            );
          },
        ),

        // Add more CustomItemWidget widgets as needed
      ],
    );
  }
}

class DecorItem extends StatelessWidget {
  const DecorItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        CustomItemWidget(
          imageSrc: 'assets/modelImg/sofa1.png',
          alt: 'Sofa 1',
          itemName: 'Sofa 1',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ItemModelView(
                  modelSrc: 'assets/Models/Sofa.glb',
                  alt: 'Sofa 1',
                  itemName: 'Sofa 1',
                ),
              ),
            );
          },
        ),

        // Add more CustomItemWidget widgets as needed
      ],
    );
  }
}

class CustomItemWidget extends StatelessWidget {
  final String imageSrc;
  final String alt;
  final String itemName;
  final VoidCallback onPressed;

  const CustomItemWidget({
    Key? key,
    required this.imageSrc,
    required this.alt,
    required this.itemName,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                Image.asset(
                  imageSrc,
                  height: 150,
                  width: 170,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
                Text(
                  itemName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onPressed,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View Model',
                        style: TextStyle(
                          color: Colors.white60,
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded,
                          color: Color.fromRGBO(96, 218, 94, 1)),
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
