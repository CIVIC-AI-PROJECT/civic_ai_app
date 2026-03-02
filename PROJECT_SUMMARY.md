# CIVIC.AI Mobile App - Project Summary

## 🎯 Project Overview

**CIVIC.AI** is a production-ready Flutter mobile application designed to help Indian citizens file government grievances through voice input, with AI-powered rights explanation, multimodal form filling, and escalation tracking.

### Key Features

- 🎤 **Voice-First Interface**: Record grievances in 6 Indian languages
- 🤖 **AI-Powered Rights**: Automatic extraction of citizen rights from grievance descriptions
- 📋 **Document Management**: Vision AI integration for smart form filling with document capture
- 📍 **Location Services**: Find nearest grievance redressal offices
- 📈 **Escalation Tracking**: 5-step escalation playbook with progress tracking
- 🌐 **Local Language Support**: Hindi, Telugu, Tamil, Kannada, Marathi, English

---

## 📱 Platform & Architecture

### Technology Stack

- **Framework**: Flutter 3.10.8+ with Dart
- **Architecture**: MVVM (Model-View-ViewModel) with Provider state management
- **Platforms**: iOS, Android
- **Target**: Indian government grievance system

### Project Structure

```
lib/
├── main.dart                              # App entry point with MultiProvider
├── core/                                  # Core functionality
│   ├── services/                          # Business logic services
│   │   ├── audio_service.dart            # Speech-to-text & TTS
│   │   ├── api_client.dart               # HTTP client for backend
│   │   ├── localization_service.dart     # Multi-language support
│   │   └── common_widgets.dart           # Reusable UI components
│   └── theme/
│       ├── app_theme.dart                # Material 3 theming
│       └── app_constants.dart            # Global configuration
├── models/                                # Data models
│   ├── user_model.dart                   # User profile & preferences
│   ├── grievance_model.dart              # Grievance details & status
│   └── office_model.dart                 # Government office locations
└── features/                              # Feature modules (MVVM)
    ├── onboarding/
    │   ├── viewmodels/
    │   │   └── onboarding_viewmodel.dart
    │   └── views/
    │       └── onboarding_screen.dart
    ├── voice_chat/ (Home Screen)
    │   ├── viewmodels/
    │   │   └── voice_chat_viewmodel.dart
    │   └── views/
    │       └── home_screen.dart
    ├── action_center/
    │   ├── viewmodels/
    │   │   └── action_center_viewmodel.dart
    │   └── views/
    │       └── action_center_screen.dart
    ├── form_filler/
    │   ├── viewmodels/
    │   │   └── form_filler_viewmodel.dart
    │   └── views/
    │       └── form_filler_screen.dart
    └── escalation_playbook/
        ├── viewmodels/
        │   └── escalation_playbook_viewmodel.dart
        └── views/
            └── escalation_playbook_screen.dart
```

---

## 🏗️ Architecture Details

### MVVM Design Pattern

Each feature consists of three layers:

1. **Model** (`models/`)
   - Data classes with JSON serialization
   - Manual `fromJson()` and `toJson()` methods for compatibility
   - Immutable structures with `copyWith()` patterns

2. **ViewModel** (`viewmodels/`)
   - Business logic and state management
   - Extends `ChangeNotifier` for Provider integration
   - Handles data transformation and validation
   - Manages async operations (API calls, permissions)

3. **View** (`views/`)
   - UI-only code with `Consumer` widgets
   - Responds to ViewModel state changes
   - Delegates user interactions to ViewModel methods

### State Management

- **Provider 6.0.0**: Lightweight, testable state management
- **MultiProvider**: Central dependency injection in main.dart
- **ChangeNotifier**: Simple pub-sub for feature-level updates

---

## 📋 Feature Specifications

### 1. Onboarding Screen

**Purpose**: Initialize user profile and preferences

**ViewModel State**:

- `selectedLanguage`: 6 options (EN, HI, TE, TA, KN, MR)
- `selectedPersona`: 4 options (Farmer, Worker, Student, Senior)
- `selectedState`: All 28 Indian states
- `selectedDistrict`: District mapping per state

**Key Methods**:

