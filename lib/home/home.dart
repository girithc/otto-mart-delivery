import 'dart:async';
import 'dart:convert';

import 'package:delivery/home/order/assign.dart';
import 'package:delivery/home/order/complete.dart';
import 'package:delivery/home/order/onroute.dart';
import 'package:delivery/onboarding/login/phone.dart';
import 'package:delivery/utils/network/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  OrderAssigned? orderAssigned;
  OrderAcceptedDP? orderAccepted;

  bool isCheckingOrders = false;
  bool shouldShowAppBar = true;
  String greetingName = "Partner"; // Default greeting name
  final _formKey = GlobalKey<FormBuilderState>();
  final navigation = ["Home", "Accept", "Pickup", "OnRoute", "Complete"];
  var currentState = "Home";

  final _storage = const FlutterSecureStorage();
  Duration duration = const Duration(minutes: 1); // Starting point of the timer

  @override
  void initState() {
    super.initState();
    _loadName();
    checkForOrders();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<void> _clearSecureStorage() async {
    await _storage.deleteAll();
  }

  Future<void> _loadName() async {
    String? name = await _storage.read(key: 'name');
    if (name != null && name.isNotEmpty) {
      setState(() {
        greetingName = name;
      });
    }
  }

  Future<void> checkForOrders() async {
    setState(() {
      isCheckingOrders = true;
    });

    // Simulate a network request
    final phone = await _storage.read(key: "phone");
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    final networkService = NetworkService();
    Map<String, dynamic> body = {
      'phone': phone,
    };

    final response = await networkService.postWithAuth(
        '/delivery-partner-check-order', // Adjusted endpoint
        additionalData: body);

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        orderAssigned = OrderAssigned.fromJson(jsonDecode(response.body));
        isCheckingOrders = false;
        currentState = "Accept";
        shouldShowAppBar = false;
      });
      startTimer();
    } else {
      // Handle error...
      setState(() {
        isCheckingOrders = false;
      });
    }
  }

  Future<OrderAcceptedDP?> acceptOrder() async {
    String? phone = await _storage.read(key: 'phone');
    Map<String, dynamic> requestData = {
      'phone': phone,
      'sales_order_id': orderAssigned?.id
    };
    try {
      final networkService = NetworkService();
      final response = await networkService.postWithAuth(
          '/delivery-partner-accept-order', // Adjusted endpoint
          additionalData: requestData);

      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final OrderAcceptedDP order =
            OrderAcceptedDP.fromJson(json.decode(response.body));

        return order;
      } else {
        // Handle non-200 responses
        throw Exception(
            'Failed to accept order. Status code: ${response.body}');
      }
    } catch (e) {
      // Handle network errors, parsing errors, etc
      throw Exception('Error accepting order: $e');
    }
  }

  Future<PickupOrderResult?> pickupOrder() async {
    String? phone = await _storage.read(key: 'phone');
    Map<String, dynamic> data = {
      'phone': phone,
      'sales_order_id': orderAccepted?.id,
    };

    try {
      final networkService = NetworkService();
      final response = await networkService.postWithAuth(
        '/delivery-partner-pickup-order',
        additionalData: data,
      );

      print("response ${response.body}");
      print("response: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Sucess: ${response.body}");
        return PickupOrderResult(
            orderInfo: PickupOrderInfo.fromJson(json.decode(response.body)),
            success: true);
      } else if (response.statusCode == 304) {
        // Return null for status code 304
        print(response.body);
        return PickupOrderResult(orderInfo: null, success: true);
      } else if (response.statusCode == 423 || response.statusCode == 500) {
        return PickupOrderResult(orderInfo: null, success: false);
      } else {
        print(response.body);

        // Handle other non-200 responses
        throw Exception(
            'Failed to accept order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors, parsing errors, etc
      throw Exception('Error accepting order: $e');
    }
  }

  void _showQRCodeDialog(BuildContext context) async {
    final String? phone = await _storage.read(key: 'phone');

    // Ensure phone is not null, otherwise, use a default value or handle the error
    final String phoneValue = phone ?? 'Unknown';

    // Use the phoneValue in your data string
    final String data = "$phoneValue-${orderAccepted?.id}";

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
          title: const Text("Order QR Code"),
          content: SizedBox(
            height: 300,
            width: 300,
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 300.0,
              gapless: false,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    const Color.fromRGBO(98, 0, 238, 1), // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  void _showOrderNotPackedDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(data),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration.inSeconds == 0) {
        timer.cancel();
        // Handle what happens when the timer reaches 0
      } else {
        setState(() {
          duration = duration - const Duration(seconds: 1);
        });
      }
    });
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: shouldShowAppBar
          ? PreferredSize(
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.07),
              child: buildAppBar(),
            )
          : null,
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildAppBar() {
    switch (currentState) {
      case "Accept":
        return Container();
      case "Pickup":
        return Container();
      default:
        return defaultAppBar();
    }
  }

  Widget defaultAppBar() {
    return AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,
        title: Text(
          'Hi $greetingName',
          style: const TextStyle(fontSize: 25, color: Colors.black),
        ),
        centerTitle: true,
        leading: Container(
          height: 30.0, // Set height of the container
          width: 30.0, // Set width of the container
          margin: const EdgeInsets.only(left: 10),
          decoration: const BoxDecoration(
            // Background color of the container
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black45, Colors.black87], // Gradient colors
            ), // Circular shape
          ),
          child: IconButton(
              icon: const Icon(Icons.person),
              color: Colors.white, // Icon color
              onPressed: () async {
                await _clearSecureStorage();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MyPhone()),
                  (Route<dynamic> route) => false,
                );
              }),
        ));
  }

  Widget buildBottomNavigationBar() {
    // Determine which widget to return based on the currentState
    switch (currentState) {
      case "Pickup":
        return buildPickup();
      case "OnRoute":
      //return buildOnRoute();
      case "Complete":
      //return buildComplete();
      default:
        return buildDefaultBottomBar(); // Fallback for any undefined state
    }
  }

  Widget buildPickup() {
    return Container(
      alignment: Alignment.bottomCenter,
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  child: Icon(Icons.arrow_back_rounded),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "back",
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
          ),
          FormBuilder(
            key: _formKey,
            child: Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'orderno',
                          decoration: InputDecoration(
                            labelText: 'Order No.',
                            hintText: 'Order No.',
                            filled: true, // Enable filling of the input
                            fillColor: Colors.grey[
                                200], // Set light grey color as the background
                            border: OutlineInputBorder(
                              // Define the border
                              borderRadius: BorderRadius.circular(
                                  10.0), // Circular rounded border
                              borderSide: BorderSide.none, // No border side
                            ),
                          ),
                          initialValue: orderAccepted?.id.toString(),
                          validator: _requiredValidator,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'storename',
                          decoration: InputDecoration(
                            labelText: 'Store Name',
                            hintText: 'Store Name',
                            filled: true, // Enable filling of the input
                            fillColor: Colors.grey[
                                200], // Set light grey color as the background
                            border: OutlineInputBorder(
                              // Define the border
                              borderRadius: BorderRadius.circular(
                                  10.0), // Circular rounded border
                              borderSide: BorderSide.none, // No border side
                            ),
                          ),
                          readOnly: true,
                          initialValue: orderAccepted?.storeName,
                          validator: _requiredValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FormBuilderTextField(
                    name: 'storeaddress',
                    decoration: InputDecoration(
                      labelText: 'Store Address',
                      hintText: 'Store Address',
                      filled: true, // Enable filling of the input
                      fillColor: Colors
                          .grey[200], // Set light grey color as the background
                      border: OutlineInputBorder(
                        // Define the border
                        borderRadius: BorderRadius.circular(
                            10.0), // Circular rounded border
                        borderSide: BorderSide.none, // No border side
                      ),
                    ),
                    initialValue: orderAccepted?.storeAddress,
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'orderdatetime',
                          decoration: InputDecoration(
                            labelText: 'Order DateTime',
                            hintText: 'Order DateTime',
                            filled: true, // Enable filling of the input
                            fillColor: Colors.grey[
                                200], // Set light grey color as the background
                            border: OutlineInputBorder(
                              // Define the border
                              borderRadius: BorderRadius.circular(
                                  10.0), // Circular rounded border
                              borderSide: BorderSide.none, // No border side
                            ),
                          ),
                          initialValue:
                              orderAccepted?.orderDate.toIso8601String(),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'orderstatus',
                          decoration: InputDecoration(
                            labelText: 'Order Status',
                            hintText: 'Order Status',
                            filled: true, // Enable filling of the input
                            fillColor: Colors.grey[
                                200], // Set light grey color as the background
                            border: OutlineInputBorder(
                              // Define the border
                              borderRadius: BorderRadius.circular(
                                  10.0), // Circular rounded border
                              borderSide: BorderSide.none, // No border side
                            ),
                          ),
                          initialValue: orderAccepted?.orderStatus,
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      pickupOrder().then((value) {
                        print("Value $value ");
                        if (value != null) {
                          if (value.orderInfo != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnRoutePage(
                                  order: value.orderInfo!,
                                  orderId: orderAccepted!.id,
                                ),
                              ),
                            );
                          } else if (value.success == true) {
                            _showQRCodeDialog(context);
                          } else if (value.success == false) {
                            _showOrderNotPackedDialog(
                                context, "ORDER NOT PACKED");
                          }
                        } else {
                          _showOrderNotPackedDialog(context, "ERROR");
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(98, 0, 238, 1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 65, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Pick Up Order",
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDefaultBottomBar() {
    // Return a default bottom navigation bar
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.25,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          orderAssigned != null
              ? buildOrderAssignedWidget()
              : (isCheckingOrders
                  ? Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(10),
                        child: const LinearProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    )
                  : buildNoOrderWidget(context)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildNoOrderWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isCheckingOrders) {
          checkForOrders();
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
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
                      'Check for Orders',
                      style: TextStyle(fontSize: 25, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const Center(
              child: Text(
                'No Current Order',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black54,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderAssignedWidget() {
    return GestureDetector(
      onTap: () {
        acceptOrder().then((value) {
          if (value?.orderStatus == "arrived") {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CompleteDeliveryPage(
                  orderDate: value!.orderDate.toString(),
                  orderId: value.id,
                  customerPhone: value.customerPhone,
                ),
              ),
            );
          } else if (value != null) {
            orderAccepted = value;
            currentState = "Pickup";
            shouldShowAppBar = false;
            /*
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderAssignedPage(order: value),
              ),
            );
            */
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to accept order'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.20,
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Rounded borders
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurpleAccent,
              Colors.deepPurple,
            ], // Gradient colors
          ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                acceptOrder().then((value) {
                  if (value?.orderStatus == "arrived") {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CompleteDeliveryPage(
                          orderDate: value!.orderDate.toString(),
                          orderId: value.id,
                          customerPhone: value.customerPhone,
                        ),
                      ),
                    );
                  } else if (value != null) {
                    orderAccepted = value;
                    currentState = "Pickup";
                    shouldShowAppBar = false;
                    /*
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrderAssignedPage(order: value),
                      ),
                    );
                    */
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to accept order'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      5), // Adjust for more squarish shape
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 45,
                    vertical: 15), // Inner padding of the button
              ),
              child: const Text(
                'Accept Order',
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.normal),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderAssigned {
  final int id;
  final int deliveryPartnerId;
  final int storeId;
  final DateTime orderDate;
  final String orderStatus;
  final String deliveryPartnerStatus;

  OrderAssigned({
    required this.id,
    required this.deliveryPartnerId,
    required this.storeId,
    required this.orderDate,
    required this.orderStatus,
    required this.deliveryPartnerStatus,
  });

  factory OrderAssigned.fromJson(Map<String, dynamic> json) {
    return OrderAssigned(
      id: json['id'],
      deliveryPartnerId: json['delivery_partner_id'],
      storeId: json['store_id'],
      orderDate: DateTime.parse(json['order_date']),
      orderStatus: json['order_status'],
      deliveryPartnerStatus: json['order_dp_status'],
    );
  }
}

class OrderAcceptedDP {
  final int id;
  final int deliveryPartnerId;
  final int storeId;
  final String storeName;
  final String storeAddress;
  final DateTime orderDate;
  final String orderStatus;
  final String deliveryPartnerStatus;
  final String customerPhone;

  OrderAcceptedDP(
      {required this.id,
      required this.deliveryPartnerId,
      required this.storeId,
      required this.storeName,
      required this.storeAddress,
      required this.orderDate,
      required this.orderStatus,
      required this.deliveryPartnerStatus,
      required this.customerPhone});

  factory OrderAcceptedDP.fromJson(Map<String, dynamic> json) {
    return OrderAcceptedDP(
        id: json['id'],
        deliveryPartnerId: json['delivery_partner_id'],
        storeId: json['store_id'],
        storeName: json['store_name'],
        storeAddress: json['store_address'],
        orderDate: DateTime.parse(json['order_date']),
        orderStatus: json['order_status'],
        deliveryPartnerStatus: json['order_dp_status'],
        customerPhone: json['customer_phone']);
  }
}

class PickupOrderResult {
  final PickupOrderInfo? orderInfo;
  final bool? success;

  PickupOrderResult({this.orderInfo, this.success});
}

class PickupOrderInfo {
  final String customerName;
  final String customerPhone;
  final double latitude;
  final double longitude;
  final String lineOneAddress;
  final String lineTwoAddress;
  final String streetAddress;
  final String
      orderDate; // Assuming orderDate is a string, change if it's a DateTime
  final String orderStatus;

  PickupOrderInfo({
    required this.customerName,
    required this.customerPhone,
    required this.latitude,
    required this.longitude,
    required this.lineOneAddress,
    required this.lineTwoAddress,
    required this.streetAddress,
    required this.orderDate,
    required this.orderStatus,
  });

  factory PickupOrderInfo.fromJson(Map<String, dynamic> json) {
    return PickupOrderInfo(
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lineOneAddress: json['line_one_address'],
      lineTwoAddress: json['line_two_address'],
      streetAddress: json['street_address'],
      orderDate: json['order_date'],
      orderStatus: json['order_status'],
    );
  }
}
