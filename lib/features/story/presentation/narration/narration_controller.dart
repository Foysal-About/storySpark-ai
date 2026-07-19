import 'package:flutter/widgets.dart';

import 'narration_engine.dart';

/// UI states of the read-aloud feature.
enum NarrationStatus {
  /// Story text displayed, "Read" button available.
  idle,

  /// Button pressed; audio is being prepared (cloud fetch / engine spin-up).
  loading,

  /// Audio is playing and the active section is highlighted.
  playing,
}

/// State machine driving the read-aloud button and text highlighting.
///
/// If the primary engine fails mid-story (e.g. cloud TTS quota exhausted)
/// and a [fallbackEngine] is provided, narration continues on the fallback
/// from the last spoken position instead of stopping dead.
class NarrationController extends ChangeNotifier {
  NarrationController(this._engine, {NarrationEngine? fallbackEngine})
      : _fallback = fallbackEngine;

  final NarrationEngine _engine;
  final NarrationEngine? _fallback;
  bool _disposed = false;
  bool _userStopped = false;

  NarrationStatus _status = NarrationStatus.idle;
  NarrationStatus get status => _status;

  /// Range of the story content currently being narrated, or null.
  TextRange? _highlight;
  TextRange? get highlight => _highlight;

  String? _notice;

  /// One-shot user-facing message (error or fallback notice); returns it and
  /// clears it so it is shown only once.
  String? takeNotice() {
    final n = _notice;
    _notice = null;
    return n;
  }

  Future<void> toggle({
    required String title,
    required String content,
    String? mood,
  }) {
    return _status == NarrationStatus.idle
        ? _start(title: title, content: content, mood: mood)
        : stop();
  }

  Future<void> _start({
    required String title,
    required String content,
    String? mood,
  }) async {
    _userStopped = false;
    _setStatus(NarrationStatus.loading);
    final style = NarrationStyle.fromMood(mood);

    try {
      await _engine.start(
        title: title,
        content: content,
        style: style,
        onHighlight: _onHighlight,
      );
    } catch (e) {
      debugPrint('Narration failed: $e');
      if (!_userStopped && _fallback != null) {
        _notice = 'Story voice is busy — continuing with the device voice. ($e)';
        await _resumeOnFallback(content: content, style: style);
      } else if (!_userStopped) {
        _notice = "Couldn't play the story audio. ($e)";
      }
    } finally {
      _highlight = null;
      _setStatus(NarrationStatus.idle);
    }
  }

  Future<void> _resumeOnFallback({
    required String content,
    required NarrationStyle style,
  }) async {
    // The last highlighted chunk finished playing before the failure surfaced,
    // so pick up right after it (or from the top if nothing played yet).
    final resumeFrom = _highlight?.end ?? 0;
    final remaining = content.substring(resumeFrom.clamp(0, content.length));
    if (remaining.trim().isEmpty) return;

    _notify();

    try {
      await _fallback!.start(
        title: '',
        content: remaining,
        style: style,
        onHighlight: (range) => _onHighlight(
          range == null
              ? null
              : TextRange(
                  start: range.start + resumeFrom,
                  end: range.end + resumeFrom,
                ),
        ),
      );
    } catch (e) {
      debugPrint('Fallback narration failed: $e');
      if (!_userStopped) {
        _notice = "Couldn't play the story audio. Please try again.";
      }
    }
  }

  Future<void> stop() async {
    _userStopped = true;
    await Future.wait([
      _engine.stop(),
      if (_fallback != null) _fallback.stop(),
    ]);
    _highlight = null;
    _setStatus(NarrationStatus.idle);
  }

  void _onHighlight(TextRange? range) {
    // First audible progress flips loading -> playing.
    if (_status == NarrationStatus.loading) _status = NarrationStatus.playing;
    _highlight = range;
    _notify();
  }

  void _setStatus(NarrationStatus status) {
    _status = status;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _engine.dispose();
    _fallback?.dispose();
    super.dispose();
  }
}