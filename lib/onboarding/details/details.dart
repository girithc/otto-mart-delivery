import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool isEnglish = true;
  final ImagePicker _picker = ImagePicker();
  XFile? aadharCardImage;
  XFile? panCardImage;
  XFile? personalPhoto;

  void toggleLanguage() {
    setState(() {
      isEnglish = !isEnglish;
    });
  }

  String translateToHindi(String text) {
    var translations = {
      'Welcome To Otto Mart': 'ओटो मार्ट में आपका स्वागत है',
      'Personal Photo': 'व्यक्तिगत फोटो',
      'Aadhar Card': 'आधार कार्ड',
      'PAN Card': 'पैन कार्ड',
      'Name': 'नाम',
      'Age': 'उम्र',
      'Enter Address': 'पता दर्ज करें',
      'Aadhar Card Number': 'आधार कार्ड संख्या',
      'PAN Card Number': 'पैन कार्ड संख्या',
      'Upload Image': 'छवि अपलोड करें',
      'Click a Selfie': 'सेल्फी लें'
    };
    return translations[text] ?? text;
  }

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
        title: Text(isEnglish
            ? 'Welcome To Otto Mart'
            : translateToHindi('Welcome To Otto Mart')),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: toggleLanguage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailsContainer('Name', 'Age', 'Enter Address',
                  'Personal Photo', personalPhoto,
                  cameraOnly: true),
              const SizedBox(height: 10),
              _buildDetailsContainer('Aadhar Card Number', null, null,
                  'Aadhar Card', aadharCardImage),
              const SizedBox(height: 10),
              _buildDetailsContainer(
                  'PAN Card Number', null, null, 'PAN Card', panCardImage),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsContainer(String firstField, String? secondField,
      String? buttonTitle, String imageFieldTitle, XFile? imageFile,
      {bool cameraOnly = false}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: isEnglish ? firstField : translateToHindi(firstField),
              border: const OutlineInputBorder(),
            ),
          ),
          if (secondField != null) const SizedBox(height: 10),
          if (secondField != null)
            TextFormField(
              decoration: InputDecoration(
                labelText:
                    isEnglish ? secondField : translateToHindi(secondField),
                border: const OutlineInputBorder(),
              ),
            ),
          if (buttonTitle != null) const SizedBox(height: 10),
          if (buttonTitle != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: Text(
                isEnglish ? buttonTitle : translateToHindi(buttonTitle),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          const SizedBox(height: 10),
          _imageField(imageFieldTitle, imageFile, cameraOnly: cameraOnly),
        ],
      ),
    );
  }

  Widget _imageField(String title, XFile? imageFile,
      {bool cameraOnly = false}) {
    String translatedTitle = isEnglish ? title : translateToHindi(title);
    String buttonTitle = cameraOnly ? 'Click a Selfie' : 'Upload Image';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          translatedTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
            isEnglish ? buttonTitle : translateToHindi(buttonTitle),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
