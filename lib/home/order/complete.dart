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
import 'package:url_launcher/url_launcher.dart';

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
  OrderDetails? orderDetails;
  bool isLoading = true;
  TextEditingController amountCollectedController = TextEditingController();

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

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: "",
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      fillColor: Color.fromARGB(255, 255, 189, 208),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration inputDecorationGreen(String label) {
    return InputDecoration(
      labelText: "",
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      fillColor: Color.fromARGB(255, 139, 255, 161),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
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
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content:
                  const Text('Please take a picture to complete the order.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          });
      return;
    }

    // Validate amount collected
    final amountCollected = double.tryParse(amountCollectedController.text);
    if (amountCollected == null ||
        orderDetails == null ||
        amountCollected != orderDetails!.subtotal) {
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Amount Mismatch'),
              content: const Text(
                  'The collected amount does not match order total. Please verify and try again.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          });
      return; // Stop further execution if validation fails
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
        'amount_collected': amountCollected,
        'message': 'Order Completed Successfully.'
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

  fetchOrderDetails() async {
    final partnerPhone = await _storage.read(key: 'phone');
    final networkService = NetworkService();

    Map<String, dynamic> body = {
      'delivery_partner_phone': partnerPhone,
      'customer_phone': widget.customerPhone,
      'sales_order_id': widget.orderId,
    };

    final response = await networkService.postWithAuth(
        '/delivery-partner-get-order-details',
        additionalData: body);
    print("Order Details: ${response.body}  ");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      setState(() {
        orderDetails = OrderDetails.fromJson(responseData);
        isLoading = false;
      });
    } else {
      print('Failed to fetch order details: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Delivery'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                              offset: const Offset(
                                  0, 3), // Changes position of shadow
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
                    buildProgess(),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Customer Info'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('Name',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                          '${orderDetails!.customerName}',
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                    SizedBox(height: 8), // Added spacing
                                    Text('Phone',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                          '${orderDetails!.customerPhone}',
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                    SizedBox(height: 8), // Added spacing
                                    Text('Address',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                        '${orderDetails!.deliveryAddress.streetAddress}\n${orderDetails!.deliveryAddress.lineOneAddress}\n${orderDetails!.deliveryAddress.lineTwoAddress}',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        double latitude = orderDetails!
                                            .deliveryAddress
                                            .latitude; // Example latitude
                                        double longitude = orderDetails!
                                            .deliveryAddress
                                            .longitude; // Example longitude
                                        Uri googleMapsUri = Uri.parse(
                                            "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

                                        if (await canLaunchUrl(googleMapsUri)) {
                                          await launchUrl(googleMapsUri);
                                        } else {
                                          throw 'Could not open the map.';
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        padding: EdgeInsets.all(8),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Text("Google Map",
                                            style: TextStyle(
                                              fontSize: 16,
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 122, 213, 255),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              spreadRadius: 0,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              "CUSTOMER INFO  ",
                              style: TextStyle(fontSize: 16),
                            ),
                            Icon(Icons.info_outline)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    orderDetails!.paymentType == "cash"
                        ? Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("Amount To Collect"),
                              ),
                              SizedBox(height: 5),
                              TextField(
                                decoration: inputDecoration(''),
                                readOnly: true,
                                controller: TextEditingController(
                                    text: orderDetails!.subtotal.toString() ??
                                        ""),
                              ),
                              SizedBox(height: 20),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("Amount Collected"),
                              ),
                              SizedBox(height: 5),
                              TextField(
                                decoration: inputDecorationGreen(''),
                                controller: amountCollectedController,
                              ),
                            ],
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.greenAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.25),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "ORDER IS PREPAID  ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.check_circle_outline,
                                    color: Colors.black)
                              ],
                            ),
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    _image == null
                        ? ElevatedButton(
                            onPressed: _takePicture,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 15),
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
                                      color: Color.fromRGBO(98, 0, 238, 1),
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      title: const Text("Take Picture"),
                                      content: const Center(
                                        child: Text('Please take picture'),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor:
                                                const Color.fromRGBO(98, 0, 238,
                                                    1), // Button text color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Close',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
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
                              backgroundColor:
                                  const Color.fromRGBO(98, 0, 238, 1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 65, vertical: 15),
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildCompleteOrderWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Rounded borders
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25), // Shadow color
              spreadRadius: 0,
              blurRadius: 20, // Increased shadow blur
              offset: const Offset(0, 10), // Increased vertical offset
            ),
          ],
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // Rounded borders
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25), // Shadow color
                      spreadRadius: 0,
                      blurRadius: 20, // Increased shadow blur
                      offset: const Offset(0, 10), // Increased vertical offset
                    ),
                  ],
                ),
                // Rest of your container styling...
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: Colors.black, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Complete Order',
                      style: TextStyle(fontSize: 25, color: Colors.black),
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

  Widget buildTakePictureWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Rounded borders
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25), // Shadow color
              spreadRadius: 0,
              blurRadius: 20, // Increased shadow blur
              offset: const Offset(0, 10), // Increased vertical offset
            ),
          ],
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // Rounded borders
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25), // Shadow color
                      spreadRadius: 0,
                      blurRadius: 20, // Increased shadow blur
                      offset: const Offset(0, 10), // Increased vertical offset
                    ),
                  ],
                ),
                // Rest of your container styling...
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: Colors.black, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Complete Order',
                      style: TextStyle(fontSize: 25, color: Colors.black),
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

class OrderDetails {
  final int id;
  final int deliveryPartnerId;
  final int cartId;
  final int storeId;
  final String storeName;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final int subtotal;
  final String orderDate;
  final String paymentType;
  final DeliveryAddress deliveryAddress;

  OrderDetails({
    required this.id,
    required this.deliveryPartnerId,
    required this.cartId,
    required this.storeId,
    required this.storeName,
    required this.customerId,
    this.customerName = '',
    required this.customerPhone,
    required this.subtotal,
    required this.orderDate,
    required this.paymentType,
    required this.deliveryAddress,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'],
      deliveryPartnerId: json['delivery_partner_id'],
      cartId: json['cart_id'],
      storeId: json['store_id'],
      storeName: json['store_name'],
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'],
      subtotal: json['subtotal'],
      orderDate: json['order_date'],
      paymentType: json['payment_type'],
      deliveryAddress: DeliveryAddress.fromJson(json['delivery_address']),
    );
  }
}

class DeliveryAddress {
  final String streetAddress;
  final String lineOneAddress;
  final String lineTwoAddress;
  final double latitude;
  final double longitude;

  DeliveryAddress({
    required this.streetAddress,
    required this.lineOneAddress,
    required this.lineTwoAddress,
    required this.latitude,
    required this.longitude,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      streetAddress: json['street_address'],
      lineOneAddress: json['line_one_address'],
      lineTwoAddress: json['line_two_address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
