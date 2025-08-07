import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'medicine_extraction_page.dart';
import 'medicine_search_page.dart';

class FilepickerPage extends StatefulWidget {
  const FilepickerPage({super.key});

  @override
  State<FilepickerPage> createState() => _FilepickerPageState();
}

class _FilepickerPageState extends State<FilepickerPage> {
  File? selectedFile;
  bool isProcessing = false;
  List<String> allowedExtension = ['pdf', 'jpg', 'png', 'jpeg'];

  void filepicked() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtension,
    );

    // Check if widget is still mounted after async operation
    if (!mounted) return;

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Prescription uploaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // User cancelled file picking - don't show error dialog
      return;
    }
  }

  void processPrescription() async {
    if (selectedFile == null) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // Simulate processing delay - replace with actual OCR/parsing logic
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // TODO: Implement actual prescription parsing here
      // For now, navigate to medicine extraction page with dummy data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicineExtractionPage(
            prescriptionFile: selectedFile!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error processing prescription: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Prescription"),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.green[50],
        width: double.infinity,
        height: screenSize.height, // Force full height utilization
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height -
                  (AppBar().preferredSize.height +
                      MediaQuery.of(context).padding.top +
                      40), // Account for AppBar and padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Add some top padding to center content better
                const SizedBox(height: 40),

                // Header
                const Icon(
                  Icons.medical_services,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Jan Aushadhi Sarthak",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Upload your prescription to find generic medicines",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // File selection card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (selectedFile != null) ...[
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Selected: ${selectedFile!.path.split(Platform.pathSeparator).last}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        ] else ...[
                          const Icon(
                            Icons.cloud_upload,
                            color: Colors.grey,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "No prescription selected",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Upload button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isProcessing ? null : filepicked,
                            icon: const Icon(Icons.file_upload),
                            label: Text(selectedFile == null
                                ? "Choose Prescription"
                                : "Change File"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Process button
                        if (selectedFile != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  isProcessing ? null : processPrescription,
                              icon: isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.analytics),
                              label: Text(isProcessing
                                  ? "Processing..."
                                  : "Parse Prescription"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Supported formats info
                const Text(
                  "Supported formats: PDF, JPG, PNG, JPEG",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                // Alternative option - direct search
                const Divider(),
                const SizedBox(height: 20),

                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.blue,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Search directly without prescription",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Find Jan Aushadhi alternatives by typing medicine names",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MedicineSearchPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search),
                            label: const Text("Search Medicines"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
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
