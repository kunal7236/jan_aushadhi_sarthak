import 'package:flutter/material.dart';
import 'services/kendra_api_service.dart';
import 'utils/action_utils.dart';

class StoreLocatorPage extends StatefulWidget {
  const StoreLocatorPage({super.key});

  @override
  State<StoreLocatorPage> createState() => _StoreLocatorPageState();
}

class _StoreLocatorPageState extends State<StoreLocatorPage> {
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _kendraCodeController = TextEditingController();

  List<JanAushadhiKendra> searchResults = [];
  bool isLoading = false;
  bool isApiDown = false;
  String? errorMessage;
  String? lastUpdated;

  // Search type: 0 = pincode, 1 = location, 2 = kendra code
  int selectedSearchType = 0;

  @override
  void initState() {
    super.initState();
    _checkApiStatus();
  }

  Future<void> _checkApiStatus() async {
    print('Checking Kendra API status...');
    final status = await KendraApiService.checkStatus();
    print('Kendra API status: ${status.isLive ? 'LIVE' : 'DOWN'}');

    if (mounted) {
      setState(() {
        isApiDown = !status.isLive;
        if (status.success && status.isLive) {
          lastUpdated = status.updatedAt;
          errorMessage = null;
        } else {
          errorMessage =
              status.error ?? "Store locator service is currently unavailable.";
        }
      });
    }
  }

  Future<void> _searchStores() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    KendraSearchResult result;

