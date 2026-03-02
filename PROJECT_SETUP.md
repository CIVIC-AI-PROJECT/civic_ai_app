# CIVIC.AI - Voice-First Government Grievance Mobile App

A comprehensive Flutter mobile application designed to empower Indian citizens to understand and file government grievances through a voice-first, AI-powered interface.

## Project Overview

CIVIC.AI is a cutting-edge mobile application that bridges the gap between rural citizens and government services in India. The app uses:

- **Voice-First Interface**: Citizens can file grievances entirely through voice input
- **AI-Powered Rights Explanation**: Claude 3.5 Sonnet/Gemini Pro Vision for understanding user rights
- **Multimodal Form Filler**: Vision AI to extract document information automatically
- **Edge-AI Document Checker**: TensorFlow Lite for on-device document quality verification
- **MVVM Architecture**: Clean separation of concerns for maintainability and testing

## Features

### 1. **Persona Setup (Onboarding)**

- Multi-language support (English, हिंदी, తెలుగు, தமிழ், ಕನ್ನಡ, मराठी)
- Visual persona selection (Farmer, Worker, Student, Senior)
- AutoLocation detection (State/District selection)
- Filters irrelevant government data based on user profile

### 2. **Voice-First Home Screen**

- Large, glowing microphone button for easy voice input
- Quick category taps (Ration/PDS, Pensions, Land Disputes, FIR/Police)
- Audio playback of prompts for illiterate users
- Real-time audio waveform visualization

### 3. **Rights & Action Thread**

- Displays user's voice complaint with transcription
- AI-generated explanation of the user's government rights
- "What to Say" script with audio playback
- Ready-to-use dialogue the user can play to officials

### 4. **Action Center (Maps & Documents)**

- Document checklist with collected status
- Embedded map showing nearest grievance redressal office
- Pre-filled PDF application generator
- Direct call button to office
- Escalation pathway visualization

### 5. **Zero-Typing Form Filler (Vision-to-Action)**

- Camera capture for Aadhar, Ration Card, and other documents
- Vision AI extracts text and data fields automatically
- Auto-populated PDF forms with extracted information
- No manual typing required

### 6. **Edge-AI Document Checker**

- On-device TensorFlow Lite model for document quality
- Detects blur, glare, incorrect borders in real-time
- Prevents rejected applications before submission
- Saves rural data bandwidth by processing locally

### 7. **Escalation Playbook**

- 5-step escalation timeline
- Step 1: Local Official Contact
- Step 2: District Officer Complaint
- Step 3: CM Helpline Escalation
- Step 4: PGRAM Portal Filing
- Step 5: Legal Remedies
- Progress tracking and step completion markers

## Architecture

### MVVM Pattern

The application follows MVVM (Model-View-ViewModel) architecture:

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── theme/              # Theme configuration
│   └── services/           # Reusable services (API, Audio, etc.)
├── features/
│   ├── onboarding/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
│   ├── voice_chat/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
│   ├── action_center/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
│   ├── form_filler/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
│   └── escalation_playbook/
│       ├── models/
│       ├── viewmodels/
│       └── views/
├── models/                 # Core data models
└── main.dart
└── assets/
    ├── images/            # App images
    ├── i18n/              # Localization files
    └── models/            # ML models (.tflite files)
```

### Key Components

#### Models

- **UserModel**: User profile (name, location, persona, language preference)
- **GrievanceModel**: Grievance data (type, status, extracted rights, documents)
- **OfficeModel**: Government office information (address, contact, location)

#### ViewModels (State Management)

- **OnboardingViewModel**: Manages onboarding flow
- **VoiceChatViewModel**: Handles voice input and grievance processing
- **ActionCenterViewModel**: Manages documents and office location
- **FormFillerViewModel**: Processes document uploads and extraction
- **EscalationPlaybookViewModel**: Manages escalation steps and progress

#### Services

- **AudioService**: Speech-to-text and text-to-speech functionality
- **ApiClient**: HTTP client for backend communication
- **LocalizationService**: Multi-language support
- **DocumentQualityChecker**: TensorFlow Lite for on-device ML

#### Views (Screens)

- **OnboardingScreen**: Language, persona, location selection
- **HomeScreen**: Voice-first grievance input
- **ActionCenterScreen**: Documents and maps
- **FormFillerScreen**: Vision-based document upload
- **EscalationPlaybookScreen**: Escalation steps

## Dependencies

### Core Dependencies

```yaml
provider: ^6.0.0 # State management (MVVM)
speech_to_text: ^6.6.0 # Speech recognition
flutter_tts: ^0.14.0 # Text-to-speech
google_maps_flutter: ^2.5.3 # Maps integration
camera: ^0.10.5+5 # Camera access
image_picker: ^1.0.4 # Image selection
tflite_flutter: ^0.10.1 # ML model inference
permission_handler: ^11.4.4 # Permissions management
geolocator: ^9.0.2 # GPS location
intl: ^0.19.0 # Localization
pdf: ^3.10.4 # PDF generation
http: ^1.1.0 # HTTP requests
shared_preferences: ^2.2.2 # Local storage
json_serializable: ^6.7.1 # JSON serialization
```

## Installation & Setup

### Prerequisites

- Flutter SDK >= 3.10.8
- Dart SDK >= 3.10.8
- iOS: Xcode 14+ (for iOS development)
- Android: Android Studio, NDK

### Steps

1. **Clone Repository**

   ```bash
   git clone <repo-url>
   cd civic_ai_app
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate JSON Serialization Code**

   ```bash
   flutter pub run build_runner build
   ```

