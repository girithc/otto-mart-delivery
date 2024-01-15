import 'dart:convert';

import 'package:delivery/onboarding/login/login.dart';
import 'package:delivery/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  OrderAssigned? orderAssigned;
  bool isCheckingOrders = false;
  String greetingName = "Partner"; // Default greeting name
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadName();
    // ... other initializations ...
  }

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
    String phone = '1234567890';
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    final response = await http.post(
      Uri.parse('$baseUrl/delivery-partner-check-order'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        orderAssigned = OrderAssigned.fromJson(jsonDecode(response.body));
        isCheckingOrders = false;
      });
    } else {
      // Handle error...
      setState(() {
        isCheckingOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 80,
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
          )),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                if (!isCheckingOrders) {
                  checkForOrders();
                }
              },
              child: isCheckingOrders
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
                  : buildCheckOrdersTile(context),
            ),
            const SizedBox(height: 10),
            orderAssigned != null
                ? buildOrderAssignedWidget()
                : buildNoOrderWidget(context),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
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
                child: const Center(
                  child: Text(
                    'Delivery History',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
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
                child: const Center(
                  child: Text(
                    'Earnings',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCheckOrdersTile(BuildContext context) {
    return Center(
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
    );
  }

  Widget buildNoOrderWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
        child: const Center(
          child: Text(
            'No Current Order',
            style: TextStyle(
                fontSize: 25,
                color: Colors.black54,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Widget buildOrderAssignedWidget() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      5), // Adjust for more squarish shape
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15), // Inner padding of the button
              ),
              child: const Text(
                'Accept Order',
                style: TextStyle(
                    fontSize: 27,
                    color: Colors.black,
                    fontWeight: FontWeight.normal),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Skip Order',
              style: TextStyle(fontSize: 20, color: Colors.white),
            )
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
