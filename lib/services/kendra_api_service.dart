import 'dart:convert';
import 'package:http/http.dart' as http;

class KendraApiService {
  static const String baseUrl = 'https://kendra-api.onrender.com';

  // Check if the Kendra API service is live
  static Future<KendraStatusResult> checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          return KendraStatusResult(
            isLive: data['message'] == 'Service is live',
            updatedAt: data['updated_at'] ?? '',
            success: true,
          );
        } catch (e) {
          return KendraStatusResult(
            isLive: false,
            updatedAt: '',
            success: false,
            error: 'Error parsing status response: $e',
          );
        }
      } else {
        return KendraStatusResult(
          isLive: false,
          updatedAt: '',
          success: false,
          error: 'API returned status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return KendraStatusResult(
        isLive: false,
        updatedAt: '',
        success: false,
        error: 'Failed to connect to Kendra service: $e',
      );
    }
  }

  // Get Kendra by code
  static Future<KendraSearchResult> getKendraByCode(String kendraCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kendra/${Uri.encodeComponent(kendraCode)}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          List<JanAushadhiKendra> kendras = [];

          if (data['results'] != null) {
            for (var item in data['results']) {
              kendras.add(JanAushadhiKendra.fromJson(item));
            }
          }

          return KendraSearchResult(
            kendras: kendras,
            updatedAt: data['updated_at'] ?? '',
            success: true,
          );
        } catch (e) {
          return KendraSearchResult(
            kendras: [],
            updatedAt: '',
            success: false,
            error: 'Error parsing Kendra response: $e',
          );
        }
      } else {
        return KendraSearchResult(
          kendras: [],
          updatedAt: '',
          success: false,
          error: 'API returned status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return KendraSearchResult(
        kendras: [],
        updatedAt: '',
        success: false,
        error: 'Failed to connect to Kendra database: $e',
      );
    }
  }

  // Get Kendras by pincode
  static Future<KendraSearchResult> getKendrasByPincode(String pincode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pincode/${Uri.encodeComponent(pincode)}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          List<JanAushadhiKendra> kendras = [];

          if (data['results'] != null) {
            for (var item in data['results']) {
              kendras.add(JanAushadhiKendra.fromJson(item));
            }
          }

          return KendraSearchResult(
            kendras: kendras,
            updatedAt: data['updated_at'] ?? '',
            success: true,
          );
        } catch (e) {
          return KendraSearchResult(
            kendras: [],
            updatedAt: '',
            success: false,
            error: 'Error parsing Kendra response: $e',
          );
        }
      } else {
        return KendraSearchResult(
          kendras: [],
          updatedAt: '',
          success: false,
          error: 'API returned status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return KendraSearchResult(
        kendras: [],
        updatedAt: '',
        success: false,
        error: 'Failed to connect to Kendra database: $e',
      );
    }
  }

  // Get Kendras by location (state and district)
  static Future<KendraSearchResult> getKendrasByLocation({
    required String state,
    required String district,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/location?state=${Uri.encodeComponent(state)}&district=${Uri.encodeComponent(district)}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          List<JanAushadhiKendra> kendras = [];

          if (data['results'] != null) {
            for (var item in data['results']) {
              kendras.add(JanAushadhiKendra.fromJson(item));
            }
          }

          return KendraSearchResult(
            kendras: kendras,
            updatedAt: data['updated_at'] ?? '',
            success: true,
          );
        } catch (e) {
          return KendraSearchResult(
            kendras: [],
            updatedAt: '',
            success: false,
            error: 'Error parsing Kendra response: $e',
          );
        }
      } else {
        return KendraSearchResult(
          kendras: [],
          updatedAt: '',
          success: false,
          error: 'API returned status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return KendraSearchResult(
        kendras: [],
        updatedAt: '',
        success: false,
        error: 'Failed to connect to Kendra database: $e',
      );
    }
  }
}

// Data Models
class JanAushadhiKendra {
  final String srNo;
  final String kendraCode;
  final String name;
  final String contact;
  final String stateName;
  final String districtName;
  final String pinCode;
  final String address;

  JanAushadhiKendra({
    required this.srNo,
    required this.kendraCode,
    required this.name,
    required this.contact,
    required this.stateName,
    required this.districtName,
    required this.pinCode,
    required this.address,
  });

  factory JanAushadhiKendra.fromJson(Map<String, dynamic> json) {
    return JanAushadhiKendra(
      srNo: json['Sr.No']?.toString() ?? '',
      kendraCode: json['Kendra Code']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
      contact: json['Contact']?.toString() ?? '',
      stateName: json['State Name']?.toString() ?? '',
      districtName: json['District Name']?.toString() ?? '',
      pinCode: json['Pin Code']?.toString() ?? '',
      address: json['Address']?.toString() ?? '',
    );
  }

  // Clean name for better display
  String get cleanName {
    return name.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // Format contact number
  String get formattedContact {
    if (contact.length == 10) {
      return '+91 ${contact.substring(0, 5)} ${contact.substring(5)}';
    }
    return contact;
  }

  // Get full location string
  String get fullLocation {
    return '$districtName, $stateName - $pinCode';
  }
}

class KendraSearchResult {
  final List<JanAushadhiKendra> kendras;
  final String updatedAt;
  final bool success;
  final String? error;

  KendraSearchResult({
    required this.kendras,
    required this.updatedAt,
    required this.success,
    this.error,
  });
}

class KendraStatusResult {
  final bool isLive;
  final String updatedAt;
  final bool success;
  final String? error;

  KendraStatusResult({
    required this.isLive,
    required this.updatedAt,
    required this.success,
    this.error,
  });
}
