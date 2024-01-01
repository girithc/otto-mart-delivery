import 'dart:convert';
import 'package:delivery/home/home.dart';
import 'package:delivery/onboarding/legal/privacy.dart';
import 'package:delivery/onboarding/legal/terms.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

// Main widget for phone number verification
class MyPhone extends StatefulWidget {
  const MyPhone({super.key});

  @override
  _MyPhoneState createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  bool isTesterVersion = false; // To track the state of the checkbox

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    countryController.text = "+91";
    super.initState();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Form(
          key: formKey,
          child: Container(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icon/icon.jpeg',
                    height: 250,
                  ),
                  const Text(
                    "Delivery Partner",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 20, 2, 79)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Phone Verification",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 80, // Increased height for larger input boxes
                    child: Pinput(
                      length: 10, // Set the length of the input
                      controller: phoneNumberController,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      onSubmitted: (pin) {
                        // Handle submission logic here
                      },
                      defaultPinTheme: PinTheme(
                        width: 60, // Increased width for larger input boxes
                        height: 60, // Increased height for larger input boxes
                        decoration: BoxDecoration(
                          color:
                              Colors.white, // Uniform color for each input box
                          border: Border.all(
                            color: Colors.deepPurpleAccent, // Border color
                            width: 2, // Border width
                          ),
                          borderRadius:
                              BorderRadius.circular(10), // More rounded borders
                        ),
                        textStyle: const TextStyle(
                          fontSize:
                              26, // Larger font size for better visibility
                          color: Colors.black, // Text color
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors
                              .white, // Color of the input box when focused
                          border: Border.all(
                            color:
                                Colors.greenAccent, // Border color when focused
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 28,
                          color: Colors.black, // Text color when focused
                        ),
                      ),
                      // Add more customization to Pinput as needed
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        _showSnackbar('Login Initiated');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.0,
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Terms(),
                      ),
                    );
                  },
                  child: const Text('Terms and Conditions'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Privacy(),
                      ),
                    );
                  },
                  child: const Text('Privacy Policy'),
                ),
              ],
            ),
          ),
        ));
  }
}
