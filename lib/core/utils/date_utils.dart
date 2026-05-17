import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static final DateFormat _fileNameFormat = DateFormat('yyyyMMdd_HHmmss');
  static final DateFormat _displayFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');

  static String formatForFileName(DateTime dateTime) {
    return _fileNameFormat.format(dateTime);
  }

  static String formatForDisplay(DateTime dateTime) {
    return _displayFormat.format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}