// main.dart - تطبيق القرآن الكريم الشامل (نسخة احترافية محسّنة)
// Quran App Pro v2.0.0 - Enhanced Design + Offline Download
// المطور: محمد إبراهيم عبدالله

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ==================== CONSTANTS ====================
class AppConstants {
  static const String alquranApiBase = 'https://api.alquran.cloud/v1';
  static const String mp3quranApiBase = 'https://mp3quran.net/api/v3';
  static const String adhkarApiUrl = 'https://raw.githubusercontent.com/rn0x/Adhkar-json/main/adhkar.json';
  static const String aladhanApiBase = 'https://api.aladhan.com/v1';
  
  // Enhanced Color Palette
  static const Color primaryColor = Color(0xFF00BFA6);
  static const Color primaryDark = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF64FFDA);
  static const Color secondaryColor = Color(0xFF448AFF);
  static const Color accentColor = Color(0xFFE040FB);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardDarker = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF020617);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00BFA6), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient rainbowGradient = LinearGradient(
    colors: [
      Color(0xFF22c55e),
      Color(0xFF06b6d4),
      Color(0xFF3b82f6),
      Color(0xFF8b5cf6),
    ],
  );
}

// ==================== MAIN APP ====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(QuranApp(prefs: prefs));
}

class QuranApp extends StatefulWidget {
  final SharedPreferences prefs;
  const QuranApp({super.key, required this.prefs});

