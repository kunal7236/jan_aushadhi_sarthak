import 'dart:io';

class HttpDateUtils {
  static String fromHeaders(Map<String, String> headers) {
    return format(headers['last-modified'] ?? headers['date']);
  }

  static String formatDateTime(DateTime dateTime) {
    return _formatIst(dateTime);
  }

  static String formatCurrentIst() {
    return formatDateTime(
      DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)),
    );
  }

  static String format(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return '';
    }

    try {
      final normalizedValue =
          rawValue.contains(', ') ? rawValue : rawValue.replaceFirst(',', ', ');
      final parsedUtc = HttpDate.parse(normalizedValue).toUtc();
      final ist = parsedUtc.add(const Duration(hours: 5, minutes: 30));
      return _formatIst(ist);
    } catch (e) {
      return rawValue;
    }
  }

  static String _formatIst(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${_twoDigits(dateTime.day)} ${months[dateTime.month - 1]} ${dateTime.year}, '
        '${_twoDigits(hour)}:${_twoDigits(dateTime.minute)} $amPm IST';
  }

  static String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
