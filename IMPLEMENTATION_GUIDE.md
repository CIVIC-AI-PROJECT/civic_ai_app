# CIVIC.AI - Implementation Guide for Pending Features

This guide provides step-by-step instructions for implementing the remaining features in the CIVIC.AI mobile app.

---

## 1. Google Maps API Key Configuration

### Objective

Enable Google Maps functionality on iOS and Android platforms.

### Prerequisites

- Google Cloud Account (create at https://console.cloud.google.com)
- Project billing enabled

### Steps

#### 1.1 Obtain Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable Google Maps Platform APIs:
   - Google Maps SDK for iOS
   - Google Maps SDK for Android
4. Create API key:
   - Click "Create Credentials" → "API Key"
   - Copy the generated key

#### 1.2 Configure Android

**File**: `android/app/src/main/AndroidManifest.xml`

Replace this line:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

With your actual key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyC_YOUR_ACTUAL_KEY_HERE"/>
```

**Set Android Key Restrictions** (Google Cloud Console):

1. Go to Credentials → Select your API key
2. Under "Key restrictions":
   - Application restrictions: Android apps
   - Add your app's SHA-1 certificate fingerprint
3. Under "API restrictions": Select "Google Maps SDK for Android"
4. Save changes

#### 1.3 Configure iOS

**File**: `ios/Runner/Info.plist`

Add Google Maps API key (iOS doesn't require it in Info.plist if using Cloud restrictions, but can be added):

```xml
<key>com.google.ios.maps.API_KEY</key>
<string>AIzaSyC_YOUR_ACTUAL_KEY_HERE</string>
```

**Set iOS Key Restrictions** (Google Cloud Console):

1. Go to Credentials → Select your API key
2. Under "Key restrictions":
   - Application restrictions: iOS apps
   - Add your Bundle Identifier: `com.example.civicAiApp`
3. Under "API restrictions": Select "Google Maps SDK for iOS"
4. Save changes

#### 1.4 Get Android Certificate Fingerprint

Run this command to get your development key's SHA-1:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep "SHA1"
```

#### 1.5 Test Configuration

**Test Android**:

```bash
flutter run -d <android-device>
# Navigate to Action Center screen
# Verify map loads without API errors
```

**Test iOS**:

```bash
flutter run -d "iPhone 16e"
# Navigate to Action Center screen
# Verify map loads without API errors
```

---

## 2. Vision AI for Document Form-Filling

### Objective

Automatically extract data from documents using Claude 3.5 Sonnet or Gemini Pro Vision API.

### Prerequisites

- Claude API key (https://console.anthropic.com) OR
- Google Generative AI API key (https://ai.google.dev)
- Current implementation: `FormFillerViewModel._processImageWithVision()`

### Steps

#### 2.1 Choose Vision Model

**Option A: Claude 3.5 Sonnet** (Recommended for high accuracy)

```dart
// Dependencies to add to pubspec.yaml
anthropic: ^1.0.0  # Official Anthropic SDK
```

**Option B: Google Gemini Pro Vision**

```dart
// Dependencies to add to pubspec.yaml
google_generative_ai: ^0.3.0  # Official Google SDK
```

#### 2.2 Set Up API Credentials

**For Claude API**:

1. Go to https://console.anthropic.com/account/keys
2. Generate new API key
3. Store securely in your app (NOT in code)

**For Google Gemini API**:

1. Go to https://ai.google.dev
2. Create API key
3. Store securely in your app

#### 2.3 Create Vision Model Service

Create new file: `lib/core/services/vision_model_service.dart`

```dart
import 'package:anthropic/anthropic.dart';  // Or google_generative_ai
import 'package:image/image.dart' as img;
import 'dart:convert' show base64;

class VisionModelService {
  final String apiKey;
  late final Anthropic _client;  // Or GoogleGenerativeAI

  VisionModelService({required this.apiKey}) {
    _client = Anthropic(apiKey: apiKey);
  }

  /// Extract form data from document image
  /// Returns: Map<String, String> with extracted fields
  Future<Map<String, String>> extractDocumentData(String imagePath) async {
    // Read and encode image file
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64.encode(imageBytes);

    // Determine media type from file extension
    String mediaType = 'image/jpeg';
    if (imagePath.endsWith('.png')) mediaType = 'image/png';

    // Create prompt for data extraction
    final prompt = '''
    You are an expert document analysis assistant. Extract all relevant information
    from this government document (Aadhar, Ration Card, or other ID).

    Return ONLY a JSON object with these fields:
    {
      "name": "",
      "phone": "",
      "aadharNumber": "",
      "ratioCardNumber": "",
      "state": "",
      "district": "",
      "address": "",
      "dob": ""
    }

    If a field is not present, use empty string. Do not include any other text.
    ''';

    // Call Vision API
    final response = await _client.messages.create(
      model: 'claude-3-5-sonnet-20241022',
      maxTokens: 500,
      messages: [
        Message(
          role: 'user',
          content: [
            ContentBlock(
              type: 'image',
              source: ImageSource(
                type: 'base64',
                mediaType: mediaType,
                data: base64Image,
              ),
            ),
            ContentBlock(
              type: 'text',
              text: prompt,
            ),
          ],
        ),
      ],
    );

    // Parse response
    final responseText = response.content.first.text;
    final jsonString = _extractJson(responseText);
    final data = jsonDecode(jsonString);

    return Map<String, String>.from(data);
  }

  /// Helper to extract JSON from response text
  String _extractJson(String text) {
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}') + 1;
    if (startIndex == -1 || endIndex == 0) {
      throw Exception('Invalid response format');
    }
    return text.substring(startIndex, endIndex);
  }
}
```

#### 2.4 Update FormFillerViewModel

Modify `lib/features/form_filler/viewmodels/form_filler_viewmodel.dart`:

```dart
class FormFillerViewModel extends ChangeNotifier {
  late VisionModelService _visionModelService;

  FormFillerViewModel() {
    // Initialize with API key from secure storage or environment
    _visionModelService = VisionModelService(
      apiKey: _getApiKeyFromSecureStorage(),
    );
  }

  Future<Map<String, String>> _processImageWithVision(String imagePath) async {
    try {
      final extractedData = await _visionModelService.extractDocumentData(imagePath);
      return extractedData;
    } catch (e) {
      print('Vision AI error: $e');
      // Fallback to mock data or empty
      return {};
    }
  }

  String _getApiKeyFromSecureStorage() {
    // TODO: Use flutter_secure_storage or similar
    // For now, use environment variable or constant
    return 'YOUR_API_KEY_HERE';
  }
}
```

#### 2.5 Test Vision AI

```bash
# Run app on simulator/device
flutter run -d "iPhone 16e"

# Navigate to Form Filler screen
# Capture a document (Aadhar or Ration Card)
# Verify extracted data displays correctly
```

#### 2.6 Deployment Notes

- **Security**: Never commit API keys to version control
- **Storage**: Use `flutter_secure_storage` for secure API key storage
- **Fallback**: Implement graceful degradation if Vision API fails
- **Cost**: Monitor API usage to manage costs
- **Rate Limiting**: Implement backoff for API requests

---

## 3. TensorFlow Lite Document Quality Detection

### Objective

Validate document image quality before submission (focus, lighting, completeness).

### Prerequisites

- TensorFlow Lite model file (.tflite)
- Model training or pre-trained model download
- `tflite_flutter: ^0.12.1` (already in dependencies)

### Steps

#### 3.1 Obtain or Train Model

**Option A: Use Pre-trained Model** (Recommended for MVP)

1. Download document quality detection model from TensorFlow Hub
2. Example: Document scanner quality model
3. Place in `assets/models/document_quality.tflite`

**Option B: Train Custom Model** (Advanced)

1. Collect Indian government document samples
2. Label: Good, Poor (focus, lighting, completeness)
3. Train TensorFlow model using tf.keras
4. Convert to .tflite format
5. Place in `assets/models/`

#### 3.2 Update pubspec.yaml

File: `pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/models/document_quality.tflite
```

#### 3.3 Create ML Model Service

Create file: `lib/core/services/ml_model_service.dart`

```dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MLModelService {
  late Interpreter _interpreter;
  bool _isInitialized = false;

  /// Initialize TensorFlow Lite interpreter
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/document_quality.tflite',
      );
      _isInitialized = true;
      print('ML Model initialized');
    } catch (e) {
      print('Error initializing ML model: $e');
      rethrow;
    }
  }

  /// Check document quality (0-100 score)
  /// Higher score = better quality
  Future<double> evaluateDocumentQuality(String imagePath) async {
    if (!_isInitialized) await initialize();

    try {
      // Load and preprocess image
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) throw Exception('Failed to decode image');

      // Resize to model input size (e.g., 224x224)
      final resized = img.copyResize(
        image,
        width: 224,
        height: 224,
      );

      // Convert to input tensor format
      final input0 = _imageToByteList(resized);

      // Set input
      _interpreter.allocateTensors();
      _interpreter.setInput(0, input0);

      // Run inference
      _interpreter.invoke();

      // Get output
      final output = _interpreter.getOutputTensor(0).data as List<double>;

      // Output is typically [quality_score] or [bad_prob, good_prob]
      // Adjust based on your model's output format
      double qualityScore = output[0] * 100;  // Convert to 0-100 scale

      print('Document quality score: $qualityScore');
      return qualityScore;
    } catch (e) {
      print('Error evaluating document quality: $e');
      return 50.0;  // Return neutral score on error
    }
  }

  /// Convert image to input tensor format
  List<int> _imageToByteList(img.Image image) {
    var bytes = Int8List(1 * 224 * 224 * 3);
    int pixelIndex = 0;

    for (var i = 0; i < 224; i++) {
      for (var j = 0; j < 224; j++) {
        var pixel = image.getPixelSafe(j, i);
        bytes[pixelIndex++] = ((pixel >> 16) & 0xFF) - 127;  // R
        bytes[pixelIndex++] = ((pixel >> 8) & 0xFF) - 127;   // G
        bytes[pixelIndex++] = (pixel & 0xFF) - 127;          // B
      }
    }

    return bytes;
  }

  /// Release resources
  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
      _isInitialized = false;
    }
  }
}
```

#### 3.4 Update FormFillerViewModel

Modify `lib/features/form_filler/viewmodels/form_filler_viewmodel.dart`:

```dart
class FormFillerViewModel extends ChangeNotifier {
  late MLModelService _mlModelService;

  FormFillerViewModel() {
    _mlModelService = MLModelService();
    _mlModelService.initialize();
  }

  Future<bool> validateDocumentQuality(String imagePath) async {
    try {
      final qualityScore = await _mlModelService.evaluateDocumentQuality(imagePath);

      // Accept documents with quality score > 60
      if (qualityScore > 60) {
        _qualityScore = qualityScore.toInt();
        notifyListeners();
        return true;
      } else {
        print('Document quality too low: $qualityScore');
        return false;
      }
    } catch (e) {
      print('Error validating document: $e');
      return true;  // Allow on error for user experience
    }
  }

  @override
  void dispose() {
    _mlModelService.dispose();
    super.dispose();
  }
}
```

#### 3.5 Test ML Model

```bash
# Run app
flutter run -d "iPhone 16e"

# Navigate to Form Filler screen
# Capture a document
# Check console for quality score output
# Score > 60 should allow submission
```

---

## 4. Backend API Integration

### Objective

Connect to real government grievance backend for data persistence and processing.

### Prerequisites

- Backend API endpoint (e.g., https://api.civic-ai.in)
- API documentation and authentication method
- Current placeholder: `ApiClient` in `lib/core/services/api_client.dart`

### Steps

#### 4.1 Define API Endpoints

Update `lib/core/services/api_client.dart`:

```dart
const String BASE_URL = 'https://api.civic-ai.in';

class ApiEndpoints {
  // User endpoints
  static const String createUser = '/api/users/create';
  static const String updateUser = '/api/users/{userId}';
  static const String getUser = '/api/users/{userId}';

  // Grievance endpoints
  static const String submitGrievance = '/api/grievances/submit';
  static const String getGrievance = '/api/grievances/{grievanceId}';
  static const String listGrievances = '/api/grievances/user/{userId}';
  static const String analyzeGrievance = '/api/grievances/analyze';

  // Office endpoints
  static const String getNearestOffices = '/api/offices/nearest';
  static const String getOffice = '/api/offices/{officeId}';

  // Escalation endpoints
  static const String submitEscalation = '/api/escalations/submit';
  static const String getEscalation = '/api/escalations/{escalationId}';
}
```

#### 4.2 Create Request/Response Models

File: `lib/models/api_models.dart`

```dart
// Request models
class CreateUserRequest {
  final String name;
  final String phoneNumber;
  final String aadharNumber;
  final String state;
  final String district;
  final String persona;
  final String preferredLanguage;

  CreateUserRequest({
    required this.name,
    required this.phoneNumber,
    required this.aadharNumber,
    required this.state,
    required this.district,
    required this.persona,
    required this.preferredLanguage,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phoneNumber': phoneNumber,
    'aadharNumber': aadharNumber,
    'state': state,
    'district': district,
    'persona': persona,
    'preferredLanguage': preferredLanguage,
  };
}

class SubmitGrievanceRequest {
  final String userId;
  final String title;
  final String description;
  final String transcription;
  final String category;
  final List<String> documentPaths;
  final double latitude;
  final double longitude;

  SubmitGrievanceRequest({
    required this.userId,
    required this.title,
    required this.description,
    required this.transcription,
    required this.category,
    required this.documentPaths,
    required this.latitude,
    required this.longitude,
  });

  Future<Map<String, dynamic>> toJsonWithDocuments() async {
    List<String> base64Documents = [];
    for (String path in documentPaths) {
      final bytes = await File(path).readAsBytes();
      base64Documents.add(base64.encode(bytes));
    }

    return {
      'userId': userId,
      'title': title,
      'description': description,
      'transcription': transcription,
      'category': category,
      'documents': base64Documents,
      'latitude': latitude,
      'longitude': longitude,
      'submittedAt': DateTime.now().toIso8601String(),
    };
  }
}

// Response models
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }
}

class GrievanceResponse {
  final String id;
  final String userId;
  final String title;
  final String status;
  final String? assignedToOfficer;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  GrievanceResponse({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    this.assignedToOfficer,
    required this.createdAt,
    this.resolvedAt,
  });

  factory GrievanceResponse.fromJson(Map<String, dynamic> json) {
    return GrievanceResponse(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      status: json['status'],
      assignedToOfficer: json['assignedToOfficer'],
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }
}
```

#### 4.3 Update ApiClient

File: `lib/core/services/api_client.dart`

```dart
class ApiClient {
  static const String baseUrl = 'https://api.civic-ai.in';
  static const Duration timeout = Duration(seconds: 30);

  late String? _authToken;

  /// Submit a grievance with documents
  Future<GrievanceResponse> submitGrievance(
    SubmitGrievanceRequest request,
  ) async {
    try {
      final requestData = await request.toJsonWithDocuments();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.submitGrievance}'),
        headers: _getHeaders(),
        body: jsonEncode(requestData),
      ).timeout(timeout);

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return GrievanceResponse.fromJson(json['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid authentication');
      } else if (response.statusCode == 400) {
        throw ServerException('Invalid request: ${response.body}');
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw ServerException('No internet connection');
    }
  }

  /// Find nearest grievance offices
  Future<List<OfficeModel>> getNearestOffices(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getNearestOffices}')
            .replace(queryParameters: {
          'latitude': lat.toString(),
          'longitude': lng.toString(),
          'radius': '50',  // 50km radius
        }),
        headers: _getHeaders(),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((o) => OfficeModel.fromJson(o)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid authentication');
      } else {
        throw ServerException('Error fetching offices: ${response.statusCode}');
      }
    } on SocketException {
      throw ServerException('No internet connection');
    }
  }

  /// Analyze grievance text to extract rights
  Future<String> analyzeGrievanceText(String grievanceText) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.analyzeGrievance}'),
        headers: _getHeaders(),
        body: jsonEncode({'text': grievanceText}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data']['extractedRight'] ?? '';
      } else {
        throw ServerException('Error analyzing grievance');
      }
    } on SocketException {
      throw ServerException('No internet connection');
    }
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }
}
```

#### 4.4 Update ViewModels

Update each ViewModel to use API client instead of mock data.

**Example: VoiceChatViewModel**

```dart
class VoiceChatViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final AudioService _audioService;

  VoiceChatViewModel({
    required AudioService audioService,
    ApiClient? apiClient,
  }) : _audioService = audioService,
       _apiClient = apiClient ?? ApiClient();

  Future<void> processGrievance() async {
    try {
      _isProcessing = true;
      notifyListeners();

      // Get extracted right from API
      _extractedRight = await _apiClient.analyzeGrievanceText(_transcribedText);

      // Save grievance draft locally
      _currentGrievance = GrievanceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _transcribedText.split('\n').first,
        description: _transcribedText,
        audioPath: _audioPath,
        transcription: _transcribedText,
      );

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> submitGrievance(List<String> documentPaths,
      {required double latitude, required double longitude}) async {
    try {
      final request = SubmitGrievanceRequest(
        userId: _userId,
        title: _currentGrievance.title,
        description: _currentGrievance.description,
        transcription: _transcribedText,
        category: _currentGrievance.category,
        documentPaths: documentPaths,
        latitude: latitude,
        longitude: longitude,
      );

      final response = await _apiClient.submitGrievance(request);

      // Save submission ID for tracking
      _currentGrievance = _currentGrievance.copyWith(
        id: response.id,
        status: response.status,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

#### 4.5 Test API Integration

```bash
# Set up backend server locally or use staging
# Update BASE_URL in api_client.dart to your backend

# Run app
flutter run -d "iPhone 16e"

# Test user creation
flutter run -d "iPhone 16e"
# Complete onboarding

# Test grievance submission
# Record grievance on home screen
# Submit through action center
# Check backend logs for received grievance
```

---

## 5. iOS Code Signing for Physical Device

### Objective

Enable running the app on an actual iPhone device.

### Prerequisites

- Apple Developer Account (paid: $99/year)
- Physical iPhone connected via USB
- Xcode 14+

### Steps

#### 5.1 Set Up Developer Account

1. Go to https://developer.apple.com
2. Create Apple Developer Account / Sign in
3. Enroll in Apple Developer Program
4. Enable code signing on your account

#### 5.2 Create Development Certificate

In Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode:

```bash
open ios/Runner.xcworkspace
```

2. Select "Runner" project → "Runner" target
3. Go to "Signing & Capabilities"
4. Select your team in "Team" dropdown
5. Xcode automatically creates certificate

#### 5.3 Create Provisioning Profile

1. Go to https://developer.apple.com/account
2. Certificates, Identifiers & Profiles
3. Click "Identifiers" → "+"
4. Choose "App IDs"
5. Enter Bundle ID: `com.example.civicAiApp`
6. Create provisioning profile for App ID
7. Download and install

#### 5.4 Update Xcode Project

In Xcode:

1. Select Runner project
2. Go to "Build Settings"
3. Search "Code Signing"
4. Set "Code Signing Identity" to your certificate
5. Set "Development Team" to your team ID

#### 5.5 Update Flutter Configuration

File: `ios/Runner/Info.plist`

```xml
<key>NSHumanReadableCopyright</key>
<string>Your Company Name</string>
```

#### 5.6 Build & Deploy

```bash
# Connect iPhone via USB
# Unlock and select "Trust this device"

# List connected devices
flutter devices

# Run on device
flutter run -d "00008120-00144C263E05A01E"

# Or build release
flutter build ios
open build/ios/ipa/*.ipa
```

#### 5.7 Grant App Permissions

When running on device:

1. Allow microphone access
2. Allow camera access
3. Allow location access
4. Allow photo library access

---

## 6. Testing Checklist

### Functional Testing

- [ ] Onboarding screen
  - [ ] Language selection works
  - [ ] Persona selection works
  - [ ] State/district selection works
  - [ ] Data saved to SharedPreferences

- [ ] Home Screen (Voice Chat)
  - [ ] Microphone permission granted
  - [ ] Recording starts/stops
  - [ ] Transcription displays
  - [ ] Quick category selection works

- [ ] Action Center
  - [ ] Google Maps loads
  - [ ] Location permission granted
  - [ ] Nearest office found
  - [ ] Office details display

- [ ] Form Filler
  - [ ] Camera permission granted
  - [ ] Document capture works
  - [ ] Vision AI extracts data (if integrated)
  - [ ] Quality check works (if integrated)

- [ ] Escalation Playbook
  - [ ] Timeline displays
  - [ ] Step expansion works
  - [ ] Call button dials number
  - [ ] Progress updates

### Performance Testing

- [ ] App loads in < 2 seconds
- [ ] Navigation is smooth
- [ ] No memory leaks
- [ ] Voice recording stable for 5+ minutes
- [ ] Large PDF generation completes

### Permission Testing (Physical Device)

- [ ] Request microphone → User accepts/denies
- [ ] Request camera → User accepts/denies
- [ ] Request location → User accepts/denies
- [ ] Request photo library → User accepts/denies
- [ ] Graceful handling if permission denied

### API Integration Testing

- [ ] User creation successful
- [ ] Grievance submission successful
- [ ] Error handling for network errors
- [ ] Proper error messages displayed
- [ ] Data synced to backend

---

## Development Tips

### Local Testing Without Backend

```dart
// In ApiClient, create mock mode:
const bool MOCK_MODE = true;

Future<GrievanceResponse> submitGrievance(SubmitGrievanceRequest request) {
  if (MOCK_MODE) {
    return Future.value(GrievanceResponse(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      userId: request.userId,
      title: request.title,
      status: 'Submitted',
      createdAt: DateTime.now(),
    ));
  }
  // Real API call
}
```

### Enable Debug Logging

```dart
// Add to main.dart
if (kDebugMode) {
  debugPrint = (String? message, {int? wrapWidth}) {
    inspect(message);
  };
}
```

### Monitor API Calls

```bash
# View network calls in real-time
flutter run -d "iPhone 16e" --verbose 2>&1 | grep "http"
```

---

## Deployment Checklist

Before production release:

- [ ] Replace all placeholder API keys
- [ ] Set appropriate error messages for users
- [ ] Implement proper logging (not prints)
- [ ] Add analytics tracking
- [ ] Perform security audit
- [ ] Test on multiple iOS/Android versions
- [ ] Submit to Apple App Store
- [ ] Submit to Google Play Store
- [ ] Set up monitoring/crash reporting
- [ ] Prepare user documentation

---

## Support Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Dart Language**: https://dart.dev
- **Provider Package**: https://pub.dev/packages/provider
- **Google Maps API**: https://developers.google.com/maps
- **Claude API**: https://console.anthropic.com
- **Google Generative AI**: https://ai.google.dev
- **TensorFlow Lite**: https://www.tensorflow.org/lite

---

**Last Updated**: 2025
**Status**: Implementation Guide Complete
