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
      PrescriptionParseResult result;

      String fileName = widget.prescriptionFile.path.toLowerCase();
      if (fileName.endsWith('.pdf')) {
        result = await PrescriptionParser.parsePDF(widget.prescriptionFile);
      } else {
        result = await PrescriptionParser.parseImage(widget.prescriptionFile);
      }

      if (mounted) {
        setState(() {
          extractedMedicines = result.extractedMedicines;
          confidence = result.confidence;
          isLoading = false;
        });

        // Show confidence score to user
        if (confidence < 0.5) {
          _showLowConfidenceWarning();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error extracting medicines: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLowConfidenceWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Low Confidence"),
        content: Text(
          "Text recognition confidence is ${(confidence * 100).toInt()}%. "
          "Please carefully verify the extracted medicine names.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
            // Header info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Please verify the extracted medicine names. You can edit them if needed.",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (!isLoading) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Confidence: ${(confidence * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 12,
                              color: confidence > 0.7
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Extracted: ${extractedMedicines.length} medicines",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
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

              // Find Jan Aushadhi alternatives button (only when medicines exist)
              if (extractedMedicines.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: extractedMedicines.any((m) => m.isVerified)
                        ? () {
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
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.search),
                    label: const Text("Find Jan Aushadhi Alternatives"),
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

// Placeholder for the next page - Generic Alternatives
class GenericAlternativesPage extends StatefulWidget {
  final List<Medicine> medicines;

  const GenericAlternativesPage({super.key, required this.medicines});

  @override
  State<GenericAlternativesPage> createState() =>
      _GenericAlternativesPageState();
}

class _GenericAlternativesPageState extends State<GenericAlternativesPage> {
  List<Medicine> processedMedicines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _findGenericNames();
  }

  Future<void> _findGenericNames() async {
    try {
      processedMedicines = List.from(widget.medicines);

      // Find generic names for each medicine
      for (Medicine medicine in processedMedicines) {
        Medicine? genericInfo =
            await MedicineDatabase.findGenericName(medicine.commercialName);

        if (genericInfo != null) {
          medicine.genericName = genericInfo.genericName;
        }
      }

      if (mounted) {
        setState(() {
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
            content: Text("Error finding generic names: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generic Alternatives"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.green[50],
        child: Column(
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Finding generic alternatives for your medicines...",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Loading or results
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Searching for generic alternatives..."),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: processedMedicines.length,
                      itemBuilder: (context, index) {
                        final medicine = processedMedicines[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              medicine.genericName != null
                                  ? Icons.check_circle
                                  : Icons.help_outline,
                              color: medicine.genericName != null
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            title: Text(
                              medicine.commercialName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              medicine.genericName ?? "Generic name not found",
                              style: TextStyle(
                                color: medicine.genericName != null
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontStyle: medicine.genericName != null
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                            trailing: medicine.genericName != null
                                ? const Icon(Icons.arrow_forward_ios, size: 16)
                                : null,
                          ),
                        );
                      },
                    ),
            ),

            // Bottom action
            if (!isLoading) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      processedMedicines.any((m) => m.genericName != null)
                          ? _checkJanAushadhiAvailability
                          : null,
                  icon: const Icon(Icons.store),
                  label: const Text("Check Jan Aushadhi Availability"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _checkJanAushadhiAvailability() {
    // TODO: Navigate to Jan Aushadhi availability page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Jan Aushadhi availability check coming soon!"),
      ),
    );
  }
}
