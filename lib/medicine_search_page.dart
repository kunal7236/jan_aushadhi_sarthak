import 'package:flutter/material.dart';

import 'home_shell.dart';
import 'services/cart_storage_service.dart';
import 'services/janaushadhi_api_service.dart';
import 'store_locator_page.dart';

class MedicineSearchPage extends StatefulWidget {
  final List<String>? initialMedicines;
  final String? initialDraftTitle;

  const MedicineSearchPage({
    super.key,
    this.initialMedicines,
    this.initialDraftTitle,
  });

  @override
  State<MedicineSearchPage> createState() => _MedicineSearchPageState();
}

class _MedicineSearchPageState extends State<MedicineSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<JanAushadhiMedicine> searchResults = [];
  bool isLoading = false;
  bool isApiDown = false;
  String? errorMessage;

  List<String>? prescriptionMedicines;
  int currentMedicineIndex = 0;
  bool prescriptionSearchStarted = false;
  final Map<String, List<JanAushadhiMedicine>> prescriptionMedicineResults = {};
  String cartDraftTitle = 'List';

  bool get _hasPrescriptionMedicines =>
      prescriptionMedicines != null && prescriptionMedicines!.isNotEmpty;

  String get _currentPrescriptionMedicine =>
      prescriptionMedicines![currentMedicineIndex];

  @override
  void initState() {
    super.initState();
    _checkApiStatus();

    if (widget.initialMedicines != null &&
        widget.initialMedicines!.isNotEmpty) {
      prescriptionMedicines = List<String>.from(widget.initialMedicines!);
      _searchController.text = prescriptionMedicines!.first;
    }

    final incomingTitle = widget.initialDraftTitle?.trim();
    if (incomingTitle != null && incomingTitle.isNotEmpty) {
      cartDraftTitle = incomingTitle;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkApiStatus() async {
    final isLive = await JanAushadhiApiService.checkStatus();

    if (!mounted) {
      return;
    }

    if (!isLive) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeShellPage(
            initialIndex: 4,
            contactOpenedDueToApiIssue: true,
          ),
        ),
      );
      return;
    }

    setState(() {
      isApiDown = false;
      if (errorMessage?.contains('unavailable') == true) {
        errorMessage = null;
      }
    });
  }

  Future<void> _searchMedicines({String? forcedQuery}) async {
    final query = (forcedQuery ?? _searchController.text).trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a medicine name to search'),
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

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
      searchResults = List<JanAushadhiMedicine>.from(result.medicines);
      isApiDown = false;

      if (_hasPrescriptionMedicines && prescriptionMedicines!.contains(query)) {
        prescriptionMedicineResults[query] =
            List<JanAushadhiMedicine>.from(result.medicines);
      }

      if (result.success) {
        if (!_hasPrescriptionMedicines && result.medicines.isEmpty) {
          errorMessage =
              'No medicines found for "$query". Try another medicine or check the spelling.';
        }
      } else {
        if (result.error != null &&
            (result.error!.contains('Failed to connect') ||
                result.error!.contains('timeout') ||
                result.error!.contains('status code'))) {
          isApiDown = true;
          _checkApiStatus();
        }
        errorMessage = result.error;
        searchResults = [];
      }
    });
  }

  Future<void> _startPrescriptionSearch() async {
    if (!_hasPrescriptionMedicines) {
      return;
    }

    setState(() {
      prescriptionSearchStarted = true;
    });

    await _searchCurrentPrescriptionMedicine();
  }

  Future<void> _searchCurrentPrescriptionMedicine() async {
    if (!_hasPrescriptionMedicines) {
      return;
    }

    final medicine = _currentPrescriptionMedicine;
    _searchController.text = medicine;
    await _searchMedicines(forcedQuery: medicine);
  }

  Future<void> _showPrescriptionMedicine(int index) async {
    if (!_hasPrescriptionMedicines) {
      return;
    }

    if (index < 0 || index >= prescriptionMedicines!.length) {
      return;
    }

    final medicine = prescriptionMedicines![index];

    setState(() {
      currentMedicineIndex = index;
      prescriptionSearchStarted = true;
      _searchController.text = medicine;
      errorMessage = null;
      searchResults = List<JanAushadhiMedicine>.from(
        prescriptionMedicineResults[medicine] ?? const <JanAushadhiMedicine>[],
      );
    });

    if (!prescriptionMedicineResults.containsKey(medicine)) {
      await _searchMedicines(forcedQuery: medicine);
    }
  }

  Future<void> _goToPreviousPrescriptionMedicine() async {
    if (!_hasPrescriptionMedicines || currentMedicineIndex <= 0) {
      return;
    }

    await _showPrescriptionMedicine(currentMedicineIndex - 1);
  }

  Future<void> _goToNextPrescriptionMedicine() async {
    if (!_hasPrescriptionMedicines ||
        currentMedicineIndex >= prescriptionMedicines!.length - 1) {
      return;
    }

    await _showPrescriptionMedicine(currentMedicineIndex + 1);
  }

  int _foundPrescriptionCount() {
    return prescriptionMedicines
            ?.where((medicine) =>
                (prescriptionMedicineResults[medicine]?.isNotEmpty ?? false))
            .length ??
        0;
  }

  int _notFoundPrescriptionCount() {
    return prescriptionMedicines
            ?.where((medicine) =>
                prescriptionMedicineResults.containsKey(medicine) &&
                prescriptionMedicineResults[medicine]!.isEmpty)
            .length ??
        0;
  }

  bool _isPrescriptionSearchComplete() {
    if (!_hasPrescriptionMedicines || !prescriptionSearchStarted) {
      return false;
    }

    return prescriptionMedicines!
        .every((medicine) => prescriptionMedicineResults.containsKey(medicine));
  }

  bool _isMedicineFound(String medicine) {
    return (prescriptionMedicineResults[medicine]?.isNotEmpty ?? false);
  }

  List<JanAushadhiMedicine> _resultsForCurrentMedicine() {
    if (!_hasPrescriptionMedicines) {
      return searchResults;
    }

    final medicine = _currentPrescriptionMedicine;
    return prescriptionMedicineResults[medicine] ?? searchResults;
  }

  Future<void> _addToCart(JanAushadhiMedicine medicine) async {
    final added = await CartStorageService.addMedicine(
      medicine,
      draftTitle: cartDraftTitle,
    );
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Added ${medicine.cleanGenericName} to your list'
              : '${medicine.cleanGenericName} is already in your list',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleResults = _resultsForCurrentMedicine();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Jan Aushadhi Medicines'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.green[50],
        width: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_hasPrescriptionMedicines) ...[
                  Card(
                    color: Colors.teal[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.medical_services,
                                  color: Colors.teal[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Medicines from your prescription:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[700],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.teal[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${currentMedicineIndex + 1}/${prescriptionMedicines!.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.teal[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.radio_button_checked,
                                    color: Colors.teal[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Current: $_currentPrescriptionMedicine',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.teal[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (!prescriptionSearchStarted)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed:
                                    isLoading ? null : _startPrescriptionSearch,
                                icon: isLoading
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
                                label: const Text('Start Search'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: currentMedicineIndex > 0
                                        ? _goToPreviousPrescriptionMedicine
                                        : null,
                                    icon: const Icon(Icons.chevron_left),
                                    label: const Text('Prev'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.teal[700],
                                      side:
                                          BorderSide(color: Colors.teal[300]!),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: currentMedicineIndex <
                                            prescriptionMedicines!.length - 1
                                        ? _goToNextPrescriptionMedicine
                                        : null,
                                    icon: const Icon(Icons.chevron_right),
                                    label: const Text('Next'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[600],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          if (_isPrescriptionSearchComplete())
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
                                        'All prescription medicines searched!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Found: ${_foundPrescriptionCount()}, Not Available: ${_notFoundPrescriptionCount()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: EdgeInsets.zero,
                                      childrenPadding: EdgeInsets.zero,
                                      title: Text(
                                        'View searched medicines',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.green[700],
                                      ),
                                      children: [
                                        ...prescriptionMedicines!
                                            .map((medicine) {
                                          final found =
                                              _isMedicineFound(medicine);
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 6),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: found
                                                  ? Colors.green[100]
                                                  : Colors.red[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: found
                                                    ? Colors.green[300]!
                                                    : Colors.red[300]!,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  found
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  size: 16,
                                                  color: found
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    medicine,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: found
                                                          ? Colors.green[800]
                                                          : Colors.red[800],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  found ? 'Found' : 'Missing',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: found
                                                        ? Colors.green[700]
                                                        : Colors.red[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
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
                                'Search for generic medicines available in Jan Aushadhi stores',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Medicine Name',
                            hintText: 'Paracetamol',
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
                            label: Text(isLoading
                                ? 'Searching...'
                                : 'Search Medicines'),
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
                if (errorMessage != null) ...[
                  Card(
                    color: isApiDown
                        ? Colors.red[50]
                        : errorMessage!.contains(
                                'not available in Jan Aushadhi stores')
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
                                        'not available in Jan Aushadhi stores')
                                    ? Icons.info
                                    : Icons.info_outline,
                            color: isApiDown
                                ? Colors.red
                                : errorMessage!.contains(
                                        'not available in Jan Aushadhi stores')
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
                                      ? 'Service Unavailable'
                                      : errorMessage!.contains(
                                              'not available in Jan Aushadhi stores')
                                          ? 'Medicine Not Available'
                                          : 'Search Results',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isApiDown
                                        ? Colors.red
                                        : errorMessage!.contains(
                                                'not available in Jan Aushadhi stores')
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
                Expanded(
                  child: visibleResults.isEmpty
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
                                    ? 'Enter a medicine name to search'
                                    : _hasPrescriptionMedicines &&
                                            prescriptionSearchStarted
                                        ? 'No medicines found for $_currentPrescriptionMedicine'
                                        : 'No medicines found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (_searchController.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Try searching with different keywords or generic names',
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _hasPrescriptionMedicines
                                      ? 'Results for $_currentPrescriptionMedicine'
                                      : '${visibleResults.length} medicine(s) found',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: visibleResults.length,
                                itemBuilder: (context, index) {
                                  final medicine = visibleResults[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      childrenPadding:
                                          const EdgeInsets.fromLTRB(
                                              16, 0, 16, 16),
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
                                      trailing: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.green[700],
                                      ),
                                      collapsedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                                              size: 16,
                                              color: Colors.green[600]),
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
                                            '• ${medicine.unitSize}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () async {
                                                  await _addToCart(medicine);
                                                },
                                                icon: const Icon(
                                                    Icons.add_shopping_cart,
                                                    size: 16),
                                                label:
                                                    const Text('Add to List'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green[600],
                                                  foregroundColor: Colors.white,
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
                                                icon: const Icon(Icons.store,
                                                    size: 16),
                                                label:
                                                    const Text('Find Stores'),
                                                style: OutlinedButton.styleFrom(
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
        ),
      ),
    );
  }
}
