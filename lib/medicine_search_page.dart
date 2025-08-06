import 'package:flutter/material.dart';
import 'services/janaushadhi_api_service.dart';
import 'store_locator_page.dart';

class MedicineSearchPage extends StatefulWidget {
  final List<String>? initialMedicines;

  const MedicineSearchPage({super.key, this.initialMedicines});

  @override
  State<MedicineSearchPage> createState() => _MedicineSearchPageState();
}

class _MedicineSearchPageState extends State<MedicineSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<JanAushadhiMedicine> searchResults = [];
  bool isLoading = false;
  bool isApiDown = false;
  String? errorMessage;
  String? lastUpdated;

  // New variables for prescription medicine control
  List<String>? prescriptionMedicines;
  int currentMedicineIndex = 0;
  bool isSearchingPrescription = false;
  Map<String, bool> medicineSearchResults =
      {}; // Track search results for each medicine

  @override
  void initState() {
    super.initState();
    _checkApiStatus();

    // Store prescription medicines but don't search automatically
    if (widget.initialMedicines != null &&
        widget.initialMedicines!.isNotEmpty) {
      prescriptionMedicines = List.from(widget.initialMedicines!);
      // Set the first medicine in the search field
      _searchController.text = prescriptionMedicines![0];
    }
  }

  // Method to search the next medicine from prescription
  void _searchNextPrescriptionMedicine() async {
    if (prescriptionMedicines == null ||
        currentMedicineIndex >= prescriptionMedicines!.length) {
      return;
    }

    setState(() {
      isSearchingPrescription = true;
    });

    String currentMedicine = prescriptionMedicines![currentMedicineIndex];
    _searchController.text = currentMedicine;
    await _searchMedicines();

    // Store the search result for this medicine
    bool medicineFound = searchResults.isNotEmpty;
    medicineSearchResults[currentMedicine] = medicineFound;

    setState(() {
      currentMedicineIndex++;
      isSearchingPrescription = false;
    });
  }

  Future<void> _checkApiStatus() async {
    print('Checking API status...');
    final isLive = await JanAushadhiApiService.checkStatus();
    print('API status check result: ${isLive ? 'LIVE' : 'DOWN'}');

    if (mounted) {
      setState(() {
        isApiDown = !isLive;
        if (isApiDown) {
          errorMessage =
              "Jan Aushadhi medicine database is currently unavailable. Please try again later.";
        } else {
          // Clear error message if API is up and it was previously showing as down
          if (errorMessage?.contains("unavailable") == true) {
            errorMessage = null;
          }
        }
      });
    }
  }

  Future<void> _searchMedicines() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a medicine name to search"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await JanAushadhiApiService.searchMedicines(query);

    if (mounted) {
      setState(() {
        isLoading = false;
        if (result.success) {
          searchResults = result.medicines;
          lastUpdated = result.updatedAt;
          isApiDown = false;

          // Show message if no results found but API is working
          if (result.medicines.isEmpty) {
            errorMessage =
                "No medicines found for '$query'. Try another Medicine/Check the Spelling!";
          }
        } else {
          // Only set API down if it's a connection issue, not just empty results
          if (result.error != null &&
              (result.error!.contains("Failed to connect") ||
                  result.error!.contains("timeout") ||
                  result.error!.contains("status code"))) {
            isApiDown = true;
            errorMessage = result.error;

            // Recheck API status automatically when a search fails with connection issues
            _checkApiStatus();
          } else {
            isApiDown = false;
            errorMessage = result.error;
          }
          searchResults = [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Jan Aushadhi Medicines"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.green[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Initial medicines from prescription (if any)
              if (prescriptionMedicines != null &&
                  prescriptionMedicines!.isNotEmpty) ...[
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medical_services,
                                color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Medicines from your prescription:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                            // Progress indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${currentMedicineIndex}/${prescriptionMedicines!.length}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Currently searching medicine highlight
                        if (currentMedicineIndex <
                            prescriptionMedicines!.length)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search,
                                    color: Colors.green[700], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Current: ${prescriptionMedicines![currentMedicineIndex]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: prescriptionMedicines!
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            String medicine = entry.value;
                            bool isSearched = index < currentMedicineIndex;
                            bool isCurrent = index == currentMedicineIndex;
                            bool? wasFound = medicineSearchResults[medicine];

                            Color chipColor;
                            Widget? avatar;

                            if (isSearched && wasFound != null) {
                              // Medicine has been searched
                              if (wasFound) {
                                // Found - green
                                chipColor = Colors.green[100]!;
                                avatar = Icon(Icons.check,
                                    size: 16, color: Colors.green[700]);
                              } else {
                                // Not found - red
                                chipColor = Colors.red[100]!;
                                avatar = Icon(Icons.close,
                                    size: 16, color: Colors.red[700]);
                              }
                            } else if (isCurrent) {
                              // Currently being searched - orange
                              chipColor = Colors.orange[100]!;
                              avatar = Icon(Icons.search,
                                  size: 16, color: Colors.orange[700]);
                            } else {
                              // Not searched yet - blue
                              chipColor = Colors.blue[100]!;
                              avatar = null;
                            }

                            return Chip(
                              label: Text(medicine),
                              backgroundColor: chipColor,
                              avatar: avatar,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        // Search next medicine button
                        if (currentMedicineIndex <
                            prescriptionMedicines!.length)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isSearchingPrescription || isLoading
                                  ? null
                                  : _searchNextPrescriptionMedicine,
                              icon: isSearchingPrescription
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.search),
                              label: Text(
                                isSearchingPrescription
                                    ? "Searching..."
                                    : currentMedicineIndex == 0
                                        ? "Start Searching Prescription Medicines"
                                        : "Search Next Medicine",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      "All prescription medicines searched!",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Found: ${medicineSearchResults.values.where((found) => found).length}, "
                                  "Not Available: ${medicineSearchResults.values.where((found) => !found).length}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Search Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.search, color: Colors.green),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Search for generic medicines available in Jan Aushadhi stores",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: "Medicine Name",
                          hintText: "e.g., Paracetamol, Amoxicillin",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _searchMedicines,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _searchMedicines(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _searchMedicines,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: Text(
                              isLoading ? "Searching..." : "Search Medicines"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // API Status or Error
              if (errorMessage != null) ...[
                Card(
                  color: isApiDown
                      ? Colors.red[50]
                      : errorMessage!
                              .contains("not available in Jan Aushadhi stores")
                          ? Colors.blue[50]
                          : Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          isApiDown
                              ? Icons.error
                              : errorMessage!.contains(
                                      "not available in Jan Aushadhi stores")
                                  ? Icons.info
                                  : Icons.info_outline,
                          color: isApiDown
                              ? Colors.red
                              : errorMessage!.contains(
                                      "not available in Jan Aushadhi stores")
                                  ? Colors.blue[700]
                                  : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isApiDown
                                    ? "Service Unavailable"
                                    : errorMessage!.contains(
                                            "not available in Jan Aushadhi stores")
                                        ? "Medicine Not Available"
                                        : "Search Results",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isApiDown
                                      ? Colors.red
                                      : errorMessage!.contains(
                                              "not available in Jan Aushadhi stores")
                                          ? Colors.blue[700]
                                          : Colors.orange[800],
                                ),
                              ),
                              Text(
                                errorMessage!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: isApiDown ? _checkApiStatus : null,
                          color: isApiDown ? Colors.red : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Results Section
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.5, // Give it a fixed height
                child: searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medication,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? "Enter a medicine name to search"
                                  : "No medicines found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                "Try searching with different keywords or generic names",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Results header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${searchResults.length} medicine(s) found",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                if (lastUpdated != null)
                                  Text(
                                    "Updated: ${_formatDate(lastUpdated!)}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Results list
                          Expanded(
                            child: ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final medicine = searchResults[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ExpansionTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green[100],
                                      child: Text(
                                        medicine.srNo,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      medicine.cleanGenericName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Icon(Icons.currency_rupee,
                                            size: 16, color: Colors.green[600]),
                                        Text(
                                          medicine.mrp,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[700],
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "• ${medicine.unitSize}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildDetailRow(
                                                "Drug Code", medicine.drugCode),
                                            _buildDetailRow("Generic Name",
                                                medicine.cleanGenericName),
                                            _buildDetailRow(
                                                "Unit Size", medicine.unitSize),
                                            _buildDetailRow(
                                                "MRP", "₹${medicine.mrp}"),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () {
                                                      // TODO: Add to cart or find nearby stores
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              "Added ${medicine.cleanGenericName} to your list"),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                        Icons.add_shopping_cart,
                                                        size: 16),
                                                    label: const Text(
                                                        "Add to List"),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green[600],
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const StoreLocatorPage(),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                        Icons.store,
                                                        size: 16),
                                                    label: const Text(
                                                        "Find Stores"),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.green[600],
                                                      side: BorderSide(
                                                          color: Colors
                                                              .green[600]!),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ), // Close SingleChildScrollView
      ), // Close Container
    ); // Close Scaffold
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
