import 'package:speech_to_text/speech_to_text.dart';

/// On-device speech-to-text; we send the text (not audio) to Gemini.
class Speech {
  Speech._();
  static final instance = Speech._();

  final _stt = SpeechToText();
  bool? _available;

  Future<bool> ensureReady() async {
    if (_available != null) return _available!;
    try {
      _available = await _stt.initialize();
    } catch (_) {
      _available = false;
    }
    return _available!;
  }

  bool get isListening => _stt.isListening;

  Future<bool> start(void Function(String words, bool isFinal) onResult) async {
    if (!await ensureReady()) return false;
    await _stt.listen(
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      listenOptions: SpeechListenOptions(partialResults: true, listenMode: ListenMode.dictation, cancelOnError: true),
    );
    return true;
  }

  Future<void> stop() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }
}
