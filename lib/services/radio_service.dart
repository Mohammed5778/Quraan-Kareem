import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../models/radio_station.dart';

class RadioService {
  final AudioPlayer _player = AudioPlayer();
  RadioStation? _currentStation;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;
  RadioStation? get currentStation => _currentStation;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  RadioService() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
    });
  }

  // Get available radio stations
  Future<List<RadioStation>> getStations() async {
    // Return predefined Islamic radio stations
    return [
      RadioStation(
        id: '1',
        name: 'إذاعة القرآن الكريم - السعودية',
        englishName: 'Quran Radio - Saudi Arabia',
        url: 'https://stream.radiojar.com/0tpy1h0kxtzuv',
        country: 'Saudi Arabia',
        language: 'Arabic',
        isQuranRadio: true,
      ),
      RadioStation(
        id: '2',
        name: 'إذاعة القرآن الكريم - مصر',
        englishName: 'Quran Radio - Egypt',
        url: 'https://stream.radiojar.com/4wqre23fytzuv',
        country: 'Egypt',
        language: 'Arabic',
        isQuranRadio: true,
      ),
      RadioStation(
        id: '3',
        name: 'إذاعة نور دبي',
        englishName: 'Noor Dubai Radio',
        url: 'https://noorlive.dfrstream.com/noorlive.mp3',
        country: 'UAE',
        language: 'Arabic',
        isQuranRadio: true,
      ),
      RadioStation(
        id: '4',
        name: 'إذاعة الشيخ مشاري العفاسي',
        englishName: 'Sheikh Mishary Alafasy Radio',
        url: 'https://qurango.net/radio/mishary_alafasi',
        country: 'Kuwait',
        language: 'Arabic',
        isQuranRadio: true,
      ),
      RadioStation(
        id: '5',
        name: 'إذاعة الشيخ عبد الباسط',
        englishName: 'Sheikh Abdul Basit Radio',
        url: 'https://qurango.net/radio/abdulbasit_mujawwad',
        country: 'Egypt',
        language: 'Arabic',
        isQuranRadio: true,
      ),
      RadioStation(
        id: '6',
        name: 'إذاعة المنشاوي',
        englishName: 'Al-Minshawi Radio',
        url: 'https://qurango.net/radio/mohammed_alminshawi',
        country: 'Egypt',
        language: 'Arabic',
        isQuranRadio: true,
      ),
      RadioStation(
        id: '7',
        name: 'إذاعة الحصري',
        englishName: 'Al-Husary Radio',
        url: 'https://qurango.net/radio/mahmoud_alhasry',
        country: 'Egypt',
        language: 'Arabic',
        isQuranRadio: true,
      ),
      RadioStation(
        id: '8',
        name: 'إذاعة السديس والشريم',
        englishName: 'As-Sudais & Shuraim Radio',
        url: 'https://qurango.net/radio/sudais_and_shuraim',
        country: 'Saudi Arabia',
        language: 'Arabic',
        isQuranRadio: true,
      ),
    ];
  }

  // Play station
  Future<void> playStation(RadioStation station) async {
    try {
      _currentStation = station;
      await _player.setUrl(station.url);
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      throw Exception('Error playing radio: $e');
    }
  }

  // Pause
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  // Resume
  Future<void> resume() async {
    await _player.play();
    _isPlaying = true;
  }

  // Stop
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentStation = null;
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