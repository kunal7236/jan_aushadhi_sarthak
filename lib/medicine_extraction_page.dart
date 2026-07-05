import 'dart:io';
import 'package:flutter/material.dart';
import 'models/medicine_model.dart';
import 'services/prescription_service.dart';
import 'medicine_search_page.dart';

class MedicineExtractionPage extends StatefulWidget {
  final File prescriptionFile;

  const MedicineExtractionPage({
    super.key,
    required this.prescriptionFile,
  });

  @override
  State<MedicineExtractionPage> createState() => _MedicineExtractionPageState();
}

class _MedicineExtractionPageState extends State<MedicineExtractionPage> {
  List<Medicine> extractedMedicines = [];
  bool isLoading = true;
  double confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _extractMedicines();
  }

  Future<void> _extractMedicines() async {
    try {
      // Use actual OCR service to parse the prescription
      final PrescriptionParseResult result =
          await PrescriptionParser.parseImage(widget.prescriptionFile);

      if (mounted) {
        setState(() {
          extractedMedicines = result.extractedMedicines;
          confidence = result.confidence;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unable to extract medicines. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editMedicine(int index, String newName) {
    setState(() {
      extractedMedicines[index].commercialName = newName;
      extractedMedicines[index].isVerified = true;
    });
  }

  void _verifyMedicine(int index) {
    setState(() {
      extractedMedicines[index].isVerified = true;
    });
  }

  void _selectAllMedicines() {
    setState(() {
      for (final medicine in extractedMedicines) {
        medicine.isVerified = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Extracted Medicines"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.green[50],
        width: double.infinity,
        height: screenSize.height, // Force full height utilization
        child: Column(
          children: [
            if (!isLoading)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Confidence: ${(confidence * 100).toInt()}% • Extracted: ${extractedMedicines.length} medicines",
                  style: TextStyle(
                    fontSize: 12,
                    color: confidence > 0.7 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (!isLoading && extractedMedicines.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _selectAllMedicines,
                  icon: const Icon(Icons.done_all),
                  label: const Text("Select All"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    side: BorderSide(color: Colors.green[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Loading or medicines list
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Extracting medicines from prescription..."),
                          SizedBox(height: 8),
                          Text(
                            "This may take a few seconds",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : extractedMedicines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No medicines found",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "The image may be unclear or doesn't contain medicine names.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text("Try Another Image"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: extractedMedicines.length,
                          itemBuilder: (context, index) {
                            final medicine = extractedMedicines[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  medicine.isVerified
                                      ? Icons.check_circle
                                      : Icons.help_outline,
                                  color: medicine.isVerified
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                title: Text(
                                  medicine.commercialName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: medicine.isVerified
                                        ? Colors.black
                                        : Colors.grey[700],
                                  ),
                                ),
                                subtitle: Text(
                                  medicine.isVerified
                                      ? "Verified"
                                      : "Needs verification",
                                  style: TextStyle(
                                    color: medicine.isVerified
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showEditDialog(index),
                                    ),
                                    if (!medicine.isVerified)
                                      IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () => _verifyMedicine(index),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Bottom actions
            if (!isLoading) ...[
              const SizedBox(height: 16),

              // Add medicine manually button (always visible)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAddMedicineDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Medicine Manually"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[600],
                    side: BorderSide(color: Colors.green[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Find JanAushadhi alternatives button (only when medicines exist)
              if (extractedMedicines.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: extractedMedicines.any((m) => m.isVerified)
                        ? () {
                            final fileName = widget.prescriptionFile.path
                                .split(Platform.pathSeparator)
                                .last;
                            final dotIndex = fileName.lastIndexOf('.');
                            final draftTitle = dotIndex > 0
                                ? fileName.substring(0, dotIndex)
                                : fileName;

                            // Get verified medicines
                            List<String> verifiedMedicines = extractedMedicines
                                .where((m) => m.isVerified)
                                .map((m) => m.commercialName)
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicineSearchPage(
                                  initialMedicines: verifiedMedicines,
                                  initialDraftTitle: draftTitle,
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.search),
                    label: const Text("Find JanAushadhi Alternatives"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              if (extractedMedicines.isNotEmpty)
                Text(
                  "${extractedMedicines.where((m) => m.isVerified).length}/${extractedMedicines.length} medicines verified",
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditDialog(int index) {
    final controller =
        TextEditingController(text: extractedMedicines[index].commercialName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Medicine Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Medicine Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _editMedicine(index, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Medicine Manually"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter the medicine name as it appears on your prescription:",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder(),
                hintText: "e.g., Paracetamol, Crocin, etc.",
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  extractedMedicines.add(Medicine(
                    commercialName: controller.text.trim(),
                    isVerified: true, // Manual entries are pre-verified
                  ));
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Added ${controller.text.trim()}"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