4. **Run the App**

   ```bash
   # iOS
   flutter run -d "iPhone 15 Pro"

   # Android
   flutter run -d emulator-5554
   ```

### Android Setup

Add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record your grievance</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture your documents</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to find nearest government office</string>
```

## Usage Flow

### User Journey

1. **Onboarding**
   - User selects language (text shown in selected language)
   - User selects persona (Farmer, Worker, Student, Senior)
   - User selects state and district

2. **Home Screen**
   - User presses microphone to start recording complaint
   - App transcribes voice to text
   - User can use quick category buttons or free-form complaint

3. **Rights & Action**
   - AI analyzes complaint and identifies rights
   - App displays relevant government policy
   - "What to Say" script is generated and audio-playable
   - User can save grievance or proceed to next steps

4. **Action Center**
   - Display required documents for this grievance type
   - Show nearest government office on map
   - Generate official PDF application

5. **Form Filler** (Optional)
   - User takes photos of documents (Aadhar, Ration Card, etc.)
   - Vision AI extracts all text and data
   - Documents are auto-filled into official form
   - PDF is ready to print/submit

6. **Escalation Playbook**
   - If grievance is not resolved locally
   - Shows 5 escalation steps
   - User marks steps as complete
   - Direct call buttons for escalation contacts

## API Integration

### Backend Integration Points

The app is designed to integrate with a backend AI service for:

1. **Grievance Analysis**

   ```
   POST /api/grievances/analyze
   Input: { transcription, languageCode, persona, category }
   Output: { extractedRight, documents, office, escalationScript }
   ```

2. **Office Location Finder**

   ```
   GET /api/offices/nearest?lat=XX&lng=YY&state=STATE&type=TYPE
   Output: [ { name, address, contact, hours, documents } ]
   ```

3. **Heatmap Data** (Admin Dashboard)
   ```
   GET /api/admin/heatmap?state=STATE&timeRange=24h
   Output: [ { location, count, issues, trend } ]
   ```

## AI/ML Integration

### Vision AI (Multimodal Form Filler)

Use Claude 3.5 Sonnet or Gemini Pro Vision:

```dart
// Example pseudocode
final visionResponse = await aiClient.analyzeDocument(
  imageBytes: cameraImageBytes,
  documentType: 'aadhar'
);
// Returns: { name, age, address, idNumber, validUntil, ... }
```

### Edge-AI (Document Quality)

Use TensorFlow Lite model:

```dart
final interpreter = await Interpreter.fromAsset('document_quality.tflite');
final output = await interpreter.run(imageData);
// Returns: { blurScore: 0.95, glareScore: 0.12, borderScore: 0.98 }
```

### NLP Clustering (Predictive Heatmaps)

Use backend ML model for entity extraction and clustering:

```
Input: [ voice_complaint_1, voice_complaint_2, ... ]
Output: [ cluster { location, issue_type, severity, pattern } ]
```

## Testing

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test --verbose
```

### Integration Tests

```bash
flutter test integration_test
```

## Localization

Supported languages:

- English (en)
- हिंदी (hi)
- తెలుగు (te)
- தமிழ் (ta)
- ಕನ್ನಡ (kn)
- मराठी (mr)

Add more languages in `lib/core/services/localization_service.dart`

## Performance Optimization

1. **Image Optimization**: Compress camera images before upload
2. **Edge ML**: Run document quality check locally to reduce server load
3. **Caching**: Cache office locations and rights data locally
4. **Lazy Loading**: Load escalation steps on demand
5. **Audio Compression**: Compress voice notes before upload

## Security

- Use HTTPS for all API calls
- Encrypt sensitive data in local storage
- Validate user input on client and server
- Implement rate limiting for API calls
- Use OAuth 2.0 for authentication
- Follow GDPR/India data protection laws

## Future Enhancements

1. **Biometric Authentication**: Fingerprint/Face ID login
2. **WhatsApp Integration**: File grievances via WhatsApp
3. **SMS Fallback**: For users without internet
4. **Offline Mode**: Sync when back online
5. **Community Forum**: Connect users with similar grievances
6. **Real-Time Notifications**: Track grievance status updates
7. **Multi-Format Support**: Bill photos, handwritten documents
8. **Grievance Analytics Dashboard**: For government officials

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Submit a pull request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Contact & Support

- **Website**: https://civic-ai.org
- **Email**: support@civic-ai.org
- **GitHub**: https://github.com/civic-ai/civic-ai-app
- **Twitter**: @CivicAI_India

## Acknowledgments

- Built with Flutter and Dart
- Powered by Claude 3.5 Sonnet / Gemini Pro Vision
- Uses TensorFlow Lite for on-device ML
- Community-driven development

---

**Remember**: This app is designed to empower citizens, not replace official government services. Always follow proper legal procedures and official channels.
