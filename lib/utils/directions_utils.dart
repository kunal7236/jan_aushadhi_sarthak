import 'package:url_launcher/url_launcher.dart';

class DirectionsUtils {
  /// Opens Google Maps with directions to the specified location
  ///
  /// [address] is the full address string
  /// [latitude] and [longitude] are optional coordinates for more precise location
  /// Returns true if Google Maps was successfully opened, false otherwise
  static Future<bool> getDirections({
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Uri mapsUri;

      if (latitude != null && longitude != null) {
        // Use coordinates if available for more accurate directions
        mapsUri = Uri(
          scheme: 'https',
          host: 'www.google.com',
          path: '/maps/dir/',
          queryParameters: {
            'api': '1',
            'destination': '$latitude,$longitude',
            'travelmode': 'driving',
          },
        );
      } else {
        // Use address string for directions
        mapsUri = Uri(
          scheme: 'https',
          host: 'www.google.com',
          path: '/maps/dir/',
          queryParameters: {
            'api': '1',
            'destination': address,
            'travelmode': 'driving',
          },
        );
      }

      print('Attempting to open Google Maps with: $mapsUri');

      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        print('Cannot launch Google Maps for directions');
        return false;
      }
    } catch (e) {
      print('Error opening directions: $e');
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

      print('Attempting to open Google Maps location: $mapsUri');

      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        print('Cannot launch Google Maps to show location');
        return false;
      }
    } catch (e) {
      print('Error showing location on map: $e');
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

      print('Attempting to start navigation: $navigationUri');

      if (await canLaunchUrl(navigationUri)) {
        await launchUrl(navigationUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback to Google Maps directions if geo URI fails
        print('Geo URI failed, falling back to Google Maps');
        return await getDirections(
          address: address,
          latitude: latitude,
          longitude: longitude,
        );
      }
    } catch (e) {
      print('Error starting navigation: $e');
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
    if (address.trim().isEmpty || address.length < 10) {
      return false;
    }

    // Check if address contains some basic components
    String lowerAddress = address.toLowerCase();

    // Should have some location indicators
    bool hasLocationInfo = lowerAddress.contains('road') ||
        lowerAddress.contains('street') ||
        lowerAddress.contains('avenue') ||
        lowerAddress.contains('nagar') ||
        lowerAddress.contains('colony') ||
        lowerAddress.contains('area') ||
        lowerAddress.contains('sector') ||
        lowerAddress.contains('block') ||
        lowerAddress.contains('plot') ||
        lowerAddress.contains('house') ||
        lowerAddress.contains('shop');

    // Should have some numbers (house/shop/plot numbers)
    bool hasNumbers = address.contains(RegExp(r'\d'));

    return hasLocationInfo && hasNumbers;
  }
}
