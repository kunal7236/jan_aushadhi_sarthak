import 'package:flutter/material.dart';
import 'services/janaushadhi_api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _checkApiStatus();

    // If initial medicines are provided, search for them automatically
    if (widget.initialMedicines != null &&
        widget.initialMedicines!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchInitialMedicines();
      });
    }
  }

  Future<void> _searchInitialMedicines() async {
    for (String medicine in widget.initialMedicines!) {
      _searchController.text = medicine;
      await _searchMedicines();
      // Small delay between searches to avoid overwhelming the API
      await Future.delayed(const Duration(milliseconds: 500));
    }
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
                "No medicines found for '$query'. Try a different search term.";
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
        padding: const EdgeInsets.all(16),
        color: Colors.green[50],
        child: Column(
          children: [
            // Initial medicines from prescription (if any)
            if (widget.initialMedicines != null &&
                widget.initialMedicines!.isNotEmpty) ...[
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_services, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            "Medicines from your prescription:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: widget.initialMedicines!
                            .map((medicine) => Chip(
                                  label: Text(medicine),
                                  backgroundColor: Colors.blue[100],
                                  onDeleted: null,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Searching for these medicines automatically...",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
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
                color: isApiDown ? Colors.red[50] : Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        isApiDown ? Icons.error : Icons.info_outline,
                        color: isApiDown ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isApiDown
                                  ? "Service Unavailable"
                                  : "Search Results",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    isApiDown ? Colors.red : Colors.orange[800],
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
            Expanded(
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
                                                  label:
                                                      const Text("Add to List"),
                                                  style:
                                                      ElevatedButton.styleFrom(
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
                                                    // TODO: Find nearby Jan Aushadhi stores
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "Store locator coming soon!"),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.store,
                                                      size: 16),
                                                  label:
                                                      const Text("Find Stores"),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.green[600],
                                                    side: BorderSide(
                                                        color:
                                                            Colors.green[600]!),
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
      ),
    );
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
