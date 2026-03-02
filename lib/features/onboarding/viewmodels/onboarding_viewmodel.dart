import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic_ai_app/models/user_model.dart';
import 'package:civic_ai_app/core/constants/app_constants.dart';

class OnboardingViewModel extends ChangeNotifier {
  String? _selectedLanguage;
  String? _selectedPersona;
  String? _selectedState;
  String? _selectedDistrict;
  bool _isLoading = false;

  String? get selectedLanguage => _selectedLanguage;
  String? get selectedPersona => _selectedPersona;
  String? get selectedState => _selectedState;
  String? get selectedDistrict => _selectedDistrict;
  bool get isLoading => _isLoading;

  final List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  final Map<String, List<String>> districts = {
    'Andhra Pradesh': ['Visakhapatnam', 'Krishna', 'Guntur', 'East Godavari'],
    'Arunachal Pradesh': ['Papum Pare', 'Changlang', 'Lohit'],
    'Assam': ['Kamrup', 'Nagaon', 'Barpeta', 'Sonitpur'],
    'Bihar': ['Patna', 'East Champaran', 'Muzaffarpur', 'Bhagalpur'],
    'Chhattisgarh': ['Raipur', 'Bilaspur', 'Durg', 'Rajnandgaon'],
    // Add more districts as needed
  };

  void selectLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void selectPersona(String persona) {
    _selectedPersona = persona;
    notifyListeners();
  }

  void selectState(String state) {
    _selectedState = state;
    _selectedDistrict = null;
    notifyListeners();
  }

  void selectDistrict(String district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  List<String> getDistrictsForState(String state) {
    return districts[state] ?? [];
  }

  Future<bool> completeOnboarding({
    required String userId,
    required String name,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save preferences
      _selectedLanguage?.let(
        (lang) => prefs.setString(AppConstants.languageKey, lang),
      );
      _selectedPersona?.let(
        (persona) => prefs.setString(AppConstants.personaKey, persona),
      );

      // Create user model
      final user = UserModel(
        id: userId,
        name: name,
        phoneNumber: phoneNumber,
        state: _selectedState ?? '',
        district: _selectedDistrict ?? '',
        persona: _parsePersona(_selectedPersona ?? 'farmer'),
        preferredLanguage: _parseLanguage(_selectedLanguage ?? 'en'),
        createdAt: DateTime.now(),
      );

      // Save user
      prefs.setString(AppConstants.userKey, user.toJson().toString());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Persona _parsePersona(String persona) {
    switch (persona.toLowerCase()) {
      case 'farmer':
        return Persona.farmer;
      case 'worker':
        return Persona.worker;
      case 'student':
        return Persona.student;
      case 'senior':
        return Persona.senior;
      default:
        return Persona.farmer;
    }
  }

  Language _parseLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'en':
      case 'english':
        return Language.english;
      case 'hi':
      case 'hindi':
        return Language.hindi;
      case 'te':
      case 'telugu':
        return Language.telugu;
      case 'ta':
      case 'tamil':
        return Language.tamil;
      case 'kn':
      case 'kannada':
        return Language.kannada;
      case 'mr':
      case 'marathi':
        return Language.marathi;
      default:
        return Language.english;
    }
  }

  bool get canProceed =>
      _selectedLanguage != null &&
      _selectedPersona != null &&
      _selectedState != null &&
      _selectedDistrict != null;
}

extension on String? {
  void let(Function(String) callback) {
    if (this != null) {
      callback(this!);
    }
  }
}
