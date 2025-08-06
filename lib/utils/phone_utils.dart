import 'package:url_launcher/url_launcher.dart';

class PhoneUtils {
  /// Opens the device's dialer with the provided phone number
  ///
  /// [phoneNumber] should be in format like "9876543210" or "+91 9876543210"
  /// Returns true if the dialer was successfully opened, false otherwise
  static Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      // Clean the phone number by removing spaces, dashes, and other formatting
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Ensure the number starts with country code if it doesn't already
      if (!cleanNumber.startsWith('+') && cleanNumber.length == 10) {
        cleanNumber = '+91$cleanNumber'; // Default to India country code
      }

      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: cleanNumber,
      );

      print('Attempting to open dialer with: $cleanNumber');

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        return true;
      } else {
        print('Cannot launch phone dialer for: $cleanNumber');
        return false;
      }
    } catch (e) {
      print('Error making phone call: $e');
      return false;
    }
  }

  /// Validates if a phone number is in a proper format
  ///
  /// Returns true if the phone number appears to be valid
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if it's a valid Indian mobile number
    if (cleanNumber.length == 10 && cleanNumber.startsWith(RegExp(r'[6789]'))) {
      return true;
    }

    // Check if it's a valid Indian number with country code
    if (cleanNumber.length == 13 && cleanNumber.startsWith('+91')) {
      String mobileNumber = cleanNumber.substring(3);
      return mobileNumber.startsWith(RegExp(r'[6789]'));
    }

    // Check if it's a valid number with country code (without +)
    if (cleanNumber.length == 12 && cleanNumber.startsWith('91')) {
      String mobileNumber = cleanNumber.substring(2);
      return mobileNumber.startsWith(RegExp(r'[6789]'));
    }

    return false;
  }

  /// Formats a phone number for display
  ///
  /// Example: "9876543210" becomes "+91 98765 43210"
  static String formatPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // If it's a 10-digit Indian number
    if (cleanNumber.length == 10 && cleanNumber.startsWith(RegExp(r'[6789]'))) {
      return '+91 ${cleanNumber.substring(0, 5)} ${cleanNumber.substring(5)}';
    }

    // If it already has country code
    if (cleanNumber.startsWith('+91') && cleanNumber.length == 13) {
      String mobile = cleanNumber.substring(3);
      return '+91 ${mobile.substring(0, 5)} ${mobile.substring(5)}';
    }

    // Return as is if format is unclear
    return phoneNumber;
  }
}
