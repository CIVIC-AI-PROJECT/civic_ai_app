# CIVIC.AI - Quick Start Guide

Get up and running with the CIVIC.AI Flutter mobile app in minutes.

---

## Prerequisites

### System Requirements

- **macOS** 10.14+ (for iOS development)
- **Xcode** 14.0+ (from App Store)
- **Flutter** 3.10.8+ ([flutter.dev](https://flutter.dev/docs/get-started/install))
- **Dart** (included with Flutter)

### Verify Installation

```bash
flutter doctor
# Should show:
# [✓] Flutter
# [✓] Xcode
# [✓] Connected device (at least one iOS simulator/device)
```

---

## Project Setup (5 Minutes)

### 1. Clone & Navigate

```bash
cd /Users/vatsalgupta/Developer/civic_ai_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate BuildRunner (if needed - already completed)

```bash
# Usually not needed, but if compilation issues:
flutter clean && flutter pub get
```

---

## Running the App

### Option 1: iOS Simulator (Easiest)

```bash
# List available simulators
flutter emulators

# Launch simulator
flutter emulators --launch "iPhone 16e"

# Run app (builds automatically)
flutter run

# Or with specific simulator
flutter run -d "iPhone 16e"
```

### Option 2: Physical iPhone (Requires Code Signing)

```bash
# Connect iPhone via USB
# Unlock device and select "Trust"

# List connected devices
flutter devices

# Run on device
flutter run -d <DEVICE_ID>
```

### Option 3: Hot Reload Development

```bash
# Start app
flutter run

# Once running, press 'r' to hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

---

## Project Structure Quick Reference

### Key Directories

```
lib/
├── main.dart                    ← App entry point
├── core/
│   ├── services/               ← Business logic
│   │   ├── audio_service.dart
│   │   ├── api_client.dart
│   │   ├── localization_service.dart
│   │   └── common_widgets.dart
│   └── theme/
│       ├── app_theme.dart      ← Colors, fonts, styles
│       └── app_constants.dart  ← Configuration
├── models/                      ← Data classes
│   ├── user_model.dart
│   ├── grievance_model.dart
│   └── office_model.dart
└── features/                    ← Feature modules (MVVM)
    ├── onboarding/
    ├── voice_chat/
    ├── action_center/
    ├── form_filler/
    └── escalation_playbook/
```

### Each Feature Has This Structure

```
features/my_feature/
├── viewmodels/
│   └── my_feature_viewmodel.dart    ← Business logic
└── views/
    └── my_feature_screen.dart       ← UI only
```

---

## Common Development Tasks

### Adding a New Feature

**1. Create folder structure:**

```bash
mkdir -p lib/features/my_feature/viewmodels
mkdir -p lib/features/my_feature/views
```

**2. Create ViewModel:**

```bash
touch lib/features/my_feature/viewmodels/my_feature_viewmodel.dart
```

```dart
import 'package:flutter/foundation.dart';

class MyFeatureViewModel extends ChangeNotifier {
  // State variables
  String _myState = '';

  // Getters
  String get myState => _myState;

  // Methods
  void updateState(String newValue) {
    _myState = newValue;
    notifyListeners();  // Notify UI of changes
  }
}
```

**3. Create View:**

```bash
touch lib/features/my_feature/views/my_feature_screen.dart
```

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/my_feature_viewmodel.dart';

class MyFeatureScreen extends StatelessWidget {
  const MyFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: Consumer<MyFeatureViewModel>(
        builder: (context, viewModel, _) {
          return Center(
            child: Column(
              children: [
                Text(viewModel.myState),
                ElevatedButton(
                  onPressed: () => viewModel.updateState('Updated'),
                  child: const Text('Update'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

**4. Register in main.dart:**

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MyFeatureViewModel()),
  ],
  // ...
)
```

**5. Add route in main.dart:**

```dart
routes: {
  '/my-feature': (context) => const MyFeatureScreen(),
}
```

### Modifying UI Colors

**File:** `lib/core/theme/app_theme.dart`

```dart
// Change primary color
static const Color primaryColor = Color(0xFF2E7D32);  // Government Green
```

### Adding a New Service

**1. Create service file:**

```bash
touch lib/core/services/my_service.dart
```

**2. Implement service:**

```dart
class MyService {
  Future<String> doSomething() async {
    // Implementation
    return 'result';
  }
}
```

**3. Register in main.dart:**

```dart
Provider<MyService>(create: (_) => MyService()),
```

**4. Use in ViewModel:**

```dart
class MyViewModel extends ChangeNotifier {
  final MyService _myService;

  MyViewModel({required MyService myService}) : _myService = myService;
}
```

### Using Localization

**File:** `lib/core/services/localization_service.dart`

```dart
// In ViewModel or Widget:
String label = LocalizationService.translate(
  'key_name',
  userSelectedLanguage,
);

// Example:
String greeting = LocalizationService.translate(
  'hello',  // English key
  'hi',     // Hindi language code
);
```

**Supported Language Codes:**

- `en` - English
- `hi` - Hindi
- `te` - Telugu
- `ta` - Tamil
- `kn` - Kannada
- `mr` - Marathi

---

## Debugging

### Print Statements

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('Debug message: $variable');
}
```

### Use Dart DevTools

```bash
# Show performance, logs, network in browser
flutter pub global activate devtools
devtools
```

### Check Errors

```bash
# Run analyzer to find issues
flutter analyze

# Fix common issues
dart fix --apply
```

### Debug Console

Press `D` while running to show debug console with log messages.

---

## Building for Release

### iOS Release Build

```bash
flutter build ios
# Outputs: build/ios/ipa/
```

### Web (Preview)

```bash
flutter run -d chrome
```

---

## Troubleshooting

### "Android SDK not found"

```bash
# Expected - Android SDK not installed on this machine
# Not needed for iOS development
# To fix: Install Android Studio + Android SDK
```

### "CocoaPods error"

```bash
# Clean and rebuild
flutter clean
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter pub get
flutter run
```

### "Port 8080 already in use"

```bash
# Kill process using port
lsof -i :8080
kill -9 <PID>
```

### "iPhone simulator not responding"

```bash
# Restart simulator
xcrun simctl erase all
# Launch fresh simulator
flutter emulators --launch "iPhone 16e"
```

### "Hot reload not working"

```bash
# Try hot restart
# In running app, press 'R' (capital R)
# If that fails, stop and rerun:
flutter run
```

---

## Code Standards

### File Naming

- Classes: PascalCase (`UserModel`, `OnboardingScreen`)
- Files: snake_case (`user_model.dart`, `onboarding_screen.dart`)
- Constants: camelCase (`primaryColor`)
- Variables: camelCase (`myVariable`)

### Dart Formatting

```bash
# Format all files
dart format lib/

# Format one file
dart format lib/main.dart
```

### Linting

```bash
# Check linting issues
flutter analyze

# Fix automatically
dart fix --apply
```

### Comments

```dart
/// Documentation comment (appears in editor)
// Single line comment
/* Multi-line
   comment */
```

---

## Working with State (Provider)

### Basic Pattern

```dart
// ViewModel
class MyViewModel extends ChangeNotifier {
  int _counter = 0;
  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();  // Important!
  }
}

// In main.dart
ChangeNotifierProvider(create: (_) => MyViewModel()),

// In Widget
Consumer<MyViewModel>(
  builder: (context, viewModel, _) {
    return Text(viewModel.counter.toString());
  },
)
```

### Accessing ViewModel

```dart
// Listen to changes
final viewModel = context.watch<MyViewModel>();

// Don't listen (read once)
final viewModel = context.read<MyViewModel>();

// In ViewModel init
ChangeNotifierProvider(
  create: (context) => MyViewModel(
    service: context.read<MyService>(),
  ),
)
```

---

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run one test file
flutter test test/features/onboarding/onboarding_viewmodel_test.dart

# Watch mode (re-run on file changes)
flutter test --watch
```

### Add Test

**File:** `test/features/my_feature/my_feature_viewmodel_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:civic_ai_app/features/my_feature/viewmodels/my_feature_viewmodel.dart';

void main() {
  group('MyFeatureViewModel', () {
    test('should update state', () {
      final viewModel = MyFeatureViewModel();

      viewModel.updateState('New Value');

      expect(viewModel.myState, 'New Value');
    });
  });
}
```

---

## Git Workflow

### Before Starting Work

```bash
# Ensure code is latest
git pull origin main

# Create feature branch
git checkout -b feature/my-feature
```

### During Development

```bash
# Check status
git status

# Add changes
git add lib/features/my_feature/

# Commit
git commit -m "feat: add my feature"

# Push
git push origin feature/my-feature
```

### Common Git Commands

```bash
# See recent changes
git log --oneline -10

# Undo file changes
git checkout -- lib/my_file.dart

# Undo last commit (keep changes)
git reset --soft HEAD~1

# View diff
git diff lib/main.dart
```

---

## Resources

### Documentation

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Language](https://dart.dev)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design](https://material.io/design)

### Useful Links

- App Icons: [Flutter Launcher Icons](https://pub.dev/packages/flutter_launcher_icons)
- Networking: [Dio Package](https://pub.dev/packages/dio)
- Local Storage: [Hive Database](https://pub.dev/packages/hive)
- Testing: [Mockito](https://pub.dev/packages/mockito)

### Learning

- [Flutter Codelab](https://flutter.dev/codelabs)
- [Google Mobile Dev](https://developers.google.com/apps)
- [YouTube: Flutter](https://www.youtube.com/@FlutterDev)

---

## Tips & Tricks

### Quick Navigation

- Press 'w' while running → Inspect widget tree
- Press 'i' → Toggle iOS/Android
- Press 'h' → Show hot reload status

### Faster Development

```bash
# Run with verbose logging (see all details)
flutter run -v

# Skip code gen (for quick iteration)
flutter run --no-fast-start

# Use specific device immediately
flutter run -d "iPhone 16e" --verbose
```

### Check Flutter Setup

```bash
# Detailed environment check
flutter doctor -v

# Check available devices
flutter devices

# Check pub packages
flutter pub outdated
```

---

## Getting Help

1. **Check Flutter Docs**: https://flutter.dev/docs
2. **Search Stack Overflow**: Tag with `flutter` and `dart`
3. **Open Issue on GitHub**: With minimal reproduction case
4. **Ask in Flutter Community**: https://discord.gg/flutter
5. **Review PROJECT_SUMMARY.md**: In project root
6. **Review IMPLEMENTATION_GUIDE.md**: For feature details

---

**Happy Coding!** 🚀

For detailed feature information, see [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
For implementing features, see [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
