import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              onTap: () => {},
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
