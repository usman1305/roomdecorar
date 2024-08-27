import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class ViewSingle3DObject extends StatefulWidget {
  final String modelSrc;
  final String itemName;

  ViewSingle3DObject({Key? key, required this.modelSrc, required this.itemName})
      : super(key: key);

  @override
  _ViewSingle3DObjectState createState() => _ViewSingle3DObjectState();
}

class _ViewSingle3DObjectState extends State<ViewSingle3DObject> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];
  bool isLoading = false;
  double modelScale = 0.6;
  GlobalKey _globalKey = GlobalKey();

  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName), // Display model name in the title
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
            Center(
              child: CircularProgressIndicator(),
            ),
          // Camera icon button aligned at the bottom center
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60.0), // Padding for bottom
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
          // Delete button aligned near the bottom right
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60.0, right: 30.0), // Padding for bottom and right
              child: ElevatedButton(
                onPressed: onRemoveEverything,
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
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;
  }

  Future<void> onRemoveEverything() async {
    anchors.forEach((anchor) {
      this.arAnchorManager!.removeAnchor(anchor);
    });
    anchors = [];
  }

  Future<void> _saveARImage() async {
    // Request storage permission
    await _requestPermission();

    try {
      // Capture the AR view as an image
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final result = await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
        print(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot saved to gallery!')),
        );
      }
    } catch (e) {
      arSessionManager!.onError("Screenshot capture failed: $e");
    }
  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults.firstWhere(
          (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane,
    );
    var newAnchor = ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await this.arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor!) {
      this.anchors.add(newAnchor);
      setState(() {
        isLoading = true;
      });
      // Add node to anchor
      var newNode = ARNode(
        type: NodeType.webGLB,
        uri: widget.modelSrc, // Use the passed model source URL
        scale: Vector3(modelScale, modelScale, modelScale),
        position: Vector3(0.0, 0.0, 0.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0),
      );
      bool? didAddNodeToAnchor = await this.arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
      setState(() {
        isLoading = false;
      });
      if (didAddNodeToAnchor!) {
        this.nodes.add(newNode);
      } else {
        this.arSessionManager!.onError("Adding Node to Anchor failed");
      }
    } else {
      this.arSessionManager!.onError("Adding Anchor failed");
    }
    }

  void onPanStarted(String nodeName) {
    print("Started panning node " + nodeName);
  }

  void onPanChanged(String nodeName) {
    print("Continued panning node " + nodeName);
  }

  void onPanEnded(String nodeName, Matrix4 newTransform) {
    print("Ended panning node " + nodeName);
    this.nodes.firstWhere((element) => element.name == nodeName);
  }

  void onRotationStarted(String nodeName) {
    print("Started rotating node " + nodeName);
  }

  void onRotationChanged(String nodeName) {
    print("Continued rotating node " + nodeName);
  }

  void onRotationEnded(String nodeName, Matrix4 newTransform) {
    print("Ended rotating node " + nodeName);
    this.nodes.firstWhere((element) => element.name == nodeName);
  }

  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }
}