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
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'admin/add_decorset.dart';



class ARMeasurePage extends StatefulWidget {
  @override
  _ARMeasurePageState createState() => _ARMeasurePageState();
}

class _ARMeasurePageState extends State<ARMeasurePage> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  List<ARNode> addedNodes = [];
  List<vector.Vector3> points = [];
  List<ARAnchor> anchors = [];
  bool isLoading = false;
  List<double> distances = [];
  bool isMeasurementComplete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Measure Page'),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          if (points.length == 2)
            Positioned(
              bottom: 120,
              left: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Text(
                  'Distance 1: ${_calculateDistance(points[0], points[1]).toStringAsFixed(2)} meters',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          if (points.length == 4)
            Positioned(
              bottom: 80,
              left: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Text(
                  'Distance 2: ${_calculateDistance(points[2], points[3]).toStringAsFixed(2)} meters',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _handleDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: Text('Done', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    arSessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: true,
      handlePans: false,
      handleRotation: false,
    );

    arObjectManager.onInitialize();
    arSessionManager.onPlaneOrPointTap = _handleOnPlaneOrPointTapped;
  }

  void _handleOnPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    print('Hit Test Results: $hitTestResults'); // Debug print

    if (hitTestResults.isNotEmpty) {
      var hitTestResult = hitTestResults.first;
      var position = vector.Vector3(
        hitTestResult.worldTransform[12],
        hitTestResult.worldTransform[13],
        hitTestResult.worldTransform[14],
      );

      if (hitTestResult.type == ARHitTestResultType.plane) {
        var newAnchor = ARPlaneAnchor(transformation: hitTestResult.worldTransform);
        bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
        if (didAddAnchor!) {
          anchors.add(newAnchor);
          setState(() {
            isLoading = true;
          });
          _addSphereNode(position);
          setState(() {
            isLoading = false;
          });
        } else {
          print('Failed to add anchor.');
        }
      }

      setState(() {
        if (points.length < 4) {
          points.add(position);
          _addSphereNode(position);

          if (points.length == 2) {
            _addLine(points[0], points[1]);
          } else if (points.length == 4) {
            _addLine(points[2], points[3]);
          }
        }
      });
    } else {
      print('No point hit. Debug info: ${hitTestResults.toString()}');
    }
  }

  void _addSphereNode(vector.Vector3 position) {
    var newNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://firebasestorage.googleapis.com/v0/b/roomdecorarfyp.appspot.com/o/redball.glb?alt=media",
      scale: vector.Vector3(0.3, 0.3, 0.3),
      position: position,
    );
    arObjectManager!.addNode(newNode).then((success) {
      if (success == true) {
        addedNodes.add(newNode);
        print('Added sphere node at $position');
      } else {
        print('Failed to add sphere node.');
      }
    }).catchError((error) {
      print('Failed to add sphere node: $error');
    });
  }

  void _addLine(vector.Vector3 start, vector.Vector3 end) {
    final int numberOfBalls = 10;
    final double distance = (start - end).length;
    final vector.Vector3 direction = (end - start).normalized();
    final double ballSpacing = distance / (numberOfBalls + 1);

    for (int i = 1; i <= numberOfBalls; i++) {
      final double t = i * ballSpacing;
      final vector.Vector3 position = start + direction * t;

      var newBallNode = ARNode(
        type: NodeType.webGLB,
        uri: "https://firebasestorage.googleapis.com/v0/b/roomdecorarfyp.appspot.com/o/redball.glb?alt=media",
        scale: vector.Vector3(0.15, 0.15, 0.15),
        position: position,
      );

      arObjectManager!.addNode(newBallNode).then((success) {
        if (success == true) {
          addedNodes.add(newBallNode);
          print('Added ball node at $position');
        } else {
          print('Failed to add ball node.');
        }
      }).catchError((error) {
        print('Failed to add ball node: $error');
      });
    }
  }

  double _calculateDistance(vector.Vector3 start, vector.Vector3 end) {
    return (start - end).length;
  }

  void _handleDone() {
    if (points.length == 4) {
      final distance1 = _calculateDistance(points[0], points[1]);
      final distance2 = _calculateDistance(points[2], points[3]);

      // Update the state with the new distances
      setState(() {
        distances = [distance1, distance2];
        isMeasurementComplete = true;
      });

      // Ensure that the distances are updated before navigating
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddDecorSet(distances: List.from(distances), id: '', name: '', desc: '',),
          ),
        );
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please place four points to complete the measurement.')),
      );
    }
  }


  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }
}

