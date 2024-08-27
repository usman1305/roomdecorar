import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomdecorar/item_model_view.dart';
import 'package:roomdecorar/model/item.dart';
import 'package:roomdecorar/model/sugesstions.dart';

class CustomerSuggestionSetView extends StatefulWidget {
  final Sugesstions suggestionSet;

  const CustomerSuggestionSetView({Key? key, required this.suggestionSet}) : super(key: key);

  @override
  _CustomerSuggestionSetViewState createState() => _CustomerSuggestionSetViewState();
}

class _CustomerSuggestionSetViewState extends State<CustomerSuggestionSetView> {
  List<Item> fetchedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchModelDetails();
  }

  Future<void> _fetchModelDetails() async {
    print('Fetching model details for suggestion set: ${widget.suggestionSet.name}');

    // Directly use the items list from suggestionSet
    List<String> itemIds = widget.suggestionSet.items; // No need to split

    List<Item> fetchedItems = [];

    for (String itemId in itemIds) {
      print('Fetching item with ID: $itemId');
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('models').doc(itemId).get();
        if (doc.exists) {
          Item item = Item.fromDocument(doc);
          fetchedItems.add(item);
          print('Fetched item: ${item.name}');
        } else {
          print('No document found for item ID: $itemId');
        }
      } catch (e) {
        print('Error fetching item ID $itemId: $e');
      }
    }

    setState(() {
      this.fetchedItems = fetchedItems;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Suggestion Set Items',
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fetchedItems.isEmpty
          ? Center(
        child: Text('No items found for this suggestion set', style: TextStyle(color: Colors.white)),
      )
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        padding: const EdgeInsets.all(8.0),
        itemCount: fetchedItems.length,
        itemBuilder: (context, index) {
          final item = fetchedItems[index];
          return CustomItemWidget(
            imageSrc: item.imageUrl,
            itemName: item.name,
            itemDescription: item.description,
            modelUrl: item.modelUrl,
          );
        },
      ),
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
      child: Card(
        color: const Color.fromRGBO(33, 33, 33, 1),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  imageSrc,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
              const Row(
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
            ],
          ),
        ),
      ),
    );
  }
}
