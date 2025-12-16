# Implementation Reference - Audio Features (TTS & STT)

## Implemented MVP Version

## Architecture Overview

1. **Real-time STT**: User taps Mic → `speech_to_text` captures audio → Real-time transcription → Auto-populates text field.
2. **On-demand TTS**: Bot response → User taps Play → `Dio` calls ElevenLabs API → Save to Temp → `audioplayers` plays audio.
3. **Service Layer**:
   - `SttService`: Wraps `speech_to_text` with permission handling.
   - `TtsService`: Uses `Dio` for direct API calls to stability and control, caching files locally.
4. **State Management**: `flutter_riverpod` providers for service access.

---

## ⚠️ Key Implementation Decisions

### Dependency Changes

We opted for a direct API integration for ElevenLabs instead of using the `elevenlabs_flutter` or `elevenlabs_flutter_updated` packages. This provides:

- **Stability**: avoiding abandoned or wrapper packages.
- **Control**: Direct access to API headers and response bytes (using `Dio`).
- **Simplicity**: No need for extra package dependencies just for a simple POST request.

### Updated Dependencies

```yaml
dependencies:
  # Networking (for TTS API)
  dio: ^5.9.0

  # Audio Playback
  audioplayers: ^6.5.1

  # STT
  speech_to_text: ^7.3.0
  permission_handler: ^11.0.0

  # Configuration
  flutter_dotenv: ^5.2.1

  # Utils
  path_provider: ^2.1.4
# Removed:
# record: ^5.1.2 (Replaced by speech_to_text)
# elevenlabs_flutter / elevenlabs_flutter_updated (Replaced by Dio)
```

---

## 📋 Implemented Structure

### 1. Configuration & Permissions

- **`.env`**: Stores `ELEVENLABS_API_KEY`.
- **`AndroidManifest.xml`**: Added `RECORD_AUDIO`.
- **`Info.plist`**: Added `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription`.

### 2. Service Implementation

#### `TtsService` (Custom Implementation)

- **Engine**: `Dio` (HTTP Client) + `audioplayers`.
- **Logic**:
  1. Checks local memory cache.
  2. If missing, sends POST to `https://api.elevenlabs.io/v1/text-to-speech/{VOICE_ID}`.
  3. Writes response bytes to a temporary file.
  4. Plays file using `DeviceFileSource`.
  5. Caches file path.
- **Voice**: Defaults to "Rachel" (`21m00Tcm4TlvDq8ikWAM`).

#### `SttService`

- **Engine**: `speech_to_text`.
- **Logic**:
  1. Initializes on first use.
  2. Requests permissions.
  3. Starts listening with `listenMode: ListenMode.confirmation`.
  4. Updates text field in real-time.

### 3. UI Integration (`ChatbotScreen`)

- **Mic Button**: Toggles listening state. Icons change (Mic vs Stop).
- **Play Button**: Added to bot message bubbles. Toggles playback (Speaker vs Stop).
- **Feedback**: SnackBar messages for errors (Permissions, API failure).

---

## 📝 Verification Checklist

### Setup

1. [x] Add `ELEVENLABS_API_KEY` to `.env`.
2. [x] Run `flutter pub get`.

### STT Tests (Physical Device Required)

1. [ ] **Voice Input**: Tap Mic → Speak → Text appears in field.
2. [ ] **Stop Listening**: Tap Mic again → Listening stops, text remains.
3. [ ] **Permissions**: First run asks for Microphone permissions.

### TTS Tests

1. [ ] **Playback**: Tap Play on bot message → Audio plays.
2. [ ] **Stop**: Tap Stop (while playing) → Audio stops immediately.
3. [ ] **Caching**: Tap Play again → Audio plays instantly (no API call).

### Error Handling

1. [ ] **No Internet**: TTS shows error SnackBar.
2. [ ] **Invalid Key**: TTS shows error SnackBar.
3. [ ] **Mic Denied**: STT shows permission denied SnackBar.

---

## 💰 Cost & Limits

- **ElevenLabs**: Uses standard character-based pricing.
- **Cache**: Implemented LRU-style cache (max 20 items) to minimize API calls.
- **STT**: Uses device on-device speech recognition where available (iOS/Android), generally free but subject to OS constraints (e.g., 1-minute limit on iOS).

---

## Future Improvements

1. **Visual Feedback**: Add a waveform visualization while listening.
2. **Settings**: Allow users to change the TTS Voice.
3. **Auto-Send**: Option to automatically send the message after a pause in speech.
