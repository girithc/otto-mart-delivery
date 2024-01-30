import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CompleteDeliveryPage extends StatefulWidget {
  CompleteDeliveryPage(
      {super.key, required this.customerPhone, required this.orderDate});
  String customerPhone;
  String orderDate;

  @override
  State<CompleteDeliveryPage> createState() => _CompleteDeliveryPageState();
}

class _CompleteDeliveryPageState extends State<CompleteDeliveryPage> {
  File? _image;

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitOrder() async {
    print('Submit Order');
    if (_image == null) {
      print('No image selected');
      return;
    }

    final path =
        'delivery-partner/sales-order/${widget.customerPhone}/${widget.orderDate}';

    final ref = FirebaseStorage.instance.ref().child(path);
    print("Size ${_image!.path}");
    try {
      await ref.putFile(_image!);
      print('Upload successful');
    } catch (e) {
      print('Upload failed: $e');
    }
    /*
    final storageRef = FirebaseStorage.instance.ref().child("files/uid");
    try {
      final listResult = await storageRef.listAll();
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      print("Failed with error '${e.code}': ${e.message}");
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Delivery'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (_image != null) // This adds margin around the container
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // This adds the rounded borders
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(
                          0.5), // Shadow color with some transparency
                      spreadRadius: 2, // Extent of the shadow spread
                      blurRadius: 4, // How blurry the shadow should be
                      offset: const Offset(0, 3), // Changes position of shadow
                    ),
                  ],
                ),
                child: ClipRRect(
                  // This is used to clip the image with rounded corners
                  borderRadius: BorderRadius.circular(
                      10.0), // The same radius as the Container's border
                  child: Image.file(_image!),
                ),
              ),
            ElevatedButton(
              onPressed: _takePicture,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_enhance_outlined),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Take Picture',
                    style: TextStyle(
                        color: Color.fromRGBO(98, 0, 238, 1), fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (_image != null) {
                  _submitOrder();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        elevation: 4.0,
                        shape: const RoundedRectangleBorder(
                          // Set the shape of the dialog
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        title: const Text("Take Picture"),
                        content: const Center(
                          child: Text('Please take picture'),
                        ),
                        actions: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color.fromRGBO(
                                  98, 0, 238, 1), // Button text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(98, 0, 238, 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 65, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_box_rounded,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Submit Order',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
