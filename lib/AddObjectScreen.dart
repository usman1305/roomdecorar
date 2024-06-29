import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model3d.dart';

class AddObjectScreen extends StatefulWidget {
  final String? objectName;

  const AddObjectScreen({Key? key, this.objectName}) : super(key: key);

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
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _objectName =
        widget.objectName; // Initialize objectName with provided value
    if (_objectName != null) {
      // Load existing data if objectName is provided (editing mode)
      loadObjectData();
    }
  }

  Future<void> loadObjectData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('models')
          .where('objectName', isEqualTo: _objectName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final modelData = snapshot.docs.first.data();
        setState(() {
          _category = modelData['category'];
          _description = modelData['description'];
          _imageUrl = modelData['imageUrl'];
          _modelUrl = modelData['modelUrl'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Object not found for editing')),
        );
      }
    } catch (e) {
      print('Error loading object data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading object data')),
      );
    }
  }

  Future<void> pickFile(bool isImage) async {
    try {
      FilePickerResult? result;

      if (isImage) {
        result = await FilePicker.platform.pickFiles(type: FileType.image);
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['glb'],
        );
      }

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          if (isImage) {
            _imageBytes = result?.files.single.bytes;
          } else {
            _modelBytes = result?.files.single.bytes;
          }
        });
        print('File picked: ${result.files.single.name}');
      } else {
        print('No file picked or file is empty.');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  bool isValidImage(Uint8List fileBytes) {
    const jpgHeader = [0xFF, 0xD8];
    const pngHeader = [0x89, 0x50, 0x4E, 0x47];

    if (fileBytes.length >= 2 &&
        fileBytes[0] == jpgHeader[0] &&
        fileBytes[1] == jpgHeader[1]) {
      return true;
    }

    if (fileBytes.length >= 4 &&
        fileBytes[0] == pngHeader[0] &&
        fileBytes[1] == pngHeader[1] &&
        fileBytes[2] == pngHeader[2] &&
        fileBytes[3] == pngHeader[3]) {
      return true;
    }

    return false;
  }

  bool isValidModel(Uint8List fileBytes) {
    const glbHeader = [0x67, 0x6C, 0x54, 0x46]; // "glTF"

    if (fileBytes.length >= 4 &&
        fileBytes[0] == glbHeader[0] &&
        fileBytes[1] == glbHeader[1] &&
        fileBytes[2] == glbHeader[2] &&
        fileBytes[3] == glbHeader[3]) {
      return true;
    }

    return false;
  }

  Future<String> uploadFile(Uint8List fileBytes, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      final uploadTask = storageRef.putData(fileBytes);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

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
          if (isValidImage(_imageBytes!)) {
            _imageUrl = await uploadFile(_imageBytes!,
                'images/${DateTime.now().millisecondsSinceEpoch}.png');
          } else {
            throw Exception('Invalid image file format.');
          }
        }

        if (_modelBytes != null) {
          if (isValidModel(_modelBytes!)) {
            _modelUrl = await uploadFile(_modelBytes!,
                'models/${DateTime.now().millisecondsSinceEpoch}.glb');
          } else {
            throw Exception('Invalid model file format.');
          }
        }

        if (widget.objectName != null) {
          // Check if objectName is provided (editing mode)
          final snapshot = await FirebaseFirestore.instance
              .collection('models')
              .where('objectName', isEqualTo: widget.objectName)
              .limit(1)
              .get();

          if (snapshot.docs.isNotEmpty) {
            final docId = snapshot.docs.first.id;
            await FirebaseFirestore.instance
                .collection('models')
                .doc(docId)
                .update({
              'category': _category,
              'objectName': _objectName,
              'description': _description,
              'imageUrl': _imageUrl,
              'modelUrl': _modelUrl,
            });
            print('Object updated in Firestore: $docId');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Object updated successfully')),
            );
          } else {
            throw Exception('Object not found for updating');
          }
        } else {
          // If objectName is null, check if the new objectName is unique
          final existingObjectSnapshot = await FirebaseFirestore.instance
              .collection('models')
              .where('objectName', isEqualTo: _objectName)
              .limit(1)
              .get();

          if (existingObjectSnapshot.docs.isEmpty) {
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
          } else {
            throw Exception('Object with the same name already exists');
          }
        }
      } catch (e) {
        print('Error saving to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving object: ${e.toString()}')),
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
          _objectName == null ? 'Add 3D Model Object' : 'Edit 3D Model Object',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        iconTheme: IconThemeData(color: Colors.white),
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
                initialValue: _objectName ?? '',
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
                initialValue: _description ?? '',
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
              _imageBytes == null
                  ? Container()
                  : LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
              SizedBox(height: 20), // Removed the image display here
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
                child: Text(_objectName == null ? 'Save to Database' : 'Update',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
