import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:delivery/utils/network/service.dart'; // Adjusted import for delivery context

class LoginProvider with ChangeNotifier {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<bool> checkLogin() async {
    String? phone = await storage.read(key: "phone");
    String exists = await checkDeliveryExists(phone!); // Adjusted method name
    if (exists.length == 10) {
      // Assuming the 'exists' logic remains the same
      return true;
    }

    return false;
  }

  Future<String> checkDeliveryExists(String phoneNumber) async {
    // Adjusted method name
    try {
      final Map<String, dynamic> requestData = {"phone": phoneNumber};

      final networkService = NetworkService();
      var response = await networkService.postWithAuth(
          '/login-delivery', // Adjusted endpoint
          additionalData: requestData);
      // Send the POST request

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Assuming the API returns a JSON object with a field that indicates if the delivery exists
        final Delivery delivery =
            Delivery.fromJson(data); // Adjusted to Delivery
        print("Delivery: ${delivery.id} ${delivery.phone}");
        await storage.write(
            key: 'deliveryId', value: delivery.id.toString()); // Adjusted key
        await storage.write(key: 'phone', value: delivery.phone);
        await storage.write(key: 'name', value: delivery.name);
        await storage.write(
            key: 'authToken',
            value: delivery.token); // Assuming similar fields for delivery

        return data[
            'phone']; // Replace 'exists' with the actual field name if different
      } else {
        // Handle non-200 responses
        print('Server error: ${response.statusCode}');
        print(response.body);
        return 'error';
      }
    } catch (e) {
      print('Error occurred: $e');
      return 'error';
    }
  }
}

class Delivery {
  // Adjusted class name
  final int id;
  final String name;
  final String phone;
  final String address;
  final String createdAt;
  final String token;

  Delivery({
    // Constructor name adjusted
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.token,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    // Factory constructor name adjusted
    return Delivery(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      createdAt: json['created_at'],
      token: json['token'],
    );
  }
}