  @override
  State<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends State<QuranApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  String _currentTheme = 'dark';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    final theme = widget.prefs.getString('theme_mode') ?? 'dark';
    setState(() {
      _currentTheme = theme;
      _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void updateTheme(String mode) {
    setState(() {
      _currentTheme = mode;
      _themeMode = mode == 'light' ? ThemeMode.light : ThemeMode.dark;
    });
    widget.prefs.setString('theme_mode', mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'القرآن الكريم',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: MainScreen(
        prefs: widget.prefs,
        onThemeChanged: updateTheme,
        currentTheme: _currentTheme,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        tertiary: AppConstants.accentColor,
        surface: AppConstants.cardDark,
      ),
      scaffoldBackgroundColor: AppConstants.surfaceDark,
      fontFamily: 'Amiri',
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppConstants.cardDarker.withValues(alpha: 0.95),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppConstants.cardDark,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppConstants.cardDarker.withValues(alpha: 0.98),
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppConstants.primaryColor.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: 'Amiri',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

// ==================== MODELS ====================

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  bool isBookmarked;
  bool isDownloaded;
  double downloadProgress;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.isBookmarked = false,
    this.isDownloaded = false,
    this.downloadProgress = 0.0,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
    );
  }

  bool get isMakki => revelationType == 'Meccan';
}

class Verse {
  final int number;
  final int numberInSurah;
  final String text;
  final int juz;
  final int page;
  final int hizbQuarter;
  String? translation;
  String? tafsir;
  String? audioUrl;

  Verse({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.juz,
    required this.page,
    required this.hizbQuarter,
    this.translation,
    this.tafsir,
    this.audioUrl,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: json['number'] ?? 0,
      numberInSurah: json['numberInSurah'] ?? 0,
      text: json['text'] ?? '',
      juz: json['juz'] ?? 1,
      page: json['page'] ?? 1,
      hizbQuarter: json['hizbQuarter'] ?? 1,
      audioUrl: json['audio'],
    );
  }
}

class Reciter {
  final String id;
  final String name;
  final String? server;
  final List<int> surahList;
  final String? photo;

  Reciter({
    required this.id,
    required this.name,
    this.server,
    this.surahList = const [],
    this.photo,
  });

  factory Reciter.fromMp3QuranJson(Map<String, dynamic> json) {
    final moshaf = json['moshaf'] as List?;
    String? server;
    List<int> surahList = [];
    
    if (moshaf != null && moshaf.isNotEmpty) {
      server = moshaf[0]['server'];
      final surahListStr = moshaf[0]['surah_list'] as String?;
      if (surahListStr != null) {
        surahList = surahListStr.split(',').map((s) => int.tryParse(s) ?? 0).toList();
      }
    }

    return Reciter(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      server: server,
      surahList: surahList,
    );
  }
}

class DownloadedSurah {
  final int surahNumber;
  final String reciterId;
  final String reciterName;
  final String filePath;
  final DateTime downloadedAt;
  final int fileSize;

  DownloadedSurah({
    required this.surahNumber,
    required this.reciterId,
    required this.reciterName,
    required this.filePath,
    required this.downloadedAt,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'reciterId': reciterId,
    'reciterName': reciterName,
    'filePath': filePath,
    'downloadedAt': downloadedAt.toIso8601String(),
    'fileSize': fileSize,
  };

  factory DownloadedSurah.fromJson(Map<String, dynamic> json) => DownloadedSurah(
    surahNumber: json['surahNumber'],
    reciterId: json['reciterId'],
    reciterName: json['reciterName'],
    filePath: json['filePath'],
    downloadedAt: DateTime.parse(json['downloadedAt']),
    fileSize: json['fileSize'] ?? 0,
  );
}

class Bookmark {
  final int surahNumber;
  final String surahName;
  final int verseNumber;
  final DateTime createdAt;
  final String? note;

  Bookmark({
    required this.surahNumber,
    required this.surahName,
    required this.verseNumber,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'surahName': surahName,
    'verseNumber': verseNumber,
    'createdAt': createdAt.toIso8601String(),
    'note': note,
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    surahNumber: json['surahNumber'],
    surahName: json['surahName'],
    verseNumber: json['verseNumber'],
    createdAt: DateTime.parse(json['createdAt']),
    note: json['note'],
  );
}

class AdhkarCategory {
  final int id;
  final String category;
  final List<AdhkarItem> items;

  AdhkarCategory({
    required this.id,
    required this.category,
    required this.items,
  });

  factory AdhkarCategory.fromJson(Map<String, dynamic> json) {
    final array = json['array'] as List? ?? [];
    return AdhkarCategory(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      items: array.map((e) => AdhkarItem.fromJson(e)).toList(),
    );
  }
}

class AdhkarItem {
  final int id;
  final String text;
  final int count;
  final String? audio;
  final String? reference;

  AdhkarItem({
    required this.id,
    required this.text,
    required this.count,
    this.audio,
    this.reference,
  });

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      count: json['count'] ?? 1,
      audio: json['audio'],
      reference: json['reference'],
    );
  }
}

class RadioStation {
  final String id;
  final String name;
  final String url;

  RadioStation({required this.id, required this.name, required this.url});

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class PrayerTimings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimings.fromJson(Map<String, dynamic> json) {
    return PrayerTimings(
      fajr: (json['Fajr'] ?? '').toString().split(' ').first,
      sunrise: (json['Sunrise'] ?? '').toString().split(' ').first,
      dhuhr: (json['Dhuhr'] ?? '').toString().split(' ').first,
      asr: (json['Asr'] ?? '').toString().split(' ').first,
      maghrib: (json['Maghrib'] ?? '').toString().split(' ').first,
      isha: (json['Isha'] ?? '').toString().split(' ').first,
    );
  }

  List<MapEntry<String, String>> toList() {
    return [
      MapEntry('الفجر', fajr),
      MapEntry('الشروق', sunrise),
      MapEntry('الظهر', dhuhr),
      MapEntry('العصر', asr),
      MapEntry('المغرب', maghrib),
      MapEntry('العشاء', isha),
    ];
  }
}

class LastRead {
  final int surah;
  final int ayah;
  final DateTime timestamp;

  LastRead({required this.surah, required this.ayah, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'surah': surah,
    'ayah': ayah,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LastRead.fromJson(Map<String, dynamic> json) => LastRead(
    surah: json['surah'],
    ayah: json['ayah'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

// ==================== DOWNLOAD SERVICE ====================

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Map<String, StreamController<double>> _progressControllers = {};
  final Map<String, bool> _activeDownloads = {};

  Stream<double> getProgressStream(String key) {
    _progressControllers[key] ??= StreamController<double>.broadcast();
    return _progressControllers[key]!.stream;
  }

  Future<String?> downloadSurah({
    required int surahNumber,
    required Reciter reciter,
    required Function(double) onProgress,
  }) async {
    final key = '${reciter.id}_$surahNumber';
    
    if (_activeDownloads[key] == true) {
      return null;
    }
    
    _activeDownloads[key] = true;
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/quran_audio');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final paddedNumber = surahNumber.toString().padLeft(3, '0');
      final url = '${reciter.server}$paddedNumber.mp3';
      final filePath = '${audioDir.path}/${reciter.id}_$paddedNumber.mp3';
      
      final file = File(filePath);
      if (await file.exists()) {
        _activeDownloads[key] = false;
        return filePath;
      }

      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      
      final contentLength = response.contentLength ?? 0;
      int receivedBytes = 0;
      
      final sink = file.openWrite();
      
      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          final progress = receivedBytes / contentLength;
          onProgress(progress);
          _progressControllers[key]?.add(progress);
        }
      }
      
      await sink.close();
      _activeDownloads[key] = false;
      
      return filePath;
    } catch (e) {
      _activeDownloads[key] = false;
      rethrow;
    }
  }

  Future<void> deleteSurah(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<int> getDownloadedSize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/quran_audio');
      if (!await audioDir.exists()) return 0;
      
      int totalSize = 0;
      await for (final entity in audioDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  void dispose() {
    for (var controller in _progressControllers.values) {
      controller.close();
    }
  }
}

// ==================== API SERVICES ====================

class QuranApiService {
  static const String _baseUrl = AppConstants.alquranApiBase;
  static const String _mp3BaseUrl = AppConstants.mp3quranApiBase;

  Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/surah'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahsJson = data['data'];
        return surahsJson.map((j) => Surah.fromJson(j)).toList();
      }
      throw Exception('Failed to load surahs');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Verse>> getVerses(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surah/$surahNumber/ar.alafasy'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ayahs = data['data']['ayahs'];
        return ayahs.map((ayah) => Verse.fromJson(ayah)).toList();
      }
      throw Exception('Failed to load verses');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Verse>> getVersesWithTranslation(int surahNumber, String translationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surah/$surahNumber/editions/quran-uthmani,$translationId'),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> editions = data['data'];
        
        final arabicAyahs = editions[0]['ayahs'] as List;
        final translationAyahs = editions.length > 1 ? editions[1]['ayahs'] as List : [];

        return List.generate(arabicAyahs.length, (i) {
          final verse = Verse.fromJson(arabicAyahs[i]);
          if (i < translationAyahs.length) {
            verse.translation = translationAyahs[i]['text'];
          }
          return verse;
        });
      }
      throw Exception('Failed to load verses');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Reciter>> getReciters({String language = 'ar'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_mp3BaseUrl/reciters?language=$language'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recitersJson = data['reciters'] ?? [];
        return recitersJson
            .map((j) => Reciter.fromMp3QuranJson(j))
            .where((r) => r.server != null)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<RadioStation>> getRadios({String language = 'ar'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_mp3BaseUrl/radios?language=$language'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> radiosJson = data['radios'] ?? [];
        return radiosJson.map((j) => RadioStation.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  String getSurahAudioUrl(Reciter reciter, int surahNumber) {
    final paddedNumber = surahNumber.toString().padLeft(3, '0');
    return '${reciter.server}$paddedNumber.mp3';
  }
}

class AdhkarService {
  Future<List<AdhkarCategory>> getAdhkar() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.adhkarApiUrl),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => AdhkarCategory.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

class PrayerTimeService {
  Future<PrayerTimings?> getPrayerTimes(double lat, double lng) async {
    try {
      final now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          '${AppConstants.aladhanApiBase}/timings/${now.day}-${now.month}-${now.year}?latitude=$lat&longitude=$lng&method=4',
        ),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimings.fromJson(data['data']['timings']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double calculateQiblaDirection(double lat, double lng) {
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;

    final latRad = lat * pi / 180;
    final lngRad = lng * pi / 180;
    final kaabaLatRad = kaabaLat * pi / 180;
    final kaabaLngRad = kaabaLng * pi / 180;

    final y = sin(kaabaLngRad - lngRad);
    final x = cos(latRad) * tan(kaabaLatRad) - sin(latRad) * cos(kaabaLngRad - lngRad);
    
    var qibla = atan2(y, x) * 180 / pi;
    if (qibla < 0) qibla += 360;
    
    return qibla;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }
}

// ==================== AUDIO SERVICE ====================

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String _currentType = 'none';
  
  bool get isPlaying => _isPlaying;
  String get currentType => _currentType;
  AudioPlayer get player => _player;
  
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Duration? get duration => _player.duration;
  Duration get position => _player.position;

  Future<void> playSurah(String url) async {
    try {
      _currentType = 'surah';
      await _player.setUrl(url);
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      _currentType = 'none';
      rethrow;
    }
  }

  Future<void> playFromFile(String filePath) async {
    try {
      _currentType = 'surah';
      await _player.setFilePath(filePath);
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      _currentType = 'none';
      rethrow;
    }
  }

  Future<void> playRadio(String url) async {
    try {
      _currentType = 'radio';
      await _player.setUrl(url);
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      _currentType = 'none';
      rethrow;
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> resume() async {
    await _player.play();
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentType = 'none';
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void dispose() {
    _player.dispose();
  }
}

// ==================== MAIN SCREEN ====================

class MainScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final Function(String) onThemeChanged;
  final String currentTheme;

  const MainScreen({
    super.key,
    required this.prefs,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final AudioService _audioService = AudioService();
  final QuranApiService _apiService = QuranApiService();
  final DownloadService _downloadService = DownloadService();
  
  List<Surah> _surahs = [];
  List<Reciter> _reciters = [];
  List<Bookmark> _bookmarks = [];
  List<DownloadedSurah> _downloadedSurahs = [];
  LastRead? _lastRead;
  bool _isLoading = true;
  Reciter? _selectedReciter;
  bool _isOnline = true;
  
  double _fontSize = 24.0;
  bool _showTranslation = true;

  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
    
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _loadData() async {
    _loadSettings();
    _loadBookmarks();
    _loadLastRead();
    _loadDownloadedSurahs();
    
    try {
      final results = await Future.wait([
        _apiService.getSurahs(),
        _apiService.getReciters(),
      ]);
      
      setState(() {
        _surahs = results[0] as List<Surah>;
        _reciters = results[1] as List<Reciter>;
        if (_reciters.isNotEmpty) {
          final savedReciterId = widget.prefs.getString('reciter_id');
          _selectedReciter = _reciters.firstWhere(
            (r) => r.id == savedReciterId,
            orElse: () => _reciters.first,
          );
        }
        _updateSurahsDownloadStatus();
        _updateBookmarkedSurahs();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _loadSettings() {
    _fontSize = widget.prefs.getDouble('font_size') ?? 24.0;
    _showTranslation = widget.prefs.getBool('show_translation') ?? true;
  }

  void _loadBookmarks() {
    final jsonString = widget.prefs.getString('bookmarks');
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      _bookmarks = jsonList.map((j) => Bookmark.fromJson(j)).toList();
    }
  }

  void _saveBookmarks() {
    final jsonList = _bookmarks.map((b) => b.toJson()).toList();
    widget.prefs.setString('bookmarks', json.encode(jsonList));
  }

  void _loadLastRead() {
    final jsonString = widget.prefs.getString('last_read');
    if (jsonString != null) {
      _lastRead = LastRead.fromJson(json.decode(jsonString));
    }
  }

  void _saveLastRead(int surah, int ayah) {
    _lastRead = LastRead(surah: surah, ayah: ayah, timestamp: DateTime.now());
    widget.prefs.setString('last_read', json.encode(_lastRead!.toJson()));
    setState(() {});
  }

  void _loadDownloadedSurahs() {
    final jsonString = widget.prefs.getString('downloaded_surahs');
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      _downloadedSurahs = jsonList.map((j) => DownloadedSurah.fromJson(j)).toList();
    }
  }

  void _saveDownloadedSurahs() {
    final jsonList = _downloadedSurahs.map((d) => d.toJson()).toList();
    widget.prefs.setString('downloaded_surahs', json.encode(jsonList));
  }

  void _updateSurahsDownloadStatus() {
    for (var surah in _surahs) {
      surah.isDownloaded = _downloadedSurahs.any(
        (d) => d.surahNumber == surah.number && d.reciterId == _selectedReciter?.id,
      );
    }
  }

  void _updateBookmarkedSurahs() {
    for (var surah in _surahs) {
      surah.isBookmarked = _bookmarks.any((b) => b.surahNumber == surah.number);
    }
  }

  void _toggleBookmark(int surah, int ayah, String surahName) {
    final existingIndex = _bookmarks.indexWhere(
      (b) => b.surahNumber == surah && b.verseNumber == ayah,
    );

    setState(() {
      if (existingIndex >= 0) {
        _bookmarks.removeAt(existingIndex);
        _showSnackBar('تمت الإزالة من المفضلة', Icons.bookmark_remove);
      } else {
        _bookmarks.add(Bookmark(
          surahNumber: surah,
          surahName: surahName,
          verseNumber: ayah,
          createdAt: DateTime.now(),
        ));
        _showSnackBar('تمت الإضافة للمفضلة', Icons.bookmark_add);
      }
      _updateBookmarkedSurahs();
    });
    _saveBookmarks();
  }

  void _showSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppConstants.primaryColor,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.secondaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeTab(
                surahs: _surahs,
                isLoading: _isLoading,
                lastRead: _lastRead,
                bookmarks: _bookmarks,
                downloadedSurahs: _downloadedSurahs,
                selectedReciter: _selectedReciter,
                isOnline: _isOnline,
                onSurahTap: _openSurah,
                onContinueReading: _continueReading,
                onDownloadSurah: _downloadSurah,
                onDeleteDownload: _deleteDownload,
              ),
              DownloadsTab(
                surahs: _surahs,
                downloadedSurahs: _downloadedSurahs,
                reciters: _reciters,
                selectedReciter: _selectedReciter,
                audioService: _audioService,
                onPlay: _playDownloaded,
                onDelete: _deleteDownload,
                onSurahTap: _openSurah,
              ),
              AdhkarTab(audioService: _audioService),
              RadioTab(audioService: _audioService, isOnline: _isOnline),
              const PrayerTimesTab(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'القرآن الكريم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppConstants.goldGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'v2.0.0',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (!_isOnline) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off, size: 10, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            'غير متصل',
                            style: TextStyle(fontSize: 9, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.download_rounded),
              if (_downloadedSurahs.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_downloadedSurahs.length}',
                      style: const TextStyle(fontSize: 8, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => setState(() => _currentIndex = 1),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () => _showSettingsBottomSheet(),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppConstants.cardDarker.withValues(alpha: 0.98)
            : Colors.white.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'الرئيسية'),
              _buildNavItem(1, Icons.download_rounded, Icons.download_outlined, 'التحميلات'),
              const SizedBox(width: 56), // Space for FAB
              _buildNavItem(3, Icons.radio_rounded, Icons.radio_outlined, 'الراديو'),
              _buildNavItem(4, Icons.mosque_rounded, Icons.mosque_outlined, 'الصلاة'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppConstants.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppConstants.primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppConstants.primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppConstants.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => setState(() => _currentIndex = 2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  void _openSurah(Surah surah, [int? scrollToAyah]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahDetailScreen(
          surah: surah,
          audioService: _audioService,
          reciters: _reciters,
          selectedReciter: _selectedReciter,
          fontSize: _fontSize,
          showTranslation: _showTranslation,
          bookmarks: _bookmarks,
          downloadedSurahs: _downloadedSurahs,
          scrollToAyah: scrollToAyah,
          isOnline: _isOnline,
          onBookmarkToggle: (ayah) => _toggleBookmark(surah.number, ayah, surah.name),
          onPageChanged: (ayah) => _saveLastRead(surah.number, ayah),
          onReciterChanged: (reciter) {
            setState(() => _selectedReciter = reciter);
            widget.prefs.setString('reciter_id', reciter.id);
          },
          onDownloadComplete: (downloaded) {
            setState(() {
              _downloadedSurahs.add(downloaded);
              _updateSurahsDownloadStatus();
            });
            _saveDownloadedSurahs();
          },
        ),
      ),
    );
  }

  void _continueReading() {
    if (_lastRead != null) {
      final surah = _surahs.firstWhere((s) => s.number == _lastRead!.surah);
      _openSurah(surah, _lastRead!.ayah);
    }
  }

  Future<void> _downloadSurah(Surah surah) async {
    if (_selectedReciter == null) {
      _showSnackBar('يرجى اختيار قارئ أولاً', Icons.error);
      return;
    }

    try {
      final filePath = await _downloadService.downloadSurah(
        surahNumber: surah.number,
        reciter: _selectedReciter!,
        onProgress: (progress) {
          setState(() {
            surah.downloadProgress = progress;
          });
        },
      );

      if (filePath != null) {
        final downloadedSurah = DownloadedSurah(
          surahNumber: surah.number,
          reciterId: _selectedReciter!.id,
          reciterName: _selectedReciter!.name,
          filePath: filePath,
          downloadedAt: DateTime.now(),
          fileSize: await File(filePath).length(),
        );

        setState(() {
          _downloadedSurahs.add(downloadedSurah);
          surah.isDownloaded = true;
          surah.downloadProgress = 0.0;
        });
        _saveDownloadedSurahs();
        _showSnackBar('تم تحميل السورة بنجاح', Icons.check_circle);
      }
    } catch (e) {
      setState(() {
        surah.downloadProgress = 0.0;
      });
      _showSnackBar('فشل التحميل: $e', Icons.error);
    }
  }

  Future<void> _deleteDownload(DownloadedSurah downloaded) async {
    await _downloadService.deleteSurah(downloaded.filePath);
    setState(() {
      _downloadedSurahs.removeWhere(
        (d) => d.surahNumber == downloaded.surahNumber && d.reciterId == downloaded.reciterId,
      );
      _updateSurahsDownloadStatus();
    });
    _saveDownloadedSurahs();
    _showSnackBar('تم حذف التحميل', Icons.delete);
  }

  void _playDownloaded(DownloadedSurah downloaded) async {
    try {
      await _audioService.playFromFile(downloaded.filePath);
    } catch (e) {
      _showSnackBar('خطأ في التشغيل', Icons.error);
    }
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsBottomSheet(
        prefs: widget.prefs,
        currentTheme: widget.currentTheme,
        fontSize: _fontSize,
        showTranslation: _showTranslation,
        reciters: _reciters,
        selectedReciter: _selectedReciter,
        downloadedSize: _downloadedSurahs.fold<int>(0, (sum, d) => sum + d.fileSize),
        onThemeChanged: widget.onThemeChanged,
        onFontSizeChanged: (value) {
          setState(() => _fontSize = value);
          widget.prefs.setDouble('font_size', value);
        },
        onShowTranslationChanged: (value) {
          setState(() => _showTranslation = value);
          widget.prefs.setBool('show_translation', value);
        },
        onReciterChanged: (reciter) {
          setState(() {
            _selectedReciter = reciter;
            _updateSurahsDownloadStatus();
          });
          widget.prefs.setString('reciter_id', reciter.id);
        },
        onClearDownloads: () async {
          for (var download in _downloadedSurahs) {
            await _downloadService.deleteSurah(download.filePath);
          }
          setState(() {
            _downloadedSurahs.clear();
            _updateSurahsDownloadStatus();
          });
          _saveDownloadedSurahs();
        },
      ),
    );
  }
}

// ==================== HOME TAB ====================

class HomeTab extends StatefulWidget {
  final List<Surah> surahs;
  final bool isLoading;
  final LastRead? lastRead;
  final List<Bookmark> bookmarks;
  final List<DownloadedSurah> downloadedSurahs;
  final Reciter? selectedReciter;
  final bool isOnline;
  final Function(Surah, [int?]) onSurahTap;
  final VoidCallback onContinueReading;
  final Function(Surah) onDownloadSurah;
  final Function(DownloadedSurah) onDeleteDownload;

  const HomeTab({
    super.key,
    required this.surahs,
    required this.isLoading,
    required this.lastRead,
    required this.bookmarks,
    required this.downloadedSurahs,
    required this.selectedReciter,
    required this.isOnline,
    required this.onSurahTap,
    required this.onContinueReading,
    required this.onDownloadSurah,
    required this.onDeleteDownload,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _currentFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Surah> get _filteredSurahs {
    var list = widget.surahs;
    
    if (_searchQuery.isNotEmpty) {
      list = list.where((s) {
        return s.name.contains(_searchQuery) ||
            s.englishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.number.toString() == _searchQuery;
      }).toList();
    }
    
    switch (_currentFilter) {
      case 'makki':
        list = list.where((s) => s.isMakki).toList();
        break;
      case 'madani':
        list = list.where((s) => !s.isMakki).toList();
        break;
      case 'bookmarked':
        list = list.where((s) => s.isBookmarked).toList();
        break;
      case 'downloaded':
        list = list.where((s) => s.isDownloaded).toList();
        break;
    }
    
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildLastReadCard()),
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverToBoxAdapter(child: _buildFilterChips()),
        SliverToBoxAdapter(child: _buildSurahsHeader()),
        widget.isLoading
            ? const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppConstants.primaryColor),
                      SizedBox(height: 16),
                      Text('جاري تحميل السور...'),
                    ],
                  ),
                ),
              )
            : _filteredSurahs.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد نتائج',
                            style: TextStyle(color: Colors.grey[500], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.only(bottom: 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.5, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                (index / _filteredSurahs.length) * 0.5,
                                ((index + 1) / _filteredSurahs.length) * 0.5 + 0.5,
                                curve: Curves.easeOutCubic,
                              ),
                            )),
                            child: _buildSurahCard(_filteredSurahs[index]),
                          );
                        },
                        childCount: _filteredSurahs.length,
                      ),
                    ),
                  ),
      ],
    );
  }

  Widget _buildLastReadCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor.withValues(alpha: 0.15),
            AppConstants.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppConstants.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_stories, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'آخر قراءة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLastReadText(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isOnline ? Icons.wifi : Icons.wifi_off,
                        size: 14,
                        color: widget.isOnline ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.isOnline ? 'متصل' : 'غير متصل',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.isOnline ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.lastRead != null ? widget.onContinueReading : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      widget.lastRead != null ? 'متابعة القراءة' : 'ابدأ القراءة',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.downloadedSurahs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.download_done, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.downloadedSurahs.length} سورة محملة للاستماع بدون إنترنت',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getLastReadText() {
    if (widget.lastRead != null && widget.surahs.isNotEmpty) {
      final surah = widget.surahs.firstWhere(
        (s) => s.number == widget.lastRead!.surah,
        orElse: () => widget.surahs.first,
      );
      return '${surah.name} - الآية ${widget.lastRead!.ayah}';
    }
    return 'لا يوجد قراءة سابقة';
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث في السور...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: Colors.grey[500]),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(top: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('الكل', 'all', Icons.apps, Colors.green),
          const SizedBox(width: 10),
          _buildFilterChip('مكية', 'makki', Icons.location_city, Colors.blue),
          const SizedBox(width: 10),
          _buildFilterChip('مدنية', 'madani', Icons.mosque, Colors.purple),
          const SizedBox(width: 10),
          _buildFilterChip('المفضلة', 'bookmarked', Icons.bookmark, Colors.amber),
          const SizedBox(width: 10),
          _buildFilterChip('المحملة', 'downloaded', Icons.download_done, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter, IconData icon, Color color) {
    final isActive = _currentFilter == filter;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _currentFilter = filter),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive 
                ? color.withValues(alpha: 0.2)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color : Colors.grey.withValues(alpha: 0.2),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isActive ? color : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? color : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahsHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'السور',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_filteredSurahs.length} سورة',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(Surah surah) {
    final isDownloaded = widget.downloadedSurahs.any(
      (d) => d.surahNumber == surah.number && d.reciterId == widget.selectedReciter?.id,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => widget.onSurahTap(surah),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Surah number with gradient
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: AppConstants.rainbowGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Surah info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              surah.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (isDownloaded)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.download_done,
                                size: 16,
                                color: Colors.green,
                              ),
                            ),
                          if (surah.isBookmarked) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.bookmark,
                              size: 18,
                              color: Colors.amber[600],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surah.englishNameTranslation,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildSurahBadge(
                            '${surah.numberOfAyahs} آية',
                            Icons.format_list_numbered,
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildSurahBadge(
                            surah.isMakki ? 'مكية' : 'مدنية',
                            surah.isMakki ? Icons.location_city : Icons.mosque,
                            surah.isMakki ? Colors.blue : Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Download button
                if (widget.selectedReciter != null && widget.isOnline)
                  surah.downloadProgress > 0 && surah.downloadProgress < 1
                      ? SizedBox(
                          width: 48,
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: surah.downloadProgress,
                                strokeWidth: 3,
                                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                color: AppConstants.primaryColor,
                              ),
                              Text(
                                '${(surah.downloadProgress * 100).toInt()}%',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        )
                      : isDownloaded
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                final downloaded = widget.downloadedSurahs.firstWhere(
                                  (d) => d.surahNumber == surah.number && 
                                         d.reciterId == widget.selectedReciter?.id,
                                );
                                widget.onDeleteDownload(downloaded);
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.download_outlined),
                              onPressed: () => widget.onDownloadSurah(surah),
                            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ==================== DOWNLOADS TAB ====================

class DownloadsTab extends StatelessWidget {
  final List<Surah> surahs;
  final List<DownloadedSurah> downloadedSurahs;
  final List<Reciter> reciters;
  final Reciter? selectedReciter;
  final AudioService audioService;
  final Function(DownloadedSurah) onPlay;
  final Function(DownloadedSurah) onDelete;
  final Function(Surah, [int?]) onSurahTap;

  const DownloadsTab({
    super.key,
    required this.surahs,
    required this.downloadedSurahs,
    required this.reciters,
    required this.selectedReciter,
    required this.audioService,
    required this.onPlay,
    required this.onDelete,
    required this.onSurahTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalSize = downloadedSurahs.fold<int>(0, (sum, d) => sum + d.fileSize);
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryColor.withValues(alpha: 0.15),
                  AppConstants.secondaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppConstants.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppConstants.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.download_done, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'التحميلات',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${downloadedSurahs.length} سورة • ${_formatFileSize(totalSize)}',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'السور المحملة متاحة للاستماع بدون إنترنت',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (downloadedSurahs.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.download_outlined, size: 64, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'لا توجد تحميلات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بتحميل السور للاستماع إليها\nبدون اتصال بالإنترنت',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final download = downloadedSurahs[index];
                  final surah = surahs.firstWhere(
                    (s) => s.number == download.surahNumber,
                    orElse: () => surahs.first,
                  );
                  final reciter = reciters.firstWhere(
                    (r) => r.id == download.reciterId,
                    orElse: () => reciters.first,
                  );

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () => onSurahTap(surah),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppConstants.rainbowGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    '${surah.number}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surah.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reciter.name,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatFileSize(download.fileSize),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: AppConstants.primaryGradient,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    onPressed: () => onPlay(download),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _showDeleteDialog(context, download),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: downloadedSurahs.length,
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, DownloadedSurah download) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('حذف التحميل'),
        content: const Text('هل تريد حذف هذه السورة من التحميلات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              onDelete(download);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ==================== ADHKAR TAB ====================

class AdhkarTab extends StatefulWidget {
  final AudioService audioService;

  const AdhkarTab({super.key, required this.audioService});

  @override
  State<AdhkarTab> createState() => _AdhkarTabState();
}

class _AdhkarTabState extends State<AdhkarTab> {
  final AdhkarService _adhkarService = AdhkarService();
  List<AdhkarCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdhkar();
  }

  Future<void> _loadAdhkar() async {
    final categories = await _adhkarService.getAdhkar();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppConstants.primaryColor),
            SizedBox(height: 16),
            Text('جاري تحميل الأذكار...'),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_outline, size: 64, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد أذكار',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: AppConstants.primaryGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'الأذكار والأدعية',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'حافظ على أذكارك اليومية',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = _categories[index];
                final colors = [
                  [const Color(0xFFFF6B6B), const Color(0xFFEE5A5A)],
                  [const Color(0xFF4ECDC4), const Color(0xFF44A39D)],
                  [const Color(0xFF45B7D1), const Color(0xFF3A9BB8)],
                  [const Color(0xFFF7B731), const Color(0xFFD49E29)],
                  [const Color(0xFF5F27CD), const Color(0xFF4E20A8)],
                  [const Color(0xFFFC427B), const Color(0xFFD93666)],
                  [const Color(0xFF1DD1A1), const Color(0xFF19B089)],
                  [const Color(0xFFFFA502), const Color(0xFFD98E02)],
                ];
                final colorPair = colors[index % colors.length];
                
                return _buildCategoryCard(category, colorPair);
              },
              childCount: _categories.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(AdhkarCategory category, List<Color> colors) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => _openAdhkarCategory(category),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${category.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  category.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.items.length} ذكر',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAdhkarCategory(AdhkarCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdhkarDetailScreen(
          category: category,
          audioService: widget.audioService,
        ),
      ),
    );
  }
}

