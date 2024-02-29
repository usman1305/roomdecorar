import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ItemModelView extends StatelessWidget {
  final String modelSrc;
  final String alt;
  final String itemName;

  const ItemModelView({
    Key? key,
    required this.modelSrc,
    required this.alt,
    required this.itemName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemName),
        backgroundColor: const Color.fromRGBO(96, 218, 94, 1),
      ),
      body: Center(
        child: ModelViewer(
          backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
          src: modelSrc,
          alt: alt,
          ar: true,
          arPlacement: ArPlacement.floor,
          autoRotate: true,
          disableZoom: true,
        ),
      ),
    );
  }
}
