# Opus Audio Codec Implementation for TEQST

This document describes the implementation of Opus audio codec support in the TEQST platform, providing high-quality, efficient audio recording and processing capabilities.

## Overview

Opus is a modern, royalty-free audio codec designed for speech and music. It provides excellent compression while maintaining high audio quality, making it ideal for speech recording applications like TEQST.

### Key Benefits

- **High Compression**: Opus files are typically 3-4x smaller than WAV files
- **Excellent Quality**: Maintains speech clarity even at low bitrates
- **Low Latency**: Optimized for real-time applications
- **Wide Compatibility**: Supported by all modern browsers and audio players
- **Royalty-Free**: No licensing costs for commercial use

## Features Implemented

### Frontend (Angular/Ionic)

1. **OpusAudioService**: Core service for Opus recording operations
2. **OpusFormatSelectorComponent**: User interface for format selection
3. **Quality Presets**: Low, Medium, and High quality options
4. **Format Detection**: Automatic detection of supported formats
5. **Fallback Support**: Graceful fallback to WAV when Opus unavailable

### Backend (Django)

1. **OpusAudioProcessor**: Core processing engine
2. **Format Conversion**: Convert between WAV and Opus formats
3. **Quality Analysis**: Audio quality assessment and recommendations
4. **Batch Processing**: Convert multiple files simultaneously
5. **Metadata Extraction**: Extract audio file information

### API Endpoints

- `POST /api/opus/convert/` - Convert audio to Opus format
- `POST /api/opus/analyze/` - Analyze audio quality
- `GET /api/opus/info/` - Get system capabilities
- `POST /api/opus/batch-convert/` - Batch conversion

## Installation

### Frontend Dependencies

```bash
cd TEQST_Frontend
npm install opus-recorder@^0.9.0
```

### Backend Dependencies

```bash
cd TEQST_Backend
pip install opuslib==3.0.1 pydub==0.25.1
```

### System Dependencies (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install libopus0 libopus-dev ffmpeg
```

## Configuration

### Frontend Configuration

The Opus service automatically detects browser support and configures itself:

```typescript
// Default configuration
const defaultConfig = {
  quality: 'medium',
  bitrate: 32000,
  sampleRate: 24000,
  channels: 1
};
```

### Backend Configuration

Quality presets are configurable in `opus_utils.py`:

```python
OPUS_PRESETS = {
    'low': {
        'bitrate': 16000,
        'sample_rate': 16000,
        'channels': 1,
        'complexity': 3
    },
    'medium': {
        'bitrate': 32000,
        'sample_rate': 24000,
        'channels': 1,
        'complexity': 6
    },
    'high': {
        'bitrate': 64000,
        'sample_rate': 48000,
        'channels': 1,
        'complexity': 8
    }
}
```

## Usage

### Frontend Usage

#### Basic Recording with Opus

```typescript
import { OpusAudioService } from './opus-audio.service';

constructor(private opusService: OpusAudioService) {}

async startRecording() {
  try {
    // Set quality preset
    this.opusService.setAudioFormat({
      type: 'opus',
      quality: 'medium',
      bitrate: 32000,
      sampleRate: 24000
    });
    
    // Start recording
    await this.opusService.startRecording(mediaStream);
    
    // Stop recording and get blob
    const result = await this.opusService.stopRecording();
    console.log('Recording completed:', result.blob);
    console.log('Format:', result.format);
  } catch (error) {
    console.error('Recording failed:', error);
  }
}
```

#### Format Selection Component

```html
<app-opus-format-selector
  [showFormatSelector]="true"
  (formatChanged)="onFormatChanged($event)">
</app-opus-format-selector>
```

### Backend Usage

#### Audio Conversion

```python
from recordingmgmt.opus_utils import create_opus_processor

# Convert WAV to Opus
processor = create_opus_processor('medium')
success = processor.convert_to_opus('input.wav', 'output.opus', 'medium')

if success:
    print("Conversion successful")
else:
    print("Conversion failed")