    try {
      switch (selectedSearchType) {
        case 0: // Pincode search
          if (_pincodeController.text.trim().isEmpty) {
            _showError("Please enter a pincode");
            return;
          }
          result = await KendraApiService.getKendrasByPincode(
              _pincodeController.text.trim());
          break;

        case 1: // Location search
          if (_stateController.text.trim().isEmpty ||
              _districtController.text.trim().isEmpty) {
            _showError("Please enter both state and district");
            return;
          }
          result = await KendraApiService.getKendrasByLocation(
            state: _stateController.text.trim(),
            district: _districtController.text.trim(),
          );
          break;

        case 2: // Kendra code search
          if (_kendraCodeController.text.trim().isEmpty) {
            _showError("Please enter a Kendra code");
            return;
          }
          result = await KendraApiService.getKendraByCode(
              _kendraCodeController.text.trim());
          break;

        default:
          return;
      }

      if (mounted) {
        setState(() {
          isLoading = false;
          if (result.success) {
            searchResults = result.kendras;
            lastUpdated = result.updatedAt;
            isApiDown = false;

            if (result.kendras.isEmpty) {
              errorMessage =
                  "No Jan Aushadhi stores found for your search criteria.";
            }
          } else {
            if (result.error != null &&
                (result.error!.contains("Failed to connect") ||
                    result.error!.contains("timeout") ||
                    result.error!.contains("status code"))) {
              isApiDown = true;
              _checkApiStatus();
            } else {
              isApiDown = false;
            }
            errorMessage = result.error;
            searchResults = [];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "An error occurred: $e";
          searchResults = [];
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      isLoading = false;
      errorMessage = message;
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Jan Aushadhi Stores"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.green[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Type Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Search by:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Search type tabs
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text("Pincode"),
                              selected: selectedSearchType == 0,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedSearchType = 0;
                                    searchResults = [];
                                    errorMessage = null;
                                  });
                                }
                              },
                              selectedColor: Colors.green[200],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text("Location"),
                              selected: selectedSearchType == 1,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedSearchType = 1;
                                    searchResults = [];
                                    errorMessage = null;
                                  });
                                }
                              },
                              selectedColor: Colors.green[200],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text("Kendra Code"),
                              selected: selectedSearchType == 2,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedSearchType = 2;
                                    searchResults = [];
                                    errorMessage = null;
                                  });
                                }
                              },
                              selectedColor: Colors.green[200],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Search fields based on selected type
                      if (selectedSearchType == 0) ...[
                        // Pincode search
                        TextField(
                          controller: _pincodeController,
                          decoration: const InputDecoration(
                            labelText: "Pincode",
                            hintText: "e.g., 110001",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_pin),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          onSubmitted: (_) => _searchStores(),
                        ),
                      ] else if (selectedSearchType == 1) ...[
                        // Location search
                        TextField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: "State",
                            hintText: "e.g., Andhra Pradesh",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.map),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _districtController,
                          decoration: const InputDecoration(
                            labelText: "District",
                            hintText: "e.g., Anantapur",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) => _searchStores(),
                        ),
                      ] else if (selectedSearchType == 2) ...[
                        // Kendra code search
                        TextField(
                          controller: _kendraCodeController,
                          decoration: const InputDecoration(
                            labelText: "Kendra Code",
                            hintText: "e.g., PMBJK00005",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.qr_code),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: (_) => _searchStores(),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Search button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _searchStores,
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
                          label:
                              Text(isLoading ? "Searching..." : "Find Stores"),
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

              // Error/Status messages
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
                                  color: isApiDown
                                      ? Colors.red
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

              // Results
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.5, // Fixed height instead of Expanded
                child: searchResults.isEmpty && !isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Search for Jan Aushadhi stores",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Find stores by pincode, location, or Kendra code",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Results header
                          if (searchResults.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${searchResults.length} store(s) found",
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
                          ],

                          // Results list
                          Expanded(
                            child: ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final kendra = searchResults[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ExpansionTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green[100],
                                      child: Text(
                                        kendra.srNo,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      kendra.cleanName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      kendra.fullLocation,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildDetailRow("Kendra Code",
                                                kendra.kendraCode),
                                            _buildDetailRow("Contact",
                                                kendra.formattedContact),
                                            _buildDetailRow(
                                                "Address", kendra.address),
                                            _buildDetailRow(
                                                "Pincode", kendra.pinCode),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () => ActionUtils
                                                        .handlePhoneCall(
                                                      context,
                                                      kendra.contact,
                                                      storeName:
                                                          kendra.cleanName,
                                                    ),
                                                    icon: const Icon(Icons.call,
                                                        size: 16),
                                                    label: const Text("Call"),
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
                                                      // Construct a more complete address for better navigation
                                                      String fullAddress =
                                                          kendra.address;
                                                      if (kendra
                                                          .pinCode.isNotEmpty) {
                                                        fullAddress +=
                                                            ', ${kendra.pinCode}';
                                                      }
                                                      if (kendra.districtName
                                                          .isNotEmpty) {
                                                        fullAddress +=
                                                            ', ${kendra.districtName}';
                                                      }
                                                      if (kendra.stateName
                                                          .isNotEmpty) {
                                                        fullAddress +=
                                                            ', ${kendra.stateName}';
                                                      }

                                                      ActionUtils
                                                          .handleDirections(
                                                        context,
                                                        fullAddress,
                                                        storeName:
                                                            kendra.cleanName,
                                                      );
                                                    },
                                                    icon: const Icon(
                                                        Icons.directions,
                                                        size: 16),
                                                    label: const Text(
                                                        "Directions"),
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
                                            const SizedBox(height: 8),
                                            // Navigation button (full width)
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  // Construct a more complete address for better navigation
                                                  String fullAddress =
                                                      kendra.address;
                                                  if (kendra
                                                      .pinCode.isNotEmpty) {
                                                    fullAddress +=
                                                        ', ${kendra.pinCode}';
                                                  }
                                                  if (kendra.districtName
                                                      .isNotEmpty) {
                                                    fullAddress +=
                                                        ', ${kendra.districtName}';
                                                  }
                                                  if (kendra
                                                      .stateName.isNotEmpty) {
                                                    fullAddress +=
                                                        ', ${kendra.stateName}';
                                                  }

                                                  ActionUtils.handleNavigation(
                                                    context,
                                                    fullAddress,
                                                    storeName: kendra.cleanName,
                                                  );
                                                },
                                                icon: const Icon(
                                                    Icons.navigation,
                                                    size: 16),
                                                label: const Text(
                                                    "Start Navigation"),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue[600],
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
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

  @override
  void dispose() {
    _pincodeController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _kendraCodeController.dispose();
    super.dispose();
  }
}