// ==================== ADHKAR DETAIL SCREEN ====================

class AdhkarDetailScreen extends StatefulWidget {
  final AdhkarCategory category;
  final AudioService audioService;

  const AdhkarDetailScreen({
    super.key,
    required this.category,
    required this.audioService,
  });

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  Map<int, int> _counters = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.category.items) {
      _counters[item.id] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.category),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.items.length,
        itemBuilder: (context, index) {
          final item = widget.category.items[index];
          return _buildAdhkarCard(item);
        },
      ),
    );
  }

  Widget _buildAdhkarCard(AdhkarItem item) {
    final count = _counters[item.id] ?? 0;
    final isCompleted = item.count > 0 && count >= item.count;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isCompleted 
            ? Colors.green.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        border: isCompleted 
            ? Border.all(color: Colors.green.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _incrementCounter(item),
          onLongPress: () => _resetCounter(item),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'التكرار: ${item.count}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  item.text,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Amiri',
                    height: 2,
                    color: isCompleted ? Colors.green[700] : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isCompleted 
                          ? const LinearGradient(colors: [Colors.green, Color(0xFF2E7D32)])
                          : AppConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted ? Colors.green : AppConstants.primaryColor)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      item.count > 0 ? '$count / ${item.count}' : '$count',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (item.reference != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    item.reference!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _incrementCounter(AdhkarItem item) {
    if (item.count == 0 || (_counters[item.id] ?? 0) < item.count) {
      setState(() {
        _counters[item.id] = (_counters[item.id] ?? 0) + 1;
      });

      if (item.count > 0 && _counters[item.id] == item.count) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 12),
                Text('أحسنت! أكملت هذا الذكر'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _resetCounter(AdhkarItem item) {
    setState(() {
      _counters[item.id] = 0;
    });
    HapticFeedback.lightImpact();
  }
}

// ==================== RADIO TAB ====================

class RadioTab extends StatefulWidget {
  final AudioService audioService;
  final bool isOnline;

  const RadioTab({super.key, required this.audioService, required this.isOnline});

  @override
  State<RadioTab> createState() => _RadioTabState();
}

class _RadioTabState extends State<RadioTab> {
  final QuranApiService _apiService = QuranApiService();
  List<RadioStation> _radios = [];
  bool _isLoading = true;
  RadioStation? _playingRadio;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final radios = await _apiService.getRadios();
    setState(() {
      _radios = radios;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOnline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off, size: 64, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            const Text(
              'غير متصل بالإنترنت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'الراديو يتطلب اتصال بالإنترنت',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppConstants.primaryColor),
            SizedBox(height: 16),
            Text('جاري تحميل المحطات...'),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        if (_playingRadio != null && widget.audioService.isPlaying)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.radio, size: 56, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    _playingRadio!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '🔴 بث مباشر',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _stopRadio,
                    icon: const Icon(Icons.stop),
                    label: const Text('إيقاف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'إذاعات القرآن الكريم',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final radio = _radios[index];
                final isPlaying = _playingRadio?.id == radio.id && widget.audioService.isPlaying;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isPlaying 
                        ? AppConstants.primaryColor.withValues(alpha: 0.1)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isPlaying 
                        ? Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3))
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isPlaying 
                            ? AppConstants.primaryGradient
                            : LinearGradient(
                                colors: [
                                  Colors.grey.withValues(alpha: 0.2),
                                  Colors.grey.withValues(alpha: 0.1),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isPlaying ? Icons.radio : Icons.radio_outlined,
                        color: isPlaying ? Colors.white : Colors.grey,
                      ),
                    ),
                    title: Text(
                      radio.name,
                      style: TextStyle(
                        fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
                        color: isPlaying ? AppConstants.primaryColor : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: isPlaying ? null : AppConstants.primaryGradient,
                          color: isPlaying ? Colors.red : null,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () => isPlaying ? _stopRadio() : _playRadio(radio),
                    ),
                  ),
                );
              },
              childCount: _radios.length,
            ),
          ),
        ),
      ],
    );
  }

  void _playRadio(RadioStation radio) async {
    try {
      await widget.audioService.playRadio(radio.url);
      setState(() => _playingRadio = radio);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في تشغيل الراديو')),
        );
      }
    }
  }

  void _stopRadio() async {
    await widget.audioService.stop();
    setState(() => _playingRadio = null);
  }
}