```

#### Quality Analysis

```python
# Analyze audio quality
metrics = processor.get_audio_quality_metrics('audio.opus')
print(f"Quality score: {metrics['quality_score']}")
print(f"Recommendations: {metrics['recommendations']}")
```

## Quality Presets

### Low Quality (16 kbps)
- **Use Case**: Basic speech recording, limited bandwidth
- **Bitrate**: 16 kbps
- **Sample Rate**: 16 kHz
- **File Size**: ~2 KB per minute
- **Quality**: Good for speech, acceptable for basic needs

### Medium Quality (32 kbps) - **Recommended**
- **Use Case**: Standard speech recording, balanced quality/size
- **Bitrate**: 32 kbps
- **Sample Rate**: 24 kHz
- **File Size**: ~4 KB per minute
- **Quality**: Excellent for speech, good for music

### High Quality (64 kbps)
- **Use Case**: High-quality recording, music content
- **Bitrate**: 64 kbps
- **Sample Rate**: 48 kHz
- **File Size**: ~8 KB per minute
- **Quality**: Near-transparent, suitable for professional use

## File Size Comparison

| Format | Quality | 1 Minute | 10 Minutes | 1 Hour |
|--------|---------|-----------|------------|---------|
| WAV    | 16-bit  | ~1.4 MB  | ~14 MB     | ~84 MB  |
| Opus   | Low     | ~2 KB     | ~20 KB     | ~120 KB |
| Opus   | Medium  | ~4 KB     | ~40 KB     | ~240 KB |
| Opus   | High    | ~8 KB     | ~80 KB     | ~480 KB |

## Browser Compatibility

### Full Opus Support
- Chrome 33+
- Firefox 15+
- Safari 11+
- Edge 12+

### Partial Support (WAV fallback)
- Internet Explorer 11
- Older mobile browsers

## Migration from WAV

### Automatic Migration
The system automatically detects existing WAV files and can convert them to Opus:

```python
# Batch convert existing recordings
from recordingmgmt.opus_views import opus_batch_convert

# This will convert all WAV files in a folder to Opus
response = opus_batch_convert(request)
```

### Manual Migration
Individual files can be converted using the API:

```bash
curl -X POST http://your-server/api/opus/convert/ \
  -F "audio_file=@recording.wav" \
  -F "quality=medium"
```

## Performance Considerations

### Recording Performance
- **Latency**: Opus encoding adds ~20ms latency
- **CPU Usage**: Medium complexity preset uses ~5-10% CPU
- **Memory**: Minimal memory overhead during recording

### Playback Performance
- **Decoding**: Hardware-accelerated on modern devices
- **Streaming**: Excellent for real-time streaming applications
- **Storage**: Significant storage savings over WAV

## Troubleshooting

### Common Issues

#### Opus Not Available
```
Error: Opus recorder not available, falling back to WAV
```
**Solution**: Check browser compatibility and ensure opus-recorder package is installed.

#### Conversion Failures
```
Error: Failed to convert audio
```
**Solution**: Verify ffmpeg is installed and audio file is valid.

#### Quality Issues
```
Error: Audio quality below threshold
```
**Solution**: Increase quality preset or check input audio quality.

### Debug Mode

Enable debug logging in the backend:

```python
import logging
logging.getLogger('recordingmgmt.opus_utils').setLevel(logging.DEBUG)
```

## Testing

### Frontend Tests

```bash
cd TEQST_Frontend
npm test -- --include="**/opus-audio.service.spec.ts"
npm test -- --include="**/opus-format-selector.component.spec.ts"
```

### Backend Tests

```bash
cd TEQST_Backend
python manage.py test recordingmgmt.tests.test_opus_utils
python manage.py test recordingmgmt.tests.test_opus_views
```

## Future Enhancements

### Planned Features
1. **Adaptive Bitrate**: Automatic quality adjustment based on content
2. **Streaming Support**: Real-time Opus streaming
3. **Advanced Codecs**: Support for additional audio formats
4. **Cloud Processing**: Server-side audio enhancement

### Performance Optimizations
1. **WebAssembly**: Native Opus encoding in browser
2. **Worker Threads**: Background audio processing
3. **Caching**: Intelligent audio format caching

## Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request

### Code Standards
- Follow existing code style
- Add comprehensive tests
- Update documentation
- Include performance benchmarks

## Support

### Documentation
- [Opus Codec Specification](https://tools.ietf.org/html/rfc6716)
- [opus-recorder Documentation](https://github.com/kbumsik/opus-recorder)
- [Django REST Framework](https://www.django-rest-framework.org/)

### Community
- GitHub Issues: Report bugs and request features
- Discussions: Share ideas and solutions
- Wiki: Community-maintained documentation

## License

This implementation is part of the TEQST platform and follows the same licensing terms. Opus codec itself is royalty-free and open source.

---

*Last updated: December 2024*
*TEQST Platform - Opus Implementation v1.0*

