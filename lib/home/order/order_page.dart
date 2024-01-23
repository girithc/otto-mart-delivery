import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Assigned'),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            FormBuilderTextField(
              name: 'flatBuildingName',
              decoration: InputDecoration(
                labelText: 'Order No.',
                hintText: 'Order No.',
                filled: true, // Enable filling of the input
                fillColor:
                    Colors.grey[200], // Set light grey color as the background
                border: OutlineInputBorder(
                  // Define the border
                  borderRadius:
                      BorderRadius.circular(10.0), // Circular rounded border
                  borderSide: BorderSide.none, // No border side
                ),
              ),
              initialValue: '',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 25),
            FormBuilderTextField(
              name: 'flatBuildingName',
              decoration: InputDecoration(
                labelText: 'Store Name',
                hintText: 'Store Name',
                filled: true, // Enable filling of the input
                fillColor:
                    Colors.grey[200], // Set light grey color as the background
                border: OutlineInputBorder(
                  // Define the border
                  borderRadius:
                      BorderRadius.circular(10.0), // Circular rounded border
                  borderSide: BorderSide.none, // No border side
                ),
              ),
              initialValue: '',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 25),
            FormBuilderTextField(
              name: 'landmark',
              decoration: InputDecoration(
                labelText: 'Store Address',
                hintText: 'Store Address',
                filled: true, // Enable filling of the input
                fillColor:
                    Colors.grey[200], // Set light grey color as the background
                border: OutlineInputBorder(
                  // Define the border
                  borderRadius:
                      BorderRadius.circular(10.0), // Circular rounded border
                  borderSide: BorderSide.none, // No border side
                ),
              ),
              initialValue: '',
            ),
            const SizedBox(height: 25),
            FormBuilderTextField(
              name: 'locality',
              decoration: InputDecoration(
                labelText: 'Order DateTime',
                hintText: 'Order DateTime',
                filled: true, // Enable filling of the input
                fillColor:
                    Colors.grey[200], // Set light grey color as the background
                border: OutlineInputBorder(
                  // Define the border
                  borderRadius:
                      BorderRadius.circular(10.0), // Circular rounded border
                  borderSide: BorderSide.none, // No border side
                ),
              ),
            ),
            const SizedBox(height: 25),
            FormBuilderTextField(
              name: 'lineOneAddress',
              decoration: InputDecoration(
                labelText: 'Order Status',
                hintText: 'Order Status',
                filled: true, // Enable filling of the input
                fillColor:
                    Colors.grey[200], // Set light grey color as the background
                border: OutlineInputBorder(
                  // Define the border
                  borderRadius:
                      BorderRadius.circular(10.0), // Circular rounded border
                  borderSide: BorderSide.none, // No border side
                ),
              ),
            ),
            const SizedBox(height: 25),
            FormBuilderTextField(
              name: 'lineTwoAddress',
              decoration: InputDecoration(
                labelText: 'Partner Status',
                hintText: 'Partner Status',
                filled: true, // Enable filling of the input
                fillColor:
                    Colors.grey[200], // Set light grey color as the background
                border: OutlineInputBorder(
                  // Define the border
                  borderRadius:
                      BorderRadius.circular(10.0), // Circular rounded border
                  borderSide: BorderSide.none, // No border side
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
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
            )
          ],
        ),
      ),
    );
  }
}
