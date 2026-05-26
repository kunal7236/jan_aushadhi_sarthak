import 'dart:convert';

import 'package:http/http.dart' as http;

class KendraApiService {
  static const String baseUrl = 'https://jan-api.kunalka.me';

  static Future<KendraStatusResult> checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          final isOnline = data is Map<String, dynamic>
              ? data['status']?.toString().toLowerCase() == 'online'
              : false;

          return KendraStatusResult(
            isLive: isOnline,
            updatedAt: '',
            success: true,
          );
        } catch (_) {
          return KendraStatusResult(
            isLive: false,
            updatedAt: '',
            success: false,
            error: 'Unable to check service status right now.',
          );
        }
      }

      return KendraStatusResult(
        isLive: false,
        updatedAt: '',
        success: false,
        error: 'Unable to check service status right now.',
      );
    } catch (_) {
      return KendraStatusResult(
        isLive: false,
        updatedAt: '',
        success: false,
        error: 'Unable to check service status right now.',
      );
    }
  }

  static Future<KendraSearchResult> getKendraByCode(String kendraCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kendras?q=${Uri.encodeComponent(kendraCode)}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          final kendras = _parseKendras(data);

          return KendraSearchResult(
            kendras: kendras,
            updatedAt: '',
            success: true,
          );
        } catch (_) {
          return KendraSearchResult(
            kendras: [],
            updatedAt: '',
            success: false,
            error: 'Unable to load store information right now.',
          );
        }
      }

      return KendraSearchResult(
        kendras: [],
        updatedAt: '',
        success: false,
        error: 'Unable to load store information right now.',
        isServerError: response.statusCode >= 500,
      );
    } catch (_) {
      return KendraSearchResult(
        kendras: [],
        updatedAt: '',
        success: false,
        error: 'Unable to load store information right now.',
      );
    }
  }

  static Future<KendraSearchResult> getKendrasByPincode(String pincode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kendras?pincode=${Uri.encodeComponent(pincode)}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          final kendras = _parseKendras(data);

          return KendraSearchResult(
            kendras: kendras,
            updatedAt: '',
            success: true,
          );
        } catch (_) {
          return KendraSearchResult(
            kendras: [],
            updatedAt: '',
            success: false,
            error: 'Unable to load store information right now.',
          );
        }
      }

      return KendraSearchResult(
        kendras: [],
        updatedAt: '',
        success: false,
        error: 'Unable to load store information right now.',
        isServerError: response.statusCode >= 500,
      );
    } catch (_) {
      return KendraSearchResult(
        kendras: [],
        updatedAt: '',
        success: false,
        error: 'Unable to load store information right now.',
      );
    }
  }

  static Future<KendraSearchResult> getKendrasByLocation({
    required String state,
    required String district,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/kendras?state=${Uri.encodeComponent(state)}&district=${Uri.encodeComponent(district)}',
        ),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          final kendras = _parseKendras(data);

          return KendraSearchResult(
            kendras: kendras,
            updatedAt: '',
            success: true,
          );
        } catch (_) {
          return KendraSearchResult(
            kendras: [],
            updatedAt: '',
            success: false,
            error: 'Unable to load store information right now.',
          );
        }
      }

      return KendraSearchResult(
        kendras: [],
        updatedAt: '',
        success: false,
        error: 'Unable to load store information right now.',
        isServerError: response.statusCode >= 500,
      );
    } catch (_) {
      return KendraSearchResult(
        kendras: [],
        updatedAt: '',
        success: false,
        error: 'Unable to load store information right now.',
      );
    }
  }

  static bool isApiDownError(String? error) {
    if (error == null) {
      return false;
    }

    return error.contains('timeout') || error.contains('status code');
  }

  static List<JanAushadhiKendra> _parseKendras(dynamic data) {
    final List<dynamic> rawResults = _extractResultList(data);
    return rawResults
        .whereType<Map<String, dynamic>>()
        .map(JanAushadhiKendra.fromJson)
        .toList();
  }

  static List<dynamic> _extractResultList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      for (final key in ['results', 'stores', 'data', 'items', 'kendras']) {
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

class JanAushadhiKendra {
  final String srNo;
  final String kendraCode;
  final String name;
  final String stateName;
  final String districtName;
  final String pinCode;
  final String address;

  JanAushadhiKendra({
    required this.srNo,
    required this.kendraCode,
    required this.name,
    required this.stateName,
    required this.districtName,
    required this.pinCode,
    required this.address,
  });

  factory JanAushadhiKendra.fromJson(Map<String, dynamic> json) {
    return JanAushadhiKendra(
      srNo: _firstString(json, ['Sr.No', 'sr_no', 'srNo', 'id']),
      kendraCode: _firstString(
        json,
        ['Kendra Code', 'kendra_code', 'kendraCode', 'code'],
      ),
      name: _firstString(json, ['Name', 'name', 'store_name', 'kendra_name']),
      stateName: _firstString(json, ['State Name', 'state_name', 'state']),
      districtName: _firstString(
        json,
        ['District Name', 'district_name', 'district'],
      ),
      pinCode: _firstString(json, ['Pin Code', 'pin_code', 'pincode', 'pin']),
      address: _firstString(
          json, ['Address', 'address', 'location', 'full_address']),
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

  String get cleanName {
    return name.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String get fullLocation {
    return '$districtName, $stateName - $pinCode';
  }
}

class KendraSearchResult {
  final List<JanAushadhiKendra> kendras;
  final String updatedAt;
  final bool success;
  final String? error;
  final bool isServerError;

  KendraSearchResult({
    required this.kendras,
    required this.updatedAt,
    required this.success,
    this.error,
    this.isServerError = false,
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
