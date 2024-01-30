import 'package:delivery/firebase/firebase_api.dart';
import 'package:delivery/firebase/order.dart';
import 'package:delivery/firebase_options.dart';
import 'package:delivery/home/home.dart';
import 'package:delivery/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:delivery/onboarding/login/login.dart'; // Import your Phone/Login page here

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    // Check if any Firebase apps have been initialized
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const InitializerWidget(),
      navigatorKey: navigatorKey,
      routes: {
        '/order': (context) => const OrderPage(),
        // Other routes
      },
    );
  }
}

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({Key? key}) : super(key: key);

  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    String? partnerId = await storage.read(key: 'partnerId');
    if (partnerId != null) {
      var response = await http.post(
        Uri.parse('$baseUrl/delivery-partner-login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'partnerId': partnerId}),
      );

      // Decode the JSON response
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        navigateToLogin();
      }
    } else {
      navigateToLogin();
    }
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyPhone()));
  }

  @override
  Widget build(BuildContext context) {
// You can show a loading indicator while the check is being performed
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
