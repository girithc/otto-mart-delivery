import 'dart:convert';

import 'package:delivery/home/home.dart';
import 'package:delivery/home/order/assign.dart';
import 'package:delivery/home/order/complete.dart';
import 'package:delivery/utils/network/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class OnRoutePage extends StatefulWidget {
  OnRoutePage({super.key, required this.order, required this.orderId});
  PickupOrderInfo order;

  int orderId;

  @override
  State<OnRoutePage> createState() => _OnRoutePageState();
}

class _OnRoutePageState extends State<OnRoutePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _storage = const FlutterSecureStorage();
  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  Future<bool> arriveAtPickup() async {
    // Simulate the arrival at the pickup location
    await Future.delayed(const Duration(seconds: 2));

    final phone = await _storage.read(key: "phone");

    final Map<String, dynamic> body = {
      'phone': phone,
      'sales_order_id': widget.orderId,
      'status': 'arrived',
    };
    final networkService = NetworkService();
    final response = await networkService
        .postWithAuth('/delivery-partner-arrive', additionalData: body);

    print(
        "Response: ${response.body} ${response.statusCode} ${response.reasonPhrase} ${response.request}");

    if (response.statusCode == 200) {
      // Assuming the response body is in JSON format and contains the expected fields
      final result =
          DeliveryPartnerArriveResult.fromJson(json.decode(response.body));

      // You can now use the result object for further logic if needed
      // For example, you might want to check the order status or log the sales order ID

      return result.salesOrderId == widget.orderId &&
          result.orderStatus == 'arrived';
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Delivery'),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.white,
          child: FormBuilder(
            key: _formKey,
            child: ListView(padding: const EdgeInsets.all(16.0), children: [
              FormBuilderTextField(
                name: 'customername',
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'Customer Name',
                  filled: true, // Enable filling of the input
                  fillColor: Colors
                      .grey[200], // Set light grey color as the background
                  border: OutlineInputBorder(
                    // Define the border
                    borderRadius:
                        BorderRadius.circular(10.0), // Circular rounded border
                    borderSide: BorderSide.none, // No border side
                  ),
                ),
                initialValue: widget.order.customerName,
                validator: _requiredValidator,
                readOnly: true,
              ),
              const SizedBox(height: 25),
              FormBuilderTextField(
                name: 'customerphone',
                decoration: InputDecoration(
                  labelText: 'Customer Phone',
                  hintText: 'Customer Phone',
                  filled: true, // Enable filling of the input
                  fillColor: Colors
                      .grey[200], // Set light grey color as the background
                  border: OutlineInputBorder(
                    // Define the border
                    borderRadius:
                        BorderRadius.circular(10.0), // Circular rounded border
                    borderSide: BorderSide.none, // No border side
                  ),
                ),
                readOnly: true,
                initialValue: widget.order.customerPhone,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 25),
              FormBuilderTextField(
                name: 'streetaddress',
                decoration: InputDecoration(
                  labelText: 'Street Address',
                  hintText: 'Street Address',
                  filled: true, // Enable filling of the input
                  fillColor: Colors
                      .grey[200], // Set light grey color as the background
                  border: OutlineInputBorder(
                    // Define the border
                    borderRadius:
                        BorderRadius.circular(10.0), // Circular rounded border
                    borderSide: BorderSide.none, // No border side
                  ),
                ),
                initialValue: widget.order.streetAddress,
                readOnly: true,
              ),
              const SizedBox(height: 25),
              FormBuilderTextField(
                name: 'addresslineone',
                decoration: InputDecoration(
                  labelText: 'Address Line 1',
                  hintText: 'Address Line 1',
                  filled: true, // Enable filling of the input
                  fillColor: Colors
                      .grey[200], // Set light grey color as the background
                  border: OutlineInputBorder(
                    // Define the border
                    borderRadius:
                        BorderRadius.circular(10.0), // Circular rounded border
                    borderSide: BorderSide.none, // No border side
                  ),
                ),
                initialValue: widget.order.lineOneAddress,
                readOnly: true,
              ),
              const SizedBox(height: 25),
              FormBuilderTextField(
                name: 'addresslinetwo',
                decoration: InputDecoration(
                  labelText: 'Address Line 2',
                  hintText: 'Address Line 2',
                  filled: true, // Enable filling of the input
                  fillColor: Colors
                      .grey[200], // Set light grey color as the background
                  border: OutlineInputBorder(
                    // Define the border
                    borderRadius:
                        BorderRadius.circular(10.0), // Circular rounded border
                    borderSide: BorderSide.none, // No border side
                  ),
                ),
                initialValue: widget.order.lineTwoAddress,
                readOnly: true,
              ),
              const SizedBox(height: 25),
              FormBuilderTextField(
                name: 'orderstatus',
                decoration: InputDecoration(
                  labelText: 'Order Status',
                  hintText: 'Order Status',
                  filled: true, // Enable filling of the input
                  fillColor: Colors
                      .grey[200], // Set light grey color as the background
                  border: OutlineInputBorder(
                    // Define the border
                    borderRadius:
                        BorderRadius.circular(10.0), // Circular rounded border
                    borderSide: BorderSide.none, // No border side
                  ),
                ),
                initialValue: widget.order.orderStatus,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Colors.tealAccent, // Light grey background
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // Rounded borders
                      ),
                    ),
                    onPressed: () async {
                      double latitude =
                          widget.order.latitude; // Example latitude
                      double longitude =
                          widget.order.longitude; // Example longitude
                      Uri googleMapsUri = Uri.parse(
                          "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

                      if (await canLaunchUrl(googleMapsUri)) {
                        await launchUrl(googleMapsUri);
                      } else {
                        throw 'Could not open the map.';
                      }
                    },
                    child: const Text(
                      'Google Maps',
                      style: TextStyle(
                        color: Colors.black, // Text color
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  arriveAtPickup().then((value) {
                    if (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CompleteDeliveryPage(
                                  customerPhone: widget.order.customerPhone,
                                  orderDate: widget.order.orderDate,
                                  orderId: widget.orderId,
                                )),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Error updating order status to arrived.'),
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CompleteDeliveryPage(
                                  customerPhone: widget.order.customerPhone,
                                  orderDate: widget.order.orderDate,
                                  orderId: widget.orderId,
                                )),
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(98, 0, 238, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 65, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Complete Delivery",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ]),
          ),
        ));
  }
}

class DeliveryPartnerArriveResult {
  final int salesOrderId;
  final String orderStatus;

  DeliveryPartnerArriveResult(
      {required this.salesOrderId, required this.orderStatus});

  // Factory constructor to create a DeliveryPartnerArriveResult from a map
  factory DeliveryPartnerArriveResult.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerArriveResult(
      salesOrderId: json['sales_order_id'],
      orderStatus: json['order_status'],
    );
  }
}
