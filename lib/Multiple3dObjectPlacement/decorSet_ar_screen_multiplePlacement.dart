import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import '../model/item.dart';
import '../model/sugesstions.dart';

class Multiple3DItemPlacement extends StatefulWidget {
  final Sugesstions sugesstions;

  Multiple3DItemPlacement({Key? key, required this.sugesstions, required Sugesstions suggestionSet, required suggestions}) : super(key: key);

  @override
  _Multiple3DItemPlacementState createState() => _Multiple3DItemPlacementState();
}

class _Multiple3DItemPlacementState extends State<Multiple3DItemPlacement> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  ARNode? lastAddedNode;
  ARNode? selectedNode; // To track the currently selected node
  final Map<ARNode, ARAnchor?> nodeAnchorMap = {};

  List<Item> items = [];
  String? selectedModelSrc;
  double modelScale = 0.3;
  bool isLoading = false;
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    print('Initializing Multiple3DItemPlacement');
    _fetchModelDetails();
  }

  Future<void> _fetchModelDetails() async {
    print('Fetching model details for decor set: ${widget.sugesstions.name}');
    List<String> itemIds = widget.sugesstions.items;

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
          RepaintBoundary(
            key: _globalKey,
            child: ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
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
                    bool isSelected = selectedModelSrc == item.modelUrl;
                    return GestureDetector(
                      onTap: () {
                        print('Selecting model ${item.modelUrl}');
                        _onModelSelected(item.modelUrl ?? "");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(239, 239, 239, 1.0),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Color.fromRGBO(96, 218, 94, 1), width: 3)
                                : null,
                            image: DecorationImage(
                              image: NetworkImage(item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedNode != null) {
                    removeNode(selectedNode); // Remove the selected node
                    selectedNode = null; // Clear the selected node
                  } else {
                    print('No node selected to remove');
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  backgroundColor: Color.fromARGB(255, 255, 0, 0),
                  padding: EdgeInsets.all(16),
                ),
                child: Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 255, 255, 255),
                  size: 30,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                onPressed: _saveARImage,
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  backgroundColor: Color.fromARGB(160, 0, 0, 255),
                  padding: EdgeInsets.all(16),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Color.fromARGB(255, 255, 255, 255),
                  size: 50,
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
      ARLocationManager arLocationManager, // Add this parameter
      ) {
    print('AR View created');
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;
    // You can also save the ARLocationManager if needed
    // this.arLocationManager = arLocationManager; // Uncomment if you want to use it

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handlePans: true,
      handleRotation: true,
    );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onNodeTap = onNodeTapped;

    print('AR View initialized and onPlaneOrPointTap and onNodeTap callbacks set');
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
          nodeAnchorMap[newNode] = newAnchor; // Store the association
          lastAddedNode = newNode;
        } else {
          print('Failed to add node to anchor');
        }
      } else {
        print('Failed to add anchor');
      }
    } else {
      print('No suitable hit test result found');
    }
  }

  void onNodeTapped(List<String> nodeNames) {
    print('Node tapped: $nodeNames');

    for (String nodeName in nodeNames) {
      ARNode? tappedNode = nodeAnchorMap.keys.firstWhere(
            (node) => node.name == nodeName,

      );
      if (tappedNode != null) {
        selectedNode = tappedNode; // Store the tapped node
        print('Tapped node: ${tappedNode.name}');
      } else {
        print('Tapped node not found in nodeAnchorMap');
      }
    }
  }

  Future<void> removeNode(ARNode? node) async {
    if (node != null) {
      ARAnchor? anchor = nodeAnchorMap[node];
      if (anchor != null) {
        await arObjectManager!.removeNode(node);
        await arAnchorManager!.removeAnchor(anchor);
        nodeAnchorMap.remove(node); // Remove the association
        print('Node ${node.name} removed successfully');
      } else {
        print('Anchor for node not found');
      }
    }
  }

  Future<void> _saveARImage() async {
    if (_globalKey.currentContext != null) {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      await _saveImageToGallery(pngBytes);
    }
  }

  Future<void> _saveImageToGallery(Uint8List imageBytes) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final result = await ImageGallerySaver.saveImage(imageBytes);
      print('Image saved to gallery: $result');
    } else {
      print('Permission denied to access storage');
    }
  }

  @override
  void dispose() {
    arSessionManager?.dispose(); // Only dispose if the method exists
    arObjectManager = null; // Cleanup ARObjectManager
    arAnchorManager = null; // Cleanup ARAnchorManager
    super.dispose();
  }
}
