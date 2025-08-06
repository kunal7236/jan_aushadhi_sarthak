import 'package:flutter/material.dart';
import 'phone_utils.dart';
import 'directions_utils.dart';

/// Utility class for handling common actions like calling and getting directions
/// This provides a centralized way to handle these actions with proper error handling
class ActionUtils {
  /// Handles making a phone call with user feedback
  ///
  /// [context] is required for showing snackbars
  /// [phoneNumber] is the number to call
  /// [storeName] is optional store name for better user feedback
  static Future<void> handlePhoneCall(
    BuildContext context,
    String phoneNumber, {
    String? storeName,
  }) async {
    try {
      // Validate phone number first
      if (!PhoneUtils.isValidPhoneNumber(phoneNumber)) {
        _showErrorSnackBar(
          context,
          "Invalid phone number format. Please check the number and try again.",
        );
        return;
      }

      // Show loading indicator for a moment
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text("Opening dialer for ${storeName ?? 'store'}..."),
            ],
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.blue[600],
        ),
      );

      // Attempt to make the call
      final success = await PhoneUtils.makePhoneCall(phoneNumber);

      if (!success && context.mounted) {
        _showErrorSnackBar(
          context,
          "Unable to open dialer. Please ensure you have a phone app installed.",
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          "An error occurred while trying to make the call: $e",
        );
      }
    }
  }

  /// Handles getting directions with user feedback
  ///
  /// [context] is required for showing snackbars
  /// [address] is the destination address
  /// [storeName] is optional store name for better user feedback
  /// [latitude] and [longitude] are optional coordinates for better accuracy
  static Future<void> handleDirections(
    BuildContext context,
    String address, {
    String? storeName,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Validate address first
      if (!DirectionsUtils.isValidAddress(address)) {
        _showErrorSnackBar(
          context,
          "The address appears to be incomplete. Please check the address manually.",
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text("Opening directions to ${storeName ?? 'store'}..."),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.blue[600],
        ),
      );

      // Try to get directions first
      bool success = await DirectionsUtils.getDirections(
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      if (!success && context.mounted) {
        // Fallback: try to show location on map
        success = await DirectionsUtils.showOnMap(
          address: address,
          latitude: latitude,
          longitude: longitude,
        );

        if (!success && context.mounted) {
          _showErrorSnackBar(
            context,
            "Unable to open maps. Please install Google Maps or check your internet connection.",
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          "An error occurred while trying to get directions: $e",
        );
      }
    }
  }

  /// Handles starting navigation with user feedback
  ///
  /// [context] is required for showing snackbars
  /// [address] is the destination address
  /// [storeName] is optional store name for better user feedback
  /// [latitude] and [longitude] are optional coordinates for better accuracy
  static Future<void> handleNavigation(
    BuildContext context,
    String address, {
    String? storeName,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Validate address first
      if (!DirectionsUtils.isValidAddress(address)) {
        _showErrorSnackBar(
          context,
          "The address appears to be incomplete for navigation.",
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text("Starting navigation to ${storeName ?? 'store'}..."),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green[600],
        ),
      );

      // Start navigation
      final success = await DirectionsUtils.startNavigation(
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      if (!success && context.mounted) {
        _showErrorSnackBar(
          context,
          "Unable to start navigation. Please install a navigation app like Google Maps.",
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          "An error occurred while trying to start navigation: $e",
        );
      }
    }
  }

  /// Shows a standardized error message to the user
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows a success message to the user
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
