import 'dart:async';
import 'package:just_audio/just_audio.dart';

import '../models/reciter.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  
  bool _isPlaying = false;
  bool _isPaused = false;
  int? _currentSurah;
  int? _currentVerse;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int? get currentSurah => _currentSurah;
  int? get currentVerse => _currentVerse;
  Duration? get duration => _player.duration;
  Duration? get position => _player.position;
  
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  AudioService() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _isPaused = false;
      }
    });
  }

  // Play entire surah
  Future<void> playSurah(int surahNumber, Reciter reciter) async {
    try {
      _currentSurah = surahNumber;
      _currentVerse = null;
      
      final paddedSurah = surahNumber.toString().padLeft(3, '0');
      final url = 'https://cdn.islamic.network/quran/audio-surah/128/${reciter.id}/$paddedSurah.mp3';
      
      await _player.setUrl(url);
      await _player.play();
      _isPlaying = true;
      _isPaused = false;
    } catch (e) {
      _isPlaying = false;
      throw Exception('Error playing surah: $e');
    }
  }

  // Play specific verse
  Future<void> playVerse(int verseNumber, Reciter reciter) async {
    try {
      _currentVerse = verseNumber;
      
      final url = '${reciter.audioBaseUrl}$verseNumber.mp3';
      
      await _player.setUrl(url);
      await _player.play();
      _isPlaying = true;
      _isPaused = false;
    } catch (e) {
      _isPlaying = false;
      throw Exception('Error playing verse: $e');
    }
  }

  // Pause playback
  Future<void> pause() async {
    await _player.pause();
    _isPaused = true;
    _isPlaying = false;
  }

  // Resume playback
  Future<void> resume() async {
    await _player.play();
    _isPaused = false;
    _isPlaying = true;
  }

  // Stop playback
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _isPaused = false;
    _currentSurah = null;
    _currentVerse = null;
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Set playback speed
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  // Dispose
  void dispose() {
    _player.dispose();
  }
}