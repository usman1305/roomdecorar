import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model3d.dart';

class AddObjectScreen extends StatefulWidget {
  @override
  _AddObjectScreenState createState() => _AddObjectScreenState();
}

class _AddObjectScreenState extends State<AddObjectScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  String? _objectName;
  String? _description;
  Uint8List? _imageBytes;
  Uint8List? _modelBytes;
  String? _imageUrl;
  String? _modelUrl;

  Future<void> pickFile(bool isImage) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: isImage ? FileType.image : FileType.custom,
        allowedExtensions: isImage ? null : ['glb'],
      );

      if (result != null) {
        setState(() {
          if (isImage) {
            _imageBytes = result.files.single.bytes;
          } else {
            _modelBytes = result.files.single.bytes;
          }
        });
        print('File picked: ${result.files.single.name}');
      } else {
        print('No file picked.');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<String> uploadFile(Uint8List fileBytes, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      final uploadTask = storageRef.putData(fileBytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('File uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return '';
    }
  }

  Future<void> saveToDatabase() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (_imageBytes != null) {
          _imageUrl = await uploadFile(_imageBytes!,
              'images/${DateTime.now().millisecondsSinceEpoch}.png');
        }
        if (_modelBytes != null) {
          _modelUrl = await uploadFile(_modelBytes!,
              'models/${DateTime.now().millisecondsSinceEpoch}.glb');
        }

        final newObject = Model3d(
          category: _category!,
          objectName: _objectName!,
          description: _description!,
          imageUrl: _imageUrl,
          modelUrl: _modelUrl,
        );

        await FirebaseFirestore.instance
            .collection('models')
            .add(newObject.toMap());
        print('Object added to Firestore: ${newObject.toMap()}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Object added successfully')),
        );
      } catch (e) {
        print('Error saving to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving object')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Add 3D Model Object',
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: Colors.grey[850],
                ),
                dropdownColor: Colors.black,
                hint: Text(
                  'Select a category',
                  style: TextStyle(color: Colors.white38),
                ),
                value: _category,
                items: ['Furniture', 'Ceiling', 'Wallpaper']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(color: Colors.white38),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 5),
              TextFormField(
                style: TextStyle(color: Colors.white70),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter Object Name',
                  hintStyle: TextStyle(color: Colors.white38),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an object name'
                    : null,
                onSaved: (value) {
                  _objectName = value;
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                style: TextStyle(color: Colors.white70),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter Description',
                  hintStyle: TextStyle(color: Colors.white38),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
                onSaved: (value) {
                  _description = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => pickFile(true),
                icon: Icon(Icons.image, color: Colors.black),
                label:
                    Text('Upload Image', style: TextStyle(color: Colors.black)),
              ),
              _imageUrl == null ? Container() : Image.network(_imageUrl!),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => pickFile(false),
                icon: Icon(Icons.upload_file, color: Colors.black),
                label: Text('Upload 3D Model',
                    style: TextStyle(color: Colors.black)),
              ),
              _modelBytes == null
                  ? Container()
                  : Text('Model selected',
                      style: TextStyle(color: Colors.white)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveToDatabase,
                child: Text('Save to Database',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
