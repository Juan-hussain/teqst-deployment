# TEQST Opus Implementation Testing Guide

This guide provides comprehensive testing methods for the Opus audio codec implementation.

## 🔧 **Prerequisites**

1. **Backend Server Running**
   ```bash
   cd TEQST_Backend/TEQST
   source ../venv/bin/activate
   python manage.py runserver 0.0.0.0:8000
   ```

2. **Frontend Server Running**
   ```bash
   cd TEQST_Frontend
   npm start
   ```

## 🧪 **Testing Methods**

### **1. Backend API Testing**

#### **A. Test Opus System Info (No Auth Required)**
```bash
curl -X GET http://localhost:8000/api/opus/info/ \
  -H "Content-Type: application/json"
```

#### **B. Test with Authentication**
First, get authentication token:
```bash
# Login to get token
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "your_username", "password": "your_password"}'
```

Then test authenticated endpoints:
```bash
# Test Opus info with auth
curl -X GET http://localhost:8000/api/opus/info/ \
  -H "Authorization: Token YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"

# Test audio conversion
curl -X POST http://localhost:8000/api/opus/convert/ \
  -H "Authorization: Token YOUR_TOKEN_HERE" \
  -F "audio_file=@test_audio.wav" \
  -F "quality=medium"
```

### **2. Frontend Testing**

#### **A. Browser Testing**
1. Open `http://localhost:4200` in your browser
2. Navigate to the recording section
3. Look for the new Opus format selector component
4. Test recording with different quality presets

#### **B. Console Testing**
Open browser developer tools and test in console:

```javascript
// Test Opus service availability
import { OpusAudioService } from './src/app/speak/record-view/opus-audio.service';

// Check if Opus is supported
const opusService = new OpusAudioService();
console.log('Opus supported:', opusService.isOpusCodecSupported());

// Get available formats
console.log('Available formats:', opusService.getAvailableFormats());

// Set format
opusService.setAudioFormat({
  type: 'opus',
  quality: 'medium',
  bitrate: 32000,
  sampleRate: 24000,
  channels: 1,
  mimeType: 'audio/opus',
  extension: 'opus'
});
```

### **3. Manual Testing Scenarios**

#### **Scenario 1: Basic Recording Test**
1. **Setup**: Start both frontend and backend servers
2. **Login**: Authenticate with valid credentials
3. **Navigate**: Go to recording section
4. **Select Format**: Choose Opus medium quality
5. **Record**: Record a short audio sample
6. **Verify**: Check that file is saved as .opus format
7. **Playback**: Test audio playback functionality

#### **Scenario 2: Format Conversion Test**
1. **Upload**: Upload an existing WAV file
2. **Convert**: Use the conversion API to convert to Opus
3. **Compare**: Check file sizes (Opus should be ~3-4x smaller)
4. **Quality**: Verify audio quality is maintained

#### **Scenario 3: Browser Compatibility Test**
1. **Chrome**: Test Opus recording (should work)
2. **Firefox**: Test Opus recording (should work)
3. **Safari**: Test Opus recording (should work)
4. **Edge**: Test Opus recording (should work)
5. **IE11**: Test fallback to WAV (should work)

#### **Scenario 4: Quality Preset Test**
1. **Low Quality**: Record with 16kbps preset
2. **Medium Quality**: Record with 32kbps preset
3. **High Quality**: Record with 64kbps preset
4. **Compare**: Check file sizes and audio quality

### **4. Automated Testing**

#### **A. Backend Unit Tests**
```bash
cd TEQST_Backend/TEQST
source ../venv/bin/activate

# Run Opus-specific tests
python manage.py test recordingmgmt.tests.test_opus_utils
python manage.py test recordingmgmt.tests.test_opus_views

# Run all recording tests
python manage.py test recordingmgmt
```

#### **B. Frontend Unit Tests**
```bash
cd TEQST_Frontend

# Run Opus service tests
npm test -- --include="**/opus-audio.service.spec.ts"

# Run format selector tests
npm test -- --include="**/opus-format-selector.component.spec.ts"

# Run all tests
npm test
```

### **5. Performance Testing**

#### **A. File Size Comparison**
```bash
# Create test recordings
# Record 1 minute of audio in each format
# Compare file sizes:
# - WAV: ~1.4 MB
# - Opus Low: ~2 KB
# - Opus Medium: ~4 KB
# - Opus High: ~8 KB
```

#### **B. Recording Performance**
- **Latency**: Measure recording start time
- **CPU Usage**: Monitor during recording
- **Memory Usage**: Check for memory leaks
- **Battery Impact**: Test on mobile devices

### **6. Integration Testing**

#### **A. End-to-End Recording Flow**
1. **User Login** → **Select Text** → **Choose Format** → **Record** → **Upload** → **Playback**

#### **B. Cross-Platform Testing**
- **Desktop**: Chrome, Firefox, Safari, Edge
- **Mobile**: iOS Safari, Android Chrome
- **Tablet**: iPad Safari, Android Chrome

### **7. Error Handling Testing**

#### **A. Network Issues**
- Test with slow connection
- Test with intermittent connection
- Test with no connection

#### **B. Browser Limitations**
- Test with Opus disabled
- Test with microphone blocked
- Test with insufficient permissions

#### **C. File Size Limits**
- Test with very large files
- Test with corrupted files
- Test with unsupported formats

## 🐛 **Troubleshooting Common Issues**

### **Issue 1: Opus Not Available**
```
Error: Opus recorder not available, falling back to WAV
```
**Solution**: Check browser compatibility and ensure opus-recorder package is installed

### **Issue 2: Recording Fails**
```
Error: Failed to start recording
```
**Solution**: Check microphone permissions and HTTPS requirement

### **Issue 3: Upload Fails**
```
Error: Upload failed
```
**Solution**: Check authentication and file format compatibility

### **Issue 4: Playback Issues**
```
Error: Cannot play audio
```
**Solution**: Check browser audio codec support and file format

## 📊 **Expected Results**

### **File Size Reduction**
- **WAV to Opus**: 75-90% size reduction
- **Quality**: Maintained speech clarity
- **Compatibility**: Works on all modern browsers

### **Performance Metrics**
- **Recording Latency**: <100ms
- **CPU Usage**: <10% during recording
- **Memory Usage**: <50MB additional

### **Browser Support**
- **Chrome 33+**: Full Opus support
- **Firefox 15+**: Full Opus support
- **Safari 11+**: Full Opus support
- **Edge 12+**: Full Opus support
- **IE11**: WAV fallback

## 🎯 **Success Criteria**

✅ **Opus recording works** in supported browsers
✅ **WAV fallback works** in unsupported browsers
✅ **File sizes are reduced** by 75-90%
✅ **Audio quality is maintained** for speech
✅ **All existing functionality** continues to work
✅ **No performance degradation** in recording
✅ **Cross-browser compatibility** maintained

## 📝 **Test Report Template**

```
Test Date: ___________
Tester: ___________
Browser: ___________
OS: ___________

Test Results:
□ Opus recording works
□ WAV fallback works
□ File size reduction achieved
□ Audio quality maintained
□ Playback works correctly
□ Upload works correctly
□ No errors in console
□ Performance acceptable

Issues Found:
1. ___________
2. ___________
3. ___________

Overall Result: PASS / FAIL
```

---

**Happy Testing! 🎉**

