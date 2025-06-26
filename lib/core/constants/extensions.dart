import 'package:jiffy/jiffy.dart';

extension DateTimeExtension on DateTime {
  String fromNow() {
    return Jiffy.parseFromDateTime(this).fromNow();
  }

  String format(String pattern) {
    return Jiffy.parseFromDateTime(this).format(pattern: pattern);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String truncate(int length) {
    if (length >= this.length) return this;
    return '${substring(0, length)}...';
  }
}
