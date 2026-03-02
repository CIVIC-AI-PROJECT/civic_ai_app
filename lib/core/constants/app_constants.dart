class AppConstants {
  // Strings
  static const String appName = 'CIVIC.AI';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.civic-ai.in';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Languages
  static const Map<String, String> languages = {
    'en': 'English',
    'hi': 'हिंदी',
    'te': 'తెలుగు',
    'ta': 'தமிழ்',
    'kn': 'ಕನ್ನಡ',
    'mr': 'मराठी',
  };

  // Personas
  static const List<String> personas = [
    '🌾 Farmer',
    '👷‍♀️ Worker',
    '🎓 Student',
    '👵 Senior',
  ];

  // Quick Categories
  static const List<String> quickCategories = [
    'Ration/PDS',
    'Pensions',
    'Land Disputes',
    'FIR/Police',
  ];

  // Storage Keys
  static const String userKey = 'user';
  static const String languageKey = 'language';
  static const String personaKey = 'persona';
  static const String locationKey = 'location';
  static const String grievancesKey = 'grievances';
}
