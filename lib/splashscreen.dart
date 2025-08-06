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
    final imageSize = screenSize.width * 0.6; // 60% of screen width
    final maxImageSize = 300.0; // Maximum size cap
    final finalImageSize = imageSize > maxImageSize ? maxImageSize : imageSize;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Add SafeArea for better compatibility
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Add padding for safety
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: finalImageSize,
                  width: finalImageSize,
                  child: Image.asset(
                    "assets/images/splash.jpg",
                    fit: BoxFit.contain,
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
                              size:
                                  finalImageSize * 0.16, // Responsive icon size
                              color: Colors.grey,
                            ),
                            SizedBox(height: finalImageSize * 0.03),
                            Text(
                              "Splash Image\nNot Found",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize:
                                    screenSize.width * 0.04, // Responsive text
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                    height: screenSize.height * 0.03), // Responsive spacing
                const CircularProgressIndicator(),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: screenSize.width * 0.045, // Responsive text size
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
