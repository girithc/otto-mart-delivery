import 'package:delivery/home/home.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  bool isAadharCardImageSelected = false;
  bool isPanCardImageSelected = false;
  bool isPersonalPhotoSelected = false;

  String translateToHindi(String text) {
    var translations = {
      'Welcome To Otto Mart': 'ओटो मार्ट में आपका स्वागत है',
      'Personal Photo': 'व्यक्तिगत फोटो',
      'Aadhar Card': 'आधार कार्ड',
      'PAN Card': 'पैन कार्ड',
      'Name': 'नाम',
      'Age': 'उम्र',
      'Address': 'पता दर्ज करें',
      'Aadhar Card Number': 'आधार कार्ड संख्या',
      'PAN Card Number': 'पैन कार्ड संख्या',
      'Upload Image': 'छवि अपलोड करें',
      'Click a Selfie': 'सेल्फी लें',
      'Submit': 'जमा करें',
      'Please upload all required images': 'कृपया सभी आवश्यक छवियां अपलोड करें',
    };
    return translations[text] ?? text;
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (type == 'aadhar') {
          aadharCardImage = pickedFile;
          isAadharCardImageSelected = true;
        } else if (type == 'pan') {
          panCardImage = pickedFile;
          isPanCardImageSelected = true;
        } else if (type == 'personal') {
          personalPhoto = pickedFile;
          isPersonalPhotoSelected = true;
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
            icon: Text(
              isEnglish ? 'हिंदी' : 'English',
              style: TextStyle(fontSize: 16.0),
            ),
            onPressed: toggleLanguage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailsContainer('Name', 'Age', 'Enter Address',
                    'Personal Photo', personalPhoto,
                    addressField: 'Address', cameraOnly: true),
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
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 10,
              offset: Offset(0, 5), // Specify the shadow's offset
            ),
          ],
        ),
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        height: MediaQuery.of(context).size.height * 0.12,
        child: Column(
          // Align children at the start
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, bottom: 15, top: 0),
              height: MediaQuery.of(context).size.height * (0.18 - 0.075),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      isAadharCardImageSelected &&
                      isPanCardImageSelected &&
                      isPersonalPhotoSelected) {
                    // If the form and images are valid, navigate to the home page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    // Show an alert or some other indication that images are required
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEnglish
                              ? 'Please upload all required images'
                              : translateToHindi(
                                  'Please upload all required images'),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold, // Making the font bold
                      ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0), // Slightly more rounded
                  ),
                  elevation: 5, // Adding some shadow for depth
                  side: BorderSide(
                      color: Colors.pink[200]!,
                      width: 2), // Border for a more defined look
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.electric_bike_outlined),
                    SizedBox(width: 10),
                    Text(
                      isEnglish ? 'Submit' : translateToHindi('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsContainer(String firstField, String? secondField,
      String? buttonTitle, String imageFieldTitle, XFile? imageFile,
      {bool cameraOnly = false, String? addressField}) {
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $firstField';
              }
              return null;
            },
          ),
          if (secondField != null) SizedBox(height: 10),
          if (secondField != null)
            TextFormField(
              decoration: InputDecoration(
                labelText:
                    isEnglish ? secondField : translateToHindi(secondField),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your $secondField';
                }
                return null;
              },
            ),
          if (addressField != null) SizedBox(height: 10),
          if (addressField != null)
            TextFormField(
              decoration: InputDecoration(
                labelText:
                    isEnglish ? addressField : translateToHindi(addressField),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your $addressField';
                }
                return null;
              },
            ),
          SizedBox(height: 10),
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
                alignment: Alignment.center,
                child: const Text('No image selected'),
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
        if (imageFile == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please upload an image.',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
