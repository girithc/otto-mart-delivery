import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delivery/utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NetworkService {
  final String _baseUrl = baseUrl; // Base URL for the API
  String? phone; // User's phone number
  String? token; // Authentication token
  final storage = const FlutterSecureStorage();

  Future<http.Response> postWithAuth(String endpoint,
      {Map<String, dynamic>? additionalData}) async {
    // Ensure initialization is complete before proceeding

    phone = await storage.read(key: 'phone');
    token = await storage.read(key: 'authToken');

    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};

    Map<String, dynamic> authBody = {
      'phone_auth': phone,
      'token_auth': token,
    };

    // Add additional data if provided
    if (additionalData != null &&
        endpoint != '/verify-otp-delivery-partner' &&
        endpoint != '/send-otp-delivery-partner') {
      additionalData.addAll(authBody);
    }

    print("\n");
    print("URL: $url");
    print("Headers: $headers");
    print("Body: $additionalData");
    print("\n");

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(additionalData),
    );

    return response;
  }
}
