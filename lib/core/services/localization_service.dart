class LocalizationService {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'app_name': 'CIVIC.AI',
      'welcome': 'Welcome to CIVIC.AI',
      'select_language': 'Select Your Language',
      'select_persona': 'Who Are You?',
      'select_location': 'Select Your Location',
      'next': 'Next',
      'skip': 'Skip',
      'back': 'Back',
      'done': 'Done',
      'cancel': 'Cancel',
      'save': 'Save',
      'what_problem': 'What problem are you facing today?',
      'tap_to_speak': 'Tap to Speak',
      'recording': 'Recording...',
      'stop': 'Stop',
      'your_right': 'Your Right',
      'what_to_say': 'What to Say',
      'action_center': 'Action Center',
      'documents_needed': 'Documents You Need',
      'nearest_office': 'Nearest Grievance Office',
      'generate_application': 'Generate Application',
      'escalation_steps': 'Escalation Steps',
      'call_now': 'Call Now',
      'farmer': 'Farmer',
      'worker': 'Worker',
      'student': 'Student',
      'senior': 'Senior',
      'english': 'English',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
    },
    'hi': {
      'app_name': 'CIVIC.AI',
      'welcome': 'CIVIC.AI में आपका स्वागत है',
      'select_language': 'अपनी भाषा चुनें',
      'select_persona': 'आप कौन हैं?',
      'select_location': 'अपना स्थान चुनें',
      'next': 'आगे',
      'skip': 'छोड़ें',
      'back': 'पीछे',
      'done': 'हो गया',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'what_problem': 'आज आप किस समस्या का सामना कर रहे हैं?',
      'tap_to_speak': 'बोलने के लिए टैप करें',
      'recording': 'रिकॉर्डिंग चल रही है...',
      'stop': 'बंद करें',
      'your_right': 'आपका अधिकार',
      'what_to_say': 'क्या कहना है',
      'action_center': 'कार्य केंद्र',
      'documents_needed': 'आपको आवश्यक दस्तावेज़',
      'nearest_office': 'निकटतम शिकायत कार्यालय',
      'generate_application': 'आवेदन पत्र बनाएं',
      'escalation_steps': 'सीढ़ीदार कदम',
      'call_now': 'अभी कॉल करें',
      'farmer': 'किसान',
      'worker': 'कर्मचारी',
      'student': 'छात्र',
      'senior': 'वरिष्ठ नागरिक',
      'english': 'English',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
    },
  };

  static String translate(String key, String languageCode) {
    return translations[languageCode]?[key] ?? translations['en']?[key] ?? key;
  }

  static List<MapEntry<String, String>> getLanguageList() {
    return translations['en']!.entries
        .where(
          (e) =>
              e.key.contains('english') ||
              e.key.contains('hindi') ||
              e.key.contains('telugu') ||
              e.key.contains('tamil') ||
              e.key.contains('kannada') ||
              e.key.contains('marathi'),
        )
        .toList();
  }
}
