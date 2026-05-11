import 'package:intl/intl.dart';

/// General utility functions used across the app
class AppUtils {
  AppUtils._();

  /// Format DateTime to readable string e.g. "12 Jan 2024"
  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Format DateTime to time e.g. "2:30 PM"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Returns greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Capitalize the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Get current season based on month (for Northern Hemisphere defaults)
  static String getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Autumn';
    return 'Winter';
  }

  /// Returns a color suggestion for an outfit based on season
  static List<String> getSeasonalColors(String season) {
    switch (season) {
      case 'Spring':
        return ['Pastels', 'Mint', 'Lavender', 'Blush Pink', 'Light Yellow'];
      case 'Summer':
        return ['White', 'Sky Blue', 'Coral', 'Lemon Yellow', 'Turquoise'];
      case 'Autumn':
        return ['Rust', 'Mustard', 'Olive', 'Burgundy', 'Camel'];
      case 'Winter':
        return ['Black', 'Navy', 'Dark Grey', 'Forest Green', 'Deep Red'];
      default:
        return ['Neutral', 'Black', 'White', 'Grey'];
    }
  }

  /// Get emoji flag or icon for style category
  static String getStyleEmoji(String style) {
    final map = {
      'Casual': '👕',
      'Formal': '👔',
      'Streetwear': '🧢',
      'Smart Casual': '🧥',
      'Athletic': '🏃',
      'Bohemian': '🌸',
      'Minimalist': '⬜',
      'Luxury': '💎',
    };
    return map[style] ?? '✨';
  }

  /// Convert budget range string to numeric max value
  static int budgetToInt(String? budget) {
    if (budget == null) return 999999;
    if (budget.contains('500')) return 500;
    if (budget.contains('2000')) return 2000;
    if (budget.contains('5000')) return 5000;
    if (budget.contains('15000')) return 15000;
    return 999999;
  }
}