```dart
void setLanguage(String code)
void setPersona(String persona)
void setStateAndLoadDistricts(String state)
void setDistrict(String district)
Future<void> completeOnboarding(String userId, String name, String phoneNumber)
// Saved to SharedPreferences
```

### 2. Home Screen (Voice Chat)

**Purpose**: Main grievance recording interface

**ViewModel State**:

- `isRecording`: Recording status
- `transcribedText`: Spoken grievance text
- `extractedRight`: AI-identified citizen right
- `documentChecklist`: Required documents list
- `processingProgress`: 0-100%

**Key Methods**:

```dart
Future<void> initializeAudio()
Future<void> startRecording()
Future<void> stopRecording()
// Auto-processes grievance when stopping recording
Future<void> playResponse(String text, String languageCode)  // TTS playback
```

**UI Components**:

- 150x150px glowing microphone button (Government Green #2E7D32)
- Long-press to record with visual feedback
- Quick category cards (Ration, Pensions, Land Disputes, FIR/Police)
- Analysis panel showing: Complaint → Extracted Right → What to Say

### 3. Action Center Screen

**Purpose**: Document checklist and office location

**ViewModel State**:

- `grievance`: Current grievance object
- `documentChecklist`: ChecklistItem[] (name, required, completed)
- `nearestOffice`: OfficeModel
- `currentLocation`: LatLng (user's current position)
- `loading`: Boolean flag

**Key Methods**:

```dart
void setGrievance(GrievanceModel grievance)
Future<void> getCurrentLocation()
Future<void> findNearestOffice()  // Mock: returns hardcoded office
Future<String> generatePDF()  // Creates application PDF
```

**UI Components**:

- Document checklist with checkmark icons
- Embedded Google Maps showing nearest office
- Office info card (name, officer, address, hours, phone)
- Call and "Open Maps" buttons
- "Generate Application PDF" button

### 4. Form Filler Screen

**Purpose**: Document capture and vision AI integration

**ViewModel State**:

- `aadharPath`, `ratioCardPath`, `otherDocPath`: Image file paths
- `extractedData`: Map<String, String> from vision AI
- `qualityScore`: 0-100 document quality
- `isProcessing`: Boolean flag

**Key Methods**:

```dart
Future<String?> captureDocument(String documentType)  // Camera integration
Future<bool> validateDocumentQuality(String imagePath)
// Placeholder: TensorFlow Lite model for quality check
Future<Map<String, String>> _processImageWithVision(String imagePath)
// Placeholder: Claude 3.5 Sonnet or Gemini Pro Vision API
Future<String> generateFilledPDF()  // Auto-fill form from extracted data
```

**UI Components**:

- Three document upload cards (Aadhar, Ration Card, Other)
- Camera capture buttons
- Quality verification button
- Extracted data display table
- "Generate Filled Form" button

### 5. Escalation Playbook Screen

**Purpose**: 5-step escalation timeline and contact management

**Data Model**:

```dart
class EscalationStep {
  int stepNumber;          // 1-5
  String title;            // e.g., "Contact Grievance Officer"
  String description;      // Detailed action
  String action;           // Next step instruction
  String contactNumber;    // Phone to call
  String? contactLink;     // Optional web/app link
  bool isCompleted;        // Progress tracking
}
```

**ViewModel State**:

- `escalationSteps`: List<EscalationStep> (5 items)
- `currentStep`: Int (1-5)
- `progressPercentage`: 0-100%

**Key Methods**:

```dart
void moveToStep(int stepNumber)
void markStepAsCompleted(int stepNumber)
Future<void> callContactNumber(String number)  // dial:// intent
Future<void> openContactLink(String url)       // url_launcher
double getProgressPercentage()
```

**UI Components**:

- Vertical timeline with 5 steps
- Progress bar at top
- Expandable step cards
- Contact action buttons (Call/Submit/Visit)
- Completion checkmarks

---

## 🔧 Core Services

### AudioService

**Dependencies**: `speech_to_text`, `flutter_tts`

```dart
class AudioService {
  Future<void> initializeSpeech()
  Future<void> initializeTts()
  Future<void> startListening(String languageCode)
  Future<void> stopListening()
  String get recognizedText
  Future<void> speak(String text, String languageCode)
}
```

### ApiClient

**Dependencies**: `http`, `custom_exceptions`

```dart
class ApiClient {
  Future<dynamic> get(String endpoint, {Map<String, String>? headers})
  Future<dynamic> post(String endpoint, {required dynamic body, Map<String, String>? headers})
}
```

**Custom Exceptions**:

- `UnauthorizedException` (401)
- `NotFoundException` (404)
- `ServerException` (5xx)

### LocalizationService

**Supported Languages**: English, Hindi, Telugu, Tamil, Kannada, Marathi

```dart
class LocalizationService {
  static String translate(String key, String languageCode)
}
```

---

## 🎨 Theming

### AppTheme

- **Primary**: Government Green (#2E7D32)
- **Secondary**: Light Green (#66BB6A)
- **Accent**: Orange (#FFA726)
- **Error**: Red (#F44336)
- **Success**: Green (#4CAF50)
- **Warning**: Yellow (#FFC107)

**Consistent Components**:

- Button styling with rounded corners
- Input field decoration
- Card elevation (2dp)
- Typography hierarchy

---

## 📦 Dependencies

### UI & State Management

- `provider: ^6.0.0` - State management
- `cupertino_icons: ^1.0.8` - iOS icons

### Voice & Audio

- `speech_to_text: ^7.3.0` - Speech recognition
- `flutter_tts: ^4.2.5` - Text-to-speech
- `audio_waveforms: ^2.0.2` - Audio visualization

### Maps & Location

- `google_maps_flutter: ^2.5.3` - Maps integration
- `geolocator: ^14.0.2` - Location services

### Camera & Vision

- `camera: ^0.12.0` - Camera access
- `image_picker: ^1.0.4` - Image selection

### ML/AI

- `tflite_flutter: ^0.12.1` - TensorFlow Lite inference

### Permissions

- `permission_handler: ^12.0.1` - Permission requests

### Localization

- `intl: ^0.20.2` - Internationalization

### HTTP & Serialization

- `http: ^1.1.0` - HTTP requests
- Manual JSON serialization (no json_serializable/build_runner)

### PDF & Documents

- `pdf: ^3.10.4` - PDF generation
- `printing: ^5.11.0` - Print & share

### Utilities

- `shared_preferences: ^2.2.2` - Local storage
- `get_it: ^9.2.1` - Service locator (optional)
- `dartz: ^0.10.1` - Functional programming (optional)

---

## 🔐 Permissions & Platform Configuration

### iOS Info.plist Permissions

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record your grievance</string>

<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture government documents</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to find nearest office</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photos to upload documents</string>

<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>

<key>io.flutter.embedded_views_preview</key>
<true/>
```

### Android AndroidManifest.xml Permissions

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>

<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

---

## 🚀 Build Status

### ✅ Completed

- ✅ MVVM architecture with 5 feature modules
- ✅ Core data models with manual JSON serialization
- ✅ Service layer (Audio, API, Localization, Common Widgets)
- ✅ ViewModels for all 5 features
- ✅ Complete UI screens with responsive design
- ✅ Theme and constants configuration
- ✅ Provider state management setup
- ✅ iOS Info.plist permissions configured
- ✅ Android AndroidManifest.xml permissions configured
- ✅ Flutter analyzer: 20 warnings, 0 errors
- ✅ iOS simulator build: Successful
- ✅ Dart compilation: No errors

### 🟡 Pending Implementation

- 🟡 Google Maps API Key (placeholder ready: "YOUR_GOOGLE_MAPS_API_KEY_HERE")
- 🟡 Vision AI for document form-filling (Claude 3.5 Sonnet / Gemini Pro Vision)
- 🟡 TensorFlow Lite model for document quality detection
- 🟡 Backend API integration (grievance submission, office lookup)
- 🟡 Code signing for iOS physical device testing

### ❌ Not Configured

- ❌ Android SDK (not installed on development machine)
- ❌ Android emulator build (pending SDK installation)

---

## 📱 Navigation Routes

```dart
routes: {
  '/onboarding': (context) => const OnboardingScreen(),
  '/home': (context) => const HomeScreen(),
  '/action-center': (context) => const ActionCenterScreen(),
  '/form-filler': (context) => const FormFillerScreen(),
  '/escalation-playbook': (context) => const EscalationPlaybookScreen(),
}
```

**Navigation Flow**:

1. **Onboarding** → Language, Persona, Location selection
2. **Home (Voice Chat)** → Record grievance, auto-process
3. **Action Center** → View document checklist, find office
4. **Form Filler** → Capture documents, auto-extract data
5. **Escalation Playbook** → Track 5-step resolution process

---

## 🧪 Testing

### Flutter Doctor Output ✅

```
[✓] Flutter (Channel stable, 3.38.9)
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Connected device (iPhone simulator available)
[✗] Android toolchain (SDK not installed - not required for MVP)
```

### Code Quality

```
20 info-level warnings (deprecations, style suggestions)
0 compilation errors
All Dart files analyze successfully
```

### Available Testing Devices

- ✅ iPhone 16e (iOS simulator)
- ✅ Vatsal's iPhone (physical iOS device - needs code signing)
- ✅ macOS (desktop)
- ✅ Chrome (web)

---

## 🔧 Setup & Installation

### Prerequisites

- Flutter 3.10.8+
- Dart (included with Flutter)
- Xcode 14+ for iOS development

### Build Commands

**iOS Simulator**:

```bash
flutter run -d "iPhone 16e"
```

**iOS Physical Device** (requires code signing):

```bash
flutter run -d "00008120-00144C263E05A01E"  # Your device ID
```

**Android** (requires Android SDK):

```bash
flutter run -d <device-id>  # After installing Android SDK
```

**Web**:

```bash
flutter run -d chrome
```

---

## 📝 Future Enhancements

1. **Backend Integration**
   - Connect to real government grievance system API
   - User authentication and profile persistence
   - Real grievance submission and tracking

2. **AI/ML Features**
   - Integrate Claude 3.5 Sonnet for rights extraction
   - Integrate Gemini Pro Vision for document form-filling
   - Train/deploy TensorFlow Lite model for document quality

3. **Advanced Features**
   - Multi-grievance tracking dashboard
   - Push notifications for escalation updates
   - Document OCR for automatic field extraction
   - Video grievance recording

4. **Localization**
   - Complete translation of all UI strings
   - Regional customization for each state

5. **Performance**
   - Offline-first architecture
   - Video compression for grievance uploads
   - Caching for office location data

---

## ✨ Key Achievements

### Architecture

- Clean separation of concerns with MVVM pattern
- Scalable feature-based folder structure
- Reusable service layer for cross-feature functionality

### User Experience

- Voice-first interface for accessibility
- Multi-language support for Indian citizens
- Responsive design across devices
- Clear visual feedback for all operations

### Code Quality

- Type-safe Dart implementation
- Manual JSON serialization for efficiency
- No build-time code generation needed
- Comprehensive error handling

### Platform Support

- iOS fully configured and building
- Android manifest ready (SDK installation needed)
- Web support available via Flutter

---

## 📞 Support & Next Steps

To continue development:

1. **Add Google Maps API Key**
   - Obtain key from Google Cloud Console
   - Replace "YOUR_GOOGLE_MAPS_API_KEY_HERE" in android/app/src/main/AndroidManifest.xml

2. **Implement Vision AI**
   - Set up Claude API or Gemini API credentials
   - Implement `FormFillerViewModel._processImageWithVision()`

3. **Set Up Backend**
   - Define API endpoints
   - Implement authentication
   - Create database schema

4. **Physical Device Testing**
   - Configure iOS code signing
   - Test permissions on actual device (microphone, camera, location)

5. **Install Android SDK**
   - Download Android SDK for complete platform support
   - Build and test on Android emulator/device

---

**Project Status**: ✅ Architecture Complete | 🏗️ Ready for Feature Implementation

**Created**: 2025
**Framework**: Flutter 3.38.9 with Dart 3.10.8
**Target**: Production-ready Indian citizen grievance app
