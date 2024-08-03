import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import '../model/item.dart';
import '../model/sugesstions.dart';

class Multiple3DItemPlacement extends StatefulWidget {
  final Sugesstions suggestionSet;

  Multiple3DItemPlacement({Key? key, required this.suggestionSet}) : super(key: key);

  @override
  _Multiple3DItemPlacementState createState() => _Multiple3DItemPlacementState();
}

class _Multiple3DItemPlacementState extends State<Multiple3DItemPlacement> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<Item> items = [];
  String? selectedModelSrc;
  double modelScale = 0.2;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print('Initializing Multiple3DItemPlacement');
    _fetchModelDetails();
  }

  Future<void> _fetchModelDetails() async {
    print('Fetching model details for suggestion set: ${widget.suggestionSet.name}');
    List<String> itemIds = widget.suggestionSet.items.split(',');

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
      items = fetchedItems;
      print('Fetched ${items.length} items');
    });
  }

  void _onModelSelected(String modelSrc) {
    print('Selecting model: $modelSrc');
    setState(() {
      selectedModelSrc = modelSrc;
      print('Model selected: $selectedModelSrc');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building Multiple3DItemPlacement widget');
    return Scaffold(
      appBar: AppBar(
        title: Text('Place 3D Items'),
        backgroundColor: const Color.fromRGBO(96, 218, 94, 1),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        print('Selecting model ${item.modelUrl}');
                        _onModelSelected(item.modelUrl ?? "");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Image.network(item.imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                            Text(item.name, style: TextStyle(color: Color.fromARGB(255, 241, 241, 241))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager,
      ) {
    print('AR View created');
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handlePans: true,
      handleRotation: true,
    );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    print('AR View initialized and onPlaneOrPointTap callback set');
  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    print('Plane or point tapped');
    if (selectedModelSrc == null || selectedModelSrc!.isEmpty) {
      print('No model selected or model source is empty');
      return;
    }

    ARHitTestResult? singleHitTestResult;
    for (var hitTestResult in hitTestResults) {
      if (hitTestResult.type == ARHitTestResultType.plane) {
        singleHitTestResult = hitTestResult;
        break;
      }
    }

    if (singleHitTestResult != null) {
      print('Creating new anchor');
      var newAnchor = ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await this.arAnchorManager!.addAnchor(newAnchor);
      if (didAddAnchor != null && didAddAnchor) {
        print('Anchor added successfully');
        setState(() {
          isLoading = true;
        });

        var newNode = ARNode(
          type: NodeType.webGLB,
          uri: selectedModelSrc!,
          scale: Vector3(modelScale, modelScale, modelScale),
          position: Vector3(0.0, 0.0, 0.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0),
        );

        bool? didAddNodeToAnchor = await this.arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
        setState(() {
          isLoading = false;
        });

        if (didAddNodeToAnchor != null && didAddNodeToAnchor) {
          print('Node added to anchor successfully');
        } else {
          print('Failed to add node to anchor');
          this.arSessionManager!.onError("Adding Node to Anchor failed");
        }
      } else {
        print('Failed to add anchor');
        this.arSessionManager!.onError("Adding Anchor failed");
      }
    } else {
      print('No valid plane hit test result found');
    }
  }
}
