import 'package:url_launcher/url_launcher.dart';

class DirectionsUtils {
  /// Opens Google Maps with directions to the specified location
  ///
  /// [address] is the full address string
  /// Returns true if Google Maps was successfully opened, false otherwise
  static Future<bool> getDirections({
    required String address,
  }) async {
    try {
      // Use address string for directions
      final mapsUri = Uri(
        scheme: 'https',
        host: 'www.google.com',
        path: '/maps/dir/',
        queryParameters: {
          'api': '1',
          'destination': formatAddress(address),
          'travelmode': 'driving',
        },
      );

      

      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        
        return false;
      }
    } catch (e) {
      
      return false;
    }
  }

  /// Opens Google Maps to show the location on map
  ///
  /// [address] is the full address string
  /// [latitude] and [longitude] are optional coordinates
  /// Returns true if Google Maps was successfully opened, false otherwise
  static Future<bool> showOnMap({
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Uri mapsUri;

      if (latitude != null && longitude != null) {
        // Use coordinates if available
        mapsUri = Uri(
          scheme: 'https',
          host: 'www.google.com',
          path: '/maps/search/',
          queryParameters: {
            'api': '1',
            'query': '$latitude,$longitude',
          },
        );
      } else {
        // Use address string to search location
        mapsUri = Uri(
          scheme: 'https',
          host: 'www.google.com',
          path: '/maps/search/',
          queryParameters: {
            'api': '1',
            'query': address,
          },
        );
      }

      

      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        
        return false;
      }
    } catch (e) {
      
      return false;
    }
  }

  /// Opens the navigation app with the best route to destination
  /// This will use the device's default maps app (Google Maps, Apple Maps, etc.)
  ///
  /// [address] is the destination address
  /// [latitude] and [longitude] are optional coordinates
  /// Returns true if navigation was successfully started, false otherwise
  static Future<bool> startNavigation({
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Uri navigationUri;

      if (latitude != null && longitude != null) {
        // Use geo URI for device's default maps app
        navigationUri = Uri(
          scheme: 'geo',
          path: '$latitude,$longitude',
          queryParameters: {
            'q': '$latitude,$longitude($address)',
          },
        );
      } else {
        // Use geo URI with address query
        navigationUri = Uri(
          scheme: 'geo',
          path: '0,0',
          queryParameters: {
            'q': address,
          },
        );
      }

      

      if (await canLaunchUrl(navigationUri)) {
        await launchUrl(navigationUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback to Google Maps directions if geo URI fails
        
        return await getDirections(
          address: address,
        );
      }
    } catch (e) {
      
      return false;
    }
  }

  /// Formats an address for better readability
  ///
  /// Removes extra spaces and formats the address properly
  static String formatAddress(String address) {
    return address
        .replaceAll(
            RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .trim() // Remove leading/trailing spaces
        .replaceAll(', ,', ',') // Remove empty comma sections
        .replaceAll(',,', ','); // Remove double commas
  }

  /// Validates if an address seems to be complete enough for navigation
  ///
  /// Returns true if the address contains enough information for mapping
  static bool isValidAddress(String address) {
    if (address.trim().isEmpty || address.length < 5) {
      return false;
    }

    // Much more lenient validation - just check if we have some text
    String trimmedAddress = address.trim();

    // As long as the address has some meaningful content, allow it
    // Google Maps is smart enough to handle various address formats
    return trimmedAddress.isNotEmpty && trimmedAddress.length >= 5;
  }
}
