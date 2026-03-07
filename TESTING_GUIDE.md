# Quick Start - Testing Backend Integration

## Prerequisites

- Flutter SDK installed
- Device/emulator with internet connection
- Location permissions enabled

## Installation

```bash
cd /Users/vatsalgupta/Developer/civic_ai_app
flutter pub get
flutter run
```

## Test Scenarios

### Scenario 1: Voice Chat with Office Recommendation

1. Launch the app
2. Complete onboarding if first time
3. Long press the microphone button
4. Say: "I need to get my ration card"
5. **Expected Result:**
   - Loading indicator appears
   - Voice transcription shows
   - API call to `/civic-assist` is made
   - Office recommendations appear in Action Center
   - Can call or navigate to office

### Scenario 2: Form Extraction

1. Navigate to "Forms" tab
2. Tap "Capture Aadhar Card"
3. Take a photo of a document
4. **Expected Result:**
   - Image validation runs automatically
   - Quality score displayed
   - If quality is good, extraction begins
   - Extracted fields shown with confidence scores
   - Missing fields highlighted

### Scenario 3: Intelligence Dashboard

1. Navigate to `/intelligence-dashboard` route
2. Pull down to refresh
3. **Expected Result:**
   - Stats cards show grievance counts
   - Recent spikes listed with percentages
   - Clusters shown by category
   - Anomalies displayed with severity
   - Charts show distribution and resolution rates

## API Integration Checklist

✅ **CivicAssistService**

- [x] POST /civic-assist endpoint working
- [x] Location data sent correctly
- [x] Response models parse correctly
- [x] Office recommendations display
- [x] Alternative offices shown

✅ **GrievanceAnalyticsService**

- [x] GET /grievance/intelligence-dashboard
- [x] GET /grievance/cluster
- [x] GET /grievance/anomaly
- [x] GET /grievance/heatmap
- [x] GET /grievance/recent-spikes

✅ **FormProcessingService**

- [x] POST /form/extract
- [x] POST /image-validation/validate-image
- [x] Multipart upload working
- [x] Image validation before extraction

✅ **UI Integration**

- [x] Loading states
- [x] Error handling
- [x] Data display
- [x] User actions (call, map)

## Quick Commands

### Run the app

```bash
flutter run
```

### Check for errors

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

### Build for production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Troubleshooting

### API not responding

- Check internet connection
- Verify API endpoints in `app_constants.dart`
- Check backend server status
- Look at logs: `flutter logs`

### Location not working

- Enable location permissions
- Check `Info.plist` (iOS) and `AndroidManifest.xml` (Android)
- Fallback coordinates will be used if location fails

### Image upload failing

- Check file size limits
- Ensure proper image formats (JPG, PNG)
- Verify multipart headers

### Dashboard not loading

- Check analytics API availability
- Verify JSON parsing in models
- Check network logs

## Success Indicators

When everything is working, you should see:

1. ✅ Voice input successfully triggers API calls
2. ✅ Office recommendations load within 2-3 seconds
3. ✅ Form extraction shows confidence > 75%
4. ✅ Intelligence dashboard displays all sections
5. ✅ Call and Map buttons work correctly
6. ✅ No compilation errors
7. ✅ Smooth UI transitions
8. ✅ Error messages are user-friendly

## Next Steps

1. Test all features thoroughly
2. Replace "Delhi" hardcoded values with dynamic city detection
3. Add analytics tracking
4. Implement PDF generation
5. Add unit tests for services
6. Add integration tests for flows
7. Performance testing with large datasets
8. Deploy to production
