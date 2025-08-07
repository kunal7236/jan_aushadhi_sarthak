import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jan_aushadhi_sarthak/filepicker_page.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FilepickerPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;

    // More responsive sizing based on screen dimensions
    final isTablet = screenSize.width > 600;
    final basePercentage =
        isTablet ? 0.5 : 0.8; // Smaller on tablets, larger on phones
    final imageSize = screenSize.width * basePercentage;
    final maxImageSize = screenSize.height * 0.45; // Use more vertical space
    final minImageSize = 200.0; // Minimum size for very small screens

    // Calculate final size with bounds
    double finalImageSize = imageSize;
    if (finalImageSize > maxImageSize) finalImageSize = maxImageSize;
    if (finalImageSize < minImageSize) finalImageSize = minImageSize;

    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 90, 127, 93), // Changed from white to green
      body: SizedBox(
        width: double.infinity,
        height: double.infinity, // Force full screen utilization
        child: SafeArea(
          // Add SafeArea for better compatibility
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Add padding for safety
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: finalImageSize,
                    width: finalImageSize,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 87, 124, 91), // Background color around image
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/images/JanAushadhi App Icon.png",
                        fit: BoxFit
                            .contain, // Changed to contain to show background color
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: finalImageSize,
                            width: finalImageSize,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: finalImageSize *
                                      0.16, // Responsive icon size
                                  color: Colors.grey,
                                ),
                                SizedBox(height: finalImageSize * 0.03),
                                Text(
                                  "Splash Image\nNot Found",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenSize.width *
                                        0.04, // Responsive text
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                      height: screenSize.height * 0.03), // Responsive spacing
                  const CircularProgressIndicator(),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize:
                          screenSize.width * 0.045, // Responsive text size
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
