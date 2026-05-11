/// App-wide constants — Indian market focused
class AppConstants {
  AppConstants._();

  static const String appName = 'FashionTrend AI';
  static const String appVersion = '1.0.0';

  // Supabase Tables
  static const String profilesTable = 'profiles';
  static const String analysisTable = 'ai_analyses';
  static const String recommendationsTable = 'recommendations';
  static const String closetItemsTable = 'closet_items';
  static const String savedLooksTable = 'saved_looks';
  static const String chatMessagesTable = 'chat_messages';

  // Supabase Storage
  static const String avatarsBucket = 'avatars';
  static const String analysisBucket = 'analysis-images';
  static const String closetBucket = 'closet-images';

  // Indian fashion styles
  static const List<String> styleCategories = [
    'Casual', 'Formal', 'Traditional', 'Indo-Western',
    'Streetwear', 'Smart Casual', 'Festive', 'Minimalist',
  ];

  static const List<String> occasions = [
    'Daily Wear', 'Office/Work', 'College', 'Date Night',
    'Wedding/Sangeet', 'Festival/Puja', 'Party', 'Gym/Sports',
    'Casual Outing', 'Beach/Travel',
  ];

  static const List<String> seasons = [
    'Summer (Mar-Jun)', 'Monsoon (Jul-Sep)',
    'Winter (Oct-Feb)', 'All Season',
  ];

  // Indian budget ranges in INR
  static const List<String> budgetRanges = [
    'Under ₹500', '₹500–₹2,000', '₹2,000–₹5,000',
    '₹5,000–₹15,000', '₹15,000+',
  ];

  static const List<String> bodyTypes = [
    'Slim/Lean', 'Athletic', 'Average', 'Plus Size', 'Petite',
  ];

  static const List<String> faceShapes = [
    'Oval', 'Round', 'Square', 'Heart', 'Diamond', 'Oblong',
  ];

  static const List<String> skinTones = [
    'Very Fair', 'Fair', 'Wheatish', 'Medium Brown',
    'Dark Brown', 'Deep/Dark',
  ];

  static const List<String> genders = ['Male', 'Female', 'Other'];

  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'Hindi (हिंदी)',
    'ta': 'Tamil (தமிழ்)',
    'te': 'Telugu (తెలుగు)',
    'kn': 'Kannada (ಕನ್ನಡ)',
    'ml': 'Malayalam (മലയാളം)',
    'mr': 'Marathi (मराठी)',
    'bn': 'Bengali (বাংলা)',
    'gu': 'Gujarati (ગુજરાતી)',
  };
}
