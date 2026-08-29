import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _timeFormat = DateFormat('hh:mm:ss a');
  static final DateFormat _dateFormat = DateFormat('EEE, MMM d, yyyy');

  /// Formats large numbers into clean USD abbreviations like $184.52M, $2.40B, $950.2K
  static String formatUsd(double amount) {
    if (amount <= 0) return '\$0.00';
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(2)}B';
    } else if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }

  /// Formats price with proper decimal precision e.g. $94,820.50
  static String formatPrice(double price) {
    if (price <= 0) return '\$0.00';
    if (price < 1.0) {
      return '\$${price.toStringAsFixed(4)}';
    } else if (price < 100) {
      return '\$${price.toStringAsFixed(2)}';
    } else {
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return '\$${formatter.format(price)}';
    }
  }

  /// Formats a DateTime into live clock time e.g., "08:41:03 AM"
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// Formats a DateTime into date e.g., "Sun, Aug 9, 2026"
  static String formatDate(DateTime time) {
    return _dateFormat.format(time);
  }

  /// Formats relative time e.g., "just now", "12s ago", "3m ago"
  static String formatTimeAgo(DateTime? time) {
    if (time == null) return 'Never';
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 5) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
