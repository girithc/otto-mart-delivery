import 'package:delivery/home/order/assign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class OnRoutePage extends StatefulWidget {
  OnRoutePage({super.key, required this.order});
  PickupOrderInfo order;

  @override
  State<OnRoutePage> createState() => _OnRoutePageState();
}

class _OnRoutePageState extends State<OnRoutePage> {
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
        title: const Text('Delivery'),
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
              SizedBox(height: 25),
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
              const SizedBox(height: 25),
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
                    onPressed: () {
                      // Define what should happen when the button is pressed
                    },
                    child: Text(
                      'Google Maps',
                      style: TextStyle(
                          color: Colors.black, fontSize: 18 // Text color
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {},
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
            ],
          ),
        ),
      ),
    );
  }
}
