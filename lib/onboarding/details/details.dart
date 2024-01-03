import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? aadharCardImage;
  XFile? panCardImage;
  XFile? personalPhoto;

  Future<void> _pickImage(ImageSource source, String type) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (type == 'aadhar') {
          aadharCardImage = pickedFile;
        } else if (type == 'pan') {
          panCardImage = pickedFile;
        } else if (type == 'personal') {
          personalPhoto = pickedFile;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome To Otto Mart'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(10), // Adds horizontal margin
                decoration: BoxDecoration(
                  color: Colors.white, // Set the background color
                  borderRadius: BorderRadius.circular(
                      10), // Optional: Adds rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(
                          0.5), // Shadow color with some transparency
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3), // Changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _imageField('Personal Photo', personalPhoto,
                        cameraOnly: true),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10), // Adds horizontal margin
                decoration: BoxDecoration(
                  color: Colors.white, // Set the background color
                  borderRadius: BorderRadius.circular(
                      10), // Optional: Adds rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(
                          0.5), // Shadow color with some transparency
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3), // Changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Aadhar Card Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _imageField('Aadhar Card', aadharCardImage),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10), // Adds horizontal margin
                decoration: BoxDecoration(
                  color: Colors.white, // Set the background color
                  borderRadius: BorderRadius.circular(
                      10), // Optional: Adds rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(
                          0.5), // Shadow color with some transparency
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3), // Changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'PAN Card Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 10),
                    _imageField('PAN Card', panCardImage),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageField(String title, XFile? imageFile,
      {bool cameraOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        imageFile != null
            ? Image.file(File(imageFile.path))
            : Container(
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 100),
              ),
        const SizedBox(height: 5),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _pickImage(
              cameraOnly ? ImageSource.camera : ImageSource.gallery,
              title.toLowerCase()),
          child: Text(
            'Pick ${cameraOnly ? "from Camera" : "Image"}',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
