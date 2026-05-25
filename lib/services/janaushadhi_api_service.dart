import 'dart:convert';
import 'package:http/http.dart' as http;

class JanAushadhiApiService {
  static const String baseUrl = 'https://jan-api.kunalka.me';

  // Check if the API service is live
  static Future<bool> checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          if (data is Map<String, dynamic>) {
            return data['status']?.toString().toLowerCase() == 'online';
          }
          return false;
        } catch (e) {
          return false;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Search for medicines by name
  static Future<JanAushadhiSearchResult> searchMedicines(String query) async {
    try {
      final searchUrl = '$baseUrl/search?q=${Uri.encodeComponent(query)}';

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      // Successfully received a response from the API
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);

          final medicines = _parseMedicineResults(data);

          if (medicines.isEmpty) {
            // API responded correctly but no medicines found
            return JanAushadhiSearchResult(
              medicines: [],
              updatedAt: '',
              success: true,
              error:
                  'Medicine "$query" is not available in Jan Aushadhi stores',
            );
          }

          return JanAushadhiSearchResult(
            medicines: medicines,
            updatedAt: '',
            success: true,
          );
        } catch (e) {
          return JanAushadhiSearchResult(
            medicines: [],
            updatedAt: '',
            success: false,
            error: 'Error processing API response: $e',
          );
        }
      } else if (response.statusCode == 404) {
        // Handle 404 specifically - medicine not found in database
        return JanAushadhiSearchResult(
          medicines: [],
          updatedAt: '',
          success: true,
          error: 'Medicine "$query" is not available in Jan Aushadhi stores',
        );
      } else {
        return JanAushadhiSearchResult(
          medicines: [],
          updatedAt: '',
          success: false,
          error: 'API returned status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return JanAushadhiSearchResult(
        medicines: [],
        updatedAt: '',
        success: false,
        error: 'Failed to connect to medicine database: $e',
      );
    }
  }

  static List<JanAushadhiMedicine> _parseMedicineResults(dynamic data) {
    final List<dynamic> rawResults = _extractResultList(data);
    return rawResults
        .whereType<Map<String, dynamic>>()
        .map(JanAushadhiMedicine.fromJson)
        .toList();
  }

  static List<dynamic> _extractResultList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      for (final key in ['results', 'data', 'items', 'medicines']) {
        final value = data[key];
        if (value is List) {
          return value;
        }
      }

      return [data];
    }

    return const [];
  }
}

class JanAushadhiMedicine {
  final String srNo;
  final String drugCode;
  final String genericName;
  final String unitSize;
  final String mrp;

  JanAushadhiMedicine({
    required this.srNo,
    required this.drugCode,
    required this.genericName,
    required this.unitSize,
    required this.mrp,
  });

  factory JanAushadhiMedicine.fromJson(Map<String, dynamic> json) {
    return JanAushadhiMedicine(
      srNo: _firstString(json, ['Sr_No', 'sr_no', 'srNo']),
      drugCode: _firstString(json, ['Drug Code', 'drug_code', 'drugCode']),
      genericName:
          _firstString(json, ['Generic Name', 'generic_name', 'genericName']),
      unitSize: _firstString(json, ['Unit Size', 'unit_size', 'unitSize']),
      mrp: _firstString(json, ['MRP(in Rs_)', 'mrp', 'MRP']),
    );
  }

  static String _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  // Clean generic name for better display
  String get cleanGenericName {
    return genericName
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // Get numeric MRP value
  double get numericMrp {
    try {
      return double.parse(mrp.replaceAll(RegExp(r'[^\d.]'), ''));
    } catch (e) {
      return 0.0;
    }
  }
}

class JanAushadhiSearchResult {
  final List<JanAushadhiMedicine> medicines;
  final String updatedAt;
  final bool success;
  final String? error;

  JanAushadhiSearchResult({
    required this.medicines,
    required this.updatedAt,
    required this.success,
    this.error,
  });
}