// ==================== PRAYER TIMES TAB ====================

class PrayerTimesTab extends StatefulWidget {
  const PrayerTimesTab({super.key});

  @override
  State<PrayerTimesTab> createState() => _PrayerTimesTabState();
}

class _PrayerTimesTabState extends State<PrayerTimesTab> {
  final PrayerTimeService _service = PrayerTimeService();
  PrayerTimings? _timings;
  double? _qiblaDirection;
  String _cityName = 'جاري التحديد...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() => _isLoading = true);

    try {
      final position = await _service.getCurrentLocation();
      
      if (position != null) {
        final timings = await _service.getPrayerTimes(position.latitude, position.longitude);
        final qibla = _service.calculateQiblaDirection(position.latitude, position.longitude);

        setState(() {
          _timings = timings;
          _qiblaDirection = qibla;
          _cityName = 'موقعك الحالي';
          _isLoading = false;
        });
      } else {
        final timings = await _service.getPrayerTimes(30.0444, 31.2357);
        final qibla = _service.calculateQiblaDirection(30.0444, 31.2357);

        setState(() {
          _timings = timings;
          _qiblaDirection = qibla;
          _cityName = 'القاهرة (افتراضي)';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadPrayerTimes,
      color: AppConstants.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'أوقات الصلاة',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppConstants.primaryColor),
              ),
            )
          else ...[
            // Location card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor.withValues(alpha: 0.15),
                    AppConstants.secondaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppConstants.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cityName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.refresh, size: 20),
                    ),
                    onPressed: _loadPrayerTimes,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Prayer times
            if (_timings != null)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: _timings!.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final prayerEntry = entry.value;
                    final isLast = index == _timings!.toList().length - 1;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        border: isLast ? null : Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getPrayerColor(prayerEntry.key).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _getPrayerIcon(prayerEntry.key),
                              color: _getPrayerColor(prayerEntry.key),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              prayerEntry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getPrayerColor(prayerEntry.key).withValues(alpha: 0.2),
                                  _getPrayerColor(prayerEntry.key).withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              prayerEntry.value,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getPrayerColor(prayerEntry.key),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),
            // Qibla direction
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppConstants.goldGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'اتجاه القبلة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppConstants.goldColor.withValues(alpha: 0.3),
                        width: 4,
                      ),
                      gradient: RadialGradient(
                        colors: [
                          AppConstants.goldColor.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Direction indicators
                        ...['N', 'E', 'S', 'W'].asMap().entries.map((entry) {
                          final index = entry.key;
                          final direction = entry.value;
                          return Positioned(
                            top: index == 0 ? 10 : (index == 2 ? null : 80),
                            bottom: index == 2 ? 10 : null,
                            left: index == 3 ? 10 : (index == 1 ? null : null),
                            right: index == 1 ? 10 : null,
                            child: Text(
                              direction,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                        // Compass needle
                        Transform.rotate(
                          angle: (_qiblaDirection ?? 0) * pi / 180,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: AppConstants.goldGradient,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const Icon(
                                Icons.mosque,
                                color: AppConstants.goldColor,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: AppConstants.goldGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.goldColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppConstants.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.goldColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_qiblaDirection?.toStringAsFixed(1) ?? '--'}°',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'الفجر': return Icons.nightlight_round;
      case 'الشروق': return Icons.wb_twilight;
      case 'الظهر': return Icons.wb_sunny;
      case 'العصر': return Icons.sunny_snowing;
      case 'المغرب': return Icons.wb_twilight;
      case 'العشاء': return Icons.nights_stay;
      default: return Icons.access_time;
    }
  }

  Color _getPrayerColor(String prayerName) {
    switch (prayerName) {
      case 'الفجر': return const Color(0xFF5C6BC0);
      case 'الشروق': return const Color(0xFFFF7043);
      case 'الظهر': return const Color(0xFFFFC107);
      case 'العصر': return const Color(0xFF66BB6A);
      case 'المغرب': return const Color(0xFFEF5350);
      case 'العشاء': return const Color(0xFF7E57C2);
      default: return Colors.grey;
    }
  }
}

// ==================== SETTINGS BOTTOM SHEET ====================

class SettingsBottomSheet extends StatelessWidget {
  final SharedPreferences prefs;
  final String currentTheme;
  final double fontSize;
  final bool showTranslation;
  final List<Reciter> reciters;
  final Reciter? selectedReciter;
  final int downloadedSize;
  final Function(String) onThemeChanged;
  final Function(double) onFontSizeChanged;
  final Function(bool) onShowTranslationChanged;
  final Function(Reciter) onReciterChanged;
  final VoidCallback onClearDownloads;

  const SettingsBottomSheet({
    super.key,
    required this.prefs,
    required this.currentTheme,
    required this.fontSize,
    required this.showTranslation,
    required this.reciters,
    required this.selectedReciter,
    required this.downloadedSize,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onShowTranslationChanged,
    required this.onReciterChanged,
    required this.onClearDownloads,
  });

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.settings, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'الإعدادات',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSectionTitle('المظهر'),
                  _buildSettingCard(
                    context,
                    child: Column(
                      children: [
                        _buildThemeOption(context, 'داكن', 'dark', Icons.dark_mode),
                        Divider(color: Colors.grey.withValues(alpha: 0.1)),
                        _buildThemeOption(context, 'فاتح', 'light', Icons.light_mode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('القراءة'),
                  _buildSettingCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('حجم الخط'),
                        ),
                        Slider(
                          value: fontSize,
                          min: 16,
                          max: 40,
                          divisions: 12,
                          label: fontSize.round().toString(),
                          activeColor: AppConstants.primaryColor,
                          onChanged: onFontSizeChanged,
                        ),
                        Divider(color: Colors.grey.withValues(alpha: 0.1)),
                        SwitchListTile(
                          title: const Text('إظهار الترجمة'),
                          subtitle: const Text('عرض ترجمة الآيات بالإنجليزية'),
                          value: showTranslation,
                          activeColor: AppConstants.primaryColor,
                          onChanged: onShowTranslationChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('القارئ الافتراضي'),
                  _buildSettingCard(
                    context,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: AppConstants.secondaryColor),
                      ),
                      title: Text(selectedReciter?.name ?? 'اختر قارئ'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showReciterPicker(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('التخزين'),
                  _buildSettingCard(
                    context,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.storage, color: Colors.green),
                          ),
                          title: const Text('المساحة المستخدمة'),
                          trailing: Text(
                            _formatFileSize(downloadedSize),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Divider(color: Colors.grey.withValues(alpha: 0.1)),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_sweep, color: Colors.red),
                          ),
                          title: const Text('حذف كل التحميلات'),
                          subtitle: const Text('إزالة جميع السور المحملة'),
                          onTap: () => _showClearDownloadsDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('حول التطبيق'),
                  _buildSettingCard(
                    context,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.info_outline, color: AppConstants.primaryColor),
                          ),
                          title: const Text('الإصدار'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppConstants.goldGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '2.0.0 PRO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey.withValues(alpha: 0.1)),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_outline, color: Colors.purple),
                          ),
                          title: const Text('المطور'),
                          subtitle: const Text('محمد إبراهيم عبدالله'),
                        ),
                        Divider(color: Colors.grey.withValues(alpha: 0.1)),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.favorite, color: Colors.red),
                          ),
                          title: const Text('دعاء للمطور'),
                          subtitle: const Text('نسألكم الدعاء'),
                          onTap: () => _showDevPrayerDialog(context),
                        ),
                        Divider(color: Colors.grey.withValues(alpha: 0.1)),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.share, color: Colors.blue),
                          ),
                          title: const Text('مشاركة التطبيق'),
                          onTap: () {
                            Share.share('تطبيق القرآن الكريم PRO - أفضل تطبيق لقراءة القرآن والاستماع إليه');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildThemeOption(BuildContext context, String label, String value, IconData icon) {
    final isSelected = currentTheme == value;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppConstants.primaryColor.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppConstants.primaryColor : Colors.grey,
        ),
      ),
      title: Text(label),
      trailing: isSelected 
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                gradient: AppConstants.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            )
          : null,
      onTap: () => onThemeChanged(value),
    );
  }

  void _showReciterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'اختر القارئ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = reciters[index];
                    final isSelected = selectedReciter?.id == reciter.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppConstants.primaryColor.withValues(alpha: 0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppConstants.primaryGradient : null,
                            color: isSelected ? null : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                        title: Text(
                          reciter.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: AppConstants.primaryColor)
                            : null,
                        onTap: () {
                          onReciterChanged(reciter);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDownloadsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('حذف التحميلات'),
        content: const Text('هل أنت متأكد من حذف جميع السور المحملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              onClearDownloads();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }

  void _showDevPrayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'دعوة للمطور',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'نسألكم الدعاء للمطور (محمد إبراهيم عبدالله) بالتوفيق والسداد وأن يجعل هذا العمل في ميزان حسناته.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.8),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('آمين'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SURAH DETAIL SCREEN ====================

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final AudioService audioService;
  final List<Reciter> reciters;
  final Reciter? selectedReciter;
  final double fontSize;
  final bool showTranslation;
  final List<Bookmark> bookmarks;
  final List<DownloadedSurah> downloadedSurahs;
  final int? scrollToAyah;
  final bool isOnline;
  final Function(int) onBookmarkToggle;
  final Function(int) onPageChanged;
  final Function(Reciter) onReciterChanged;
  final Function(DownloadedSurah) onDownloadComplete;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    required this.audioService,
    required this.reciters,
    required this.selectedReciter,
    required this.fontSize,
    required this.showTranslation,
    required this.bookmarks,
    required this.downloadedSurahs,
    required this.scrollToAyah,
    required this.isOnline,
    required this.onBookmarkToggle,
    required this.onPageChanged,
    required this.onReciterChanged,
    required this.onDownloadComplete,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranApiService _apiService = QuranApiService();
  final DownloadService _downloadService = DownloadService();
  List<Verse> _verses = [];
  bool _isLoading = true;
  bool _isAudioControlsVisible = false;
  Reciter? _currentReciter;
  bool _isPlaying = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};

  @override
  void initState() {
    super.initState();
    _currentReciter = widget.selectedReciter;
    _loadVerses();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _positionSubscription = widget.audioService.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    
    _durationSubscription = widget.audioService.durationStream.listen((dur) {
      if (dur != null && mounted) setState(() => _duration = dur);
    });
    
    _playerStateSubscription = widget.audioService.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
  }

  Future<void> _loadVerses() async {
    try {
      final verses = widget.showTranslation
          ? await _apiService.getVersesWithTranslation(widget.surah.number, 'en.sahih')
          : await _apiService.getVerses(widget.surah.number);

      setState(() {
        _verses = verses;
        _isLoading = false;
      });

      for (var verse in _verses) {
        _verseKeys[verse.numberInSurah] = GlobalKey();
      }

      if (widget.scrollToAyah != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAyah(widget.scrollToAyah!);
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _verseKeys[ayahNumber];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  bool get _isDownloaded {
    return widget.downloadedSurahs.any(
      (d) => d.surahNumber == widget.surah.number && d.reciterId == _currentReciter?.id,
    );
  }

  String? get _downloadedFilePath {
    final downloaded = widget.downloadedSurahs.firstWhere(
      (d) => d.surahNumber == widget.surah.number && d.reciterId == _currentReciter?.id,
      orElse: () => DownloadedSurah(
        surahNumber: 0,
        reciterId: '',
        reciterName: '',
        filePath: '',
        downloadedAt: DateTime.now(),
        fileSize: 0,
      ),
    );
    return downloaded.filePath.isNotEmpty ? downloaded.filePath : null;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppConstants.cardDarker,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConstants.primaryColor.withValues(alpha: 0.8),
                      AppConstants.secondaryColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            widget.surah.name,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.surah.englishName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHeaderBadge(
                                '${widget.surah.numberOfAyahs} آية',
                                Icons.format_list_numbered,
                              ),
                              const SizedBox(width: 12),
                              _buildHeaderBadge(
                                widget.surah.isMakki ? 'مكية' : 'مدنية',
                                widget.surah.isMakki ? Icons.location_city : Icons.mosque,
                              ),
                              if (_isDownloaded) ...[
                                const SizedBox(width: 12),
                                _buildHeaderBadge('محملة', Icons.download_done),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () {
                widget.audioService.stop();
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isAudioControlsVisible ? Icons.headphones : Icons.headphones_outlined,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  setState(() => _isAudioControlsVisible = !_isAudioControlsVisible);
                },
              ),
              if (widget.isOnline && _currentReciter != null && !_isDownloaded)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: _isDownloading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: _downloadProgress,
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download, color: Colors.white),
                  ),
                  onPressed: _isDownloading ? null : _downloadSurah,
                ),
            ],
          ),
          if (widget.surah.number != 9 && widget.surah.number != 1)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.goldColor.withValues(alpha: 0.15),
                      AppConstants.goldColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppConstants.goldColor.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                    color: AppConstants.goldColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildVerseCard(_verses[index]),
                  childCount: _verses.length,
                ),
              ),
            ),
        ],
      ),
      bottomSheet: _isAudioControlsVisible ? _buildAudioControls() : null,
    );
  }

  Widget _buildHeaderBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(Verse verse) {
    final isBookmarked = widget.bookmarks.any(
      (b) => b.surahNumber == widget.surah.number && b.verseNumber == verse.numberInSurah,
    );

    String verseText = verse.text;
    if (verse.numberInSurah == 1 && widget.surah.number != 1 && widget.surah.number != 9) {
      verseText = verseText.replaceFirst(
        RegExp(r'^(بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ|بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ)\s*'),
        '',
      );
    }

    return Container(
      key: _verseKeys[verse.numberInSurah],
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppConstants.rainbowGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${verse.numberInSurah}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.bookmark,
                    size: 22,
                    color: isBookmarked ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => widget.onBookmarkToggle(verse.numberInSurah),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 22),
                  onPressed: () => _copyVerse(verse, verseText),
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 22),
                  onPressed: () => _shareVerse(verse, verseText),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              verseText,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontFamily: 'Amiri',
                height: 2.2,
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
            if (widget.showTranslation && verse.translation != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  verse.translation!,
                  style: TextStyle(
                    fontSize: widget.fontSize - 6,
                    color: Colors.grey[500],
                    height: 1.6,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildVerseBadge('الجزء ${verse.juz}', Icons.layers),
                const SizedBox(width: 8),
                _buildVerseBadge('الصفحة ${verse.page}', Icons.menu_book),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppConstants.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        ),
                        child: Slider(
                          value: _position.inSeconds.toDouble(),
                          max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
                          onChanged: (value) {
                            widget.audioService.seek(Duration(seconds: value.toInt()));
                          },
                          activeColor: AppConstants.primaryColor,
                          inactiveColor: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 20),
                  ),
                  onPressed: _showReciterPicker,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _currentReciter?.name ?? 'اختر قارئ',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await widget.audioService.pause();
    } else {
      if (_currentReciter != null) {
        try {
          // Try to play from downloaded file first
          if (_isDownloaded && _downloadedFilePath != null) {
            await widget.audioService.playFromFile(_downloadedFilePath!);
          } else if (widget.isOnline) {
            final url = _apiService.getSurahAudioUrl(_currentReciter!, widget.surah.number);
            await widget.audioService.playSurah(url);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('السورة غير محملة ولا يوجد اتصال بالإنترنت')),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('خطأ في تشغيل الصوت')),
            );
          }
        }
      }
    }
  }

  Future<void> _downloadSurah() async {
    if (_currentReciter == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final filePath = await _downloadService.downloadSurah(
        surahNumber: widget.surah.number,
        reciter: _currentReciter!,
        onProgress: (progress) {
          setState(() => _downloadProgress = progress);
        },
      );

      if (filePath != null) {
        final file = File(filePath);
        final fileSize = await file.length();
        
        final downloadedSurah = DownloadedSurah(
          surahNumber: widget.surah.number,
          reciterId: _currentReciter!.id,
          reciterName: _currentReciter!.name,
          filePath: filePath,
          downloadedAt: DateTime.now(),
          fileSize: fileSize,
        );

        widget.onDownloadComplete(downloadedSurah);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('تم تحميل السورة بنجاح'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحميل: $e')),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
      });
    }
  }

  void _showReciterPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'اختر القارئ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = widget.reciters[index];
                    final isAvailable = reciter.surahList.contains(widget.surah.number);
                    final isSelected = _currentReciter?.id == reciter.id;
                    final isDownloaded = widget.downloadedSurahs.any(
                      (d) => d.surahNumber == widget.surah.number && d.reciterId == reciter.id,
                    );
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppConstants.primaryColor.withValues(alpha: 0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: ListTile(
                        enabled: isAvailable,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppConstants.primaryGradient : null,
                            color: isSelected ? null : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person,
                            color: isSelected 
                                ? Colors.white 
                                : (isAvailable ? Colors.grey : Colors.grey[700]),
                          ),
                        ),
                        title: Text(
                          reciter.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isAvailable ? null : Colors.grey[600],
                          ),
                        ),
                        subtitle: isAvailable ? null : const Text('غير متوفر لهذه السورة'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDownloaded)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.download_done, size: 16, color: Colors.green),
                              ),
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.check_circle, color: AppConstants.primaryColor),
                              ),
                          ],
                        ),
                        onTap: isAvailable
                            ? () {
                                setState(() => _currentReciter = reciter);
                                widget.onReciterChanged(reciter);
                                Navigator.pop(context);
                                if (_isPlaying) {
                                  widget.audioService.stop();
                                  _togglePlayPause();
                                }
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyVerse(Verse verse, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('تم نسخ الآية'),
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _shareVerse(Verse verse, String text) {
    Share.share(
      '${widget.surah.name} - الآية ${verse.numberInSurah}\n\n$text\n\n(القرآن الكريم)',
    );
  }
}