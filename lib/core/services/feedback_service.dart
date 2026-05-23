import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Provides haptic + synthesised audio feedback for interactive elements.
/// Sounds are generated programmatically as PCM WAV — no asset files required.
class FeedbackService {
  FeedbackService._() {
    // Sharp click: 800 Hz, 55 ms, fast decay
    _tapBytes = _tone(frequency: 800, durationMs: 55, decay: 45);
    // Soft ding: 660 Hz, 90 ms, gentle decay
    _dingBytes = _tone(frequency: 660, durationMs: 90, decay: 22);
  }

  static final FeedbackService instance = FeedbackService._();

  final AudioPlayer _player = AudioPlayer();
  late final Uint8List _tapBytes;
  late final Uint8List _dingBytes;

  bool soundEnabled = true;

  /// Light tap — regular buttons, nav items, links.
  void tap() {
    HapticFeedback.lightImpact();
    if (soundEnabled) _play(_tapBytes);
  }

  /// Medium impact + pleasant ding — successful form submissions.
  void success() {
    HapticFeedback.mediumImpact();
    if (soundEnabled) _play(_dingBytes);
  }

  void _play(Uint8List bytes) {
    _player.play(BytesSource(bytes));
  }

  // ── WAV generation ────────────────────────────────────────────────────────

  Uint8List _tone({
    required double frequency,
    required int durationMs,
    double amplitude = 0.45,
    double decay = 30.0,
    int sampleRate = 44100,
  }) {
    final n = (sampleRate * durationMs / 1000).round();
    final samples = Int16List(n);
    for (var i = 0; i < n; i++) {
      final t = i / sampleRate;
      final v = amplitude * exp(-t * decay) * sin(2 * pi * frequency * t);
      samples[i] = (v * 32767).round().clamp(-32768, 32767);
    }
    return _wav(samples, sampleRate);
  }

  Uint8List _wav(Int16List samples, int sampleRate) {
    const channels = 1;
    const bits = 16;
    final byteRate = sampleRate * channels * bits ~/ 8;
    final block = channels * bits ~/ 8;
    final dataSize = samples.length * block;
    final buf = ByteData(44 + dataSize);
    var o = 0;

    void s(String v) {
      for (final c in v.codeUnits) {
        buf.setUint8(o++, c);
      }
    }

    void u16(int v) {
      buf.setUint16(o, v, Endian.little);
      o += 2;
    }

    void u32(int v) {
      buf.setUint32(o, v, Endian.little);
      o += 4;
    }

    s('RIFF'); u32(36 + dataSize); s('WAVE');
    s('fmt '); u32(16); u16(1); u16(channels);
    u32(sampleRate); u32(byteRate); u16(block); u16(bits);
    s('data'); u32(dataSize);
    for (final v in samples) {
      buf.setInt16(o, v, Endian.little);
      o += 2;
    }

    return buf.buffer.asUint8List();
  }
}
