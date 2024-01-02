import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  OrderAssigned? orderAssigned;
  Future<void> checkForOrders() async {
    String phone = '1234567890';
    final response = await http.post(
      Uri.parse('/delivery-partner-check-order'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        orderAssigned = OrderAssigned.fromJson(jsonDecode(response.body));
      });
    } else {
      // Handle error...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 80,
          title: const Text(
            'Delivery',
            style: TextStyle(fontSize: 25, color: Colors.black),
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
                onPressed: () {}),
          )),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => {
                checkForOrders() // Now just calling the function
              },
              child: Center(
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
                        offset:
                            const Offset(0, 10), // Increased vertical offset
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the row contents horizontally
                    children: [
                      Icon(
                        Icons.refresh, // Refresh icon
                        color: Colors.black,
                        size: 30, // Icon color
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Check for Orders',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ), // Spacing between text and icon
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
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
