import 'dart:convert';
import 'dart:io';
import 'package:delivery/home/home.dart';
import 'package:delivery/utils/constants.dart';
import 'package:delivery/utils/network/service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CompleteDeliveryPage extends StatefulWidget {
  const CompleteDeliveryPage(
      {super.key,
      required this.customerPhone,
      required this.orderDate,
      required this.orderId});
  final String customerPhone;
  final String orderDate;
  final int orderId;

  @override
  State<CompleteDeliveryPage> createState() => _CompleteDeliveryPageState();
}

class _CompleteDeliveryPageState extends State<CompleteDeliveryPage> {
  File? _image;
  UploadTask? uploadTask;
  final _storage = const FlutterSecureStorage();

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File? compressedFile = await _compressFile(File(pickedFile.path));
      setState(() {
        _image = compressedFile;
      });
    }
  }

  Future<File?> _compressFile(File file) async {
    final String targetPath = '${file.path}_compressed.jpg';
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 50, // Adjust the quality as needed
      rotate: 0, // Adjust the rotation as needed
    );

    File resultImg = File(result!.path);

    print('Original file size: ${file.lengthSync()}');
    print('Compressed file size: ${resultImg.lengthSync()}');

    return resultImg;
  }

  Future<void> submitOrder(BuildContext context) async {
    print('Submit Order');
    final partnerPhone = await _storage.read(key: 'phone');

    if (_image == null) {
      print('No image selected');
      return;
    }

    final path =
        'delivery-partner/sales-order/${widget.customerPhone}/${widget.orderDate}';
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      setState(() {
        uploadTask = ref.putFile(_image!);
      });
      final snapshot = await uploadTask!.whenComplete(() => {});
      final urlDownloaded = await snapshot.ref.getDownloadURL();
      print('Downloaded Link: $urlDownloaded');
      setState(() {
        uploadTask = null;
      });

      // Constructing the request body
      final body = {
        'phone': partnerPhone,
        'sales_order_id': widget.orderId,
        'image': urlDownloaded,
      };

      final networkService = NetworkService();

      final response = await networkService.postWithAuth(
          '/delivery-partner-complete-order',
          additionalData: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final result = DeliveryCompletionResult.fromJson(responseData);

        // Showing the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Order Completed'),
              content: Column(
                children: [
                  Image.network(result.image),
                  Text(
                      'Order ID: ${result.salesOrderID}\nStatus: ${result.orderStatus}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Next'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            const HomePage())); // Navigate back to homepage
                  },
                ),
              ],
            );
          },
        );
      } else {
        print(
            'Failed to complete the order: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Upload failed or request failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Delivery'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            buildProgess(),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (_image != null) {
                  submitOrder(context);
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
                    'Complete Order',
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

  Widget buildProgess() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(height: 10);
        }
      });
}

class DeliveryCompletionResult {
  final int salesOrderID;
  final String orderStatus;
  final String image;

  DeliveryCompletionResult(
      {required this.salesOrderID,
      required this.orderStatus,
      required this.image});

  // Factory constructor to create a DeliveryCompletionResult instance from a JSON map
  factory DeliveryCompletionResult.fromJson(Map<String, dynamic> json) {
    return DeliveryCompletionResult(
      salesOrderID: json['sales_order_id'],
      orderStatus: json['order_status'],
      image: json['image'],
    );
  }
}
