import 'dart:convert';

import 'package:delivery/home/home.dart';
import 'package:delivery/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  OrderPage({required this.order, super.key});
  OrderAcceptedDP order;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _storage = const FlutterSecureStorage();

  bool picked = false;

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  Future<PickupOrderInfo?> pickupOrder() async {
    final Uri url = Uri.parse('$baseUrl/delivery-partner-pickup-order');

    String? phone = await _storage.read(key: 'partnerId');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'phone': phone, 'sales_order_id': widget.order.id}),
      );
      print("phone $phone, order id ${widget.order.id}");

      if (response.statusCode == 200) {
        return PickupOrderInfo.fromJson(json.decode(response.body));
      } else if (response.statusCode == 304) {
        // Return null for status code 304
        print(response.body);
        return null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Assigned'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              FormBuilderTextField(
                name: 'orderno',
                decoration: InputDecoration(
                  labelText: 'Order No.',
                  hintText: 'Order No.',
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
                initialValue: widget.order.id.toString(),
                validator: _requiredValidator,
                readOnly: true,
              ),
              const SizedBox(height: 25),
              FormBuilderTextField(
                name: 'storename',
                decoration: InputDecoration(
                  labelText: 'Store Name',
                  hintText: 'Store Name',
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
                initialValue: widget.order.storeName,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 25),
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
                    borderRadius:
                        BorderRadius.circular(10.0), // Circular rounded border
                    borderSide: BorderSide.none, // No border side
                  ),
                ),
                initialValue: widget.order.storeAddress,
                readOnly: true,
              ),
              const SizedBox(height: 25),
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
                      initialValue: widget.order.orderDate.toIso8601String(),
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
                      initialValue: widget.order.orderStatus,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              FormBuilderTextField(
                name: 'partnerstatus',
                decoration: InputDecoration(
                  labelText: 'Partner Status',
                  hintText: 'Partner Status',
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
                initialValue: widget.order.deliveryPartnerStatus,
                readOnly: true,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  pickupOrder().then((value) {
                    if (value != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order is dispatched"),
                          backgroundColor:
                              Colors.green, // Optional: for a green background
                        ),
                      );
                    } else {
                      _showQRCodeDialog(context, widget.order.id.toString());
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
    );
  }

  void _showQRCodeDialog(BuildContext context, String data) {
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
