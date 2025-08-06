import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class JanAushadhiApiService {
  static const String baseUrl = 'https://medicine-api-m176.onrender.com';

  // Check if the API service is live
  static Future<bool> checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      // Consider any successful response as API being live
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          return data['message'] == 'Service is live';
        } catch (e) {
          // Even if JSON parsing fails, if we got a 200 response, API is likely up
          return true;
        }
      }
      print('API returned status code: ${response.statusCode}');
      return false;
    } catch (e) {
      print('API Status Check Error: $e');
      return false;
    }
  }

  // Search for medicines by name
  static Future<JanAushadhiSearchResult> searchMedicines(String query) async {
    try {
      print('Searching API for: $query');
      final searchUrl = '$baseUrl/search?name=${Uri.encodeComponent(query)}';
      print('API URL: $searchUrl');

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print('API response status: ${response.statusCode}');

      // Successfully received a response from the API
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          print(
              'API data: ${data.toString().substring(0, min(100, data.toString().length))}...');

          List<JanAushadhiMedicine> medicines = [];
          if (data['results'] != null) {
            for (var item in data['results']) {
              medicines.add(JanAushadhiMedicine.fromJson(item));
            }
          }

          print('Found ${medicines.length} medicines');

          if (medicines.isEmpty) {
            // API responded correctly but no medicines found
            return JanAushadhiSearchResult(
              medicines: [],
              updatedAt: data['updated_at'] ?? '',
              success: true,
              error:
                  'Medicine "$query" is not available in Jan Aushadhi stores',
            );
          }

          return JanAushadhiSearchResult(
            medicines: medicines,
            updatedAt: data['updated_at'] ?? '',
            success: true,
          );
        } catch (e) {
          print('JSON parsing error: $e');
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
      print('API Search Error: $e');
      return JanAushadhiSearchResult(
        medicines: [],
        updatedAt: '',
        success: false,
        error: 'Failed to connect to medicine database: $e',
      );
    }
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
      srNo: json['Sr_No']?.toString() ?? '',
      drugCode: json['Drug Code']?.toString() ?? '',
      genericName: json['Generic Name']?.toString() ?? '',
      unitSize: json['Unit Size']?.toString() ?? '',
      mrp: json['MRP(in Rs_)']?.toString() ?? '',
    );
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
