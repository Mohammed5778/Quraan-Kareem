// main.dart - تطبيق القرآن الكريم الشامل (نسخة احترافية)
// Quran App Pro v1.9.2 - Single File Edition
// المطور: محمد إبراهيم عبدالله

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

// ==================== CONSTANTS ====================
class AppConstants {
  static const String alquranApiBase = 'https://api.alquran.cloud/v1';
  static const String mp3quranApiBase = 'https://mp3quran.net/api/v3';
  static const String adhkarApiUrl = 'https://raw.githubusercontent.com/rn0x/Adhkar-json/main/adhkar.json';
  static const String aladhanApiBase = 'https://api.aladhan.com/v1';
  
  static const Color primaryColor = Color(0xFF14b8a6);
  static const Color primaryHover = Color(0xFF0d9488);
  static const Color secondaryColor = Color(0xFF38bdf8);
  static const Color accentColor = Color(0xFFa78bfa);
  
  static const double devPrayerModalInterval = 2 * 24 * 60 * 60 * 1000; // 2 days
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
      _themeMode = theme == 'light' 
          ? ThemeMode.light 
          : theme == 'sepia' 
              ? ThemeMode.light 
              : ThemeMode.dark;
    });
  }

  void updateTheme(String mode) {
    setState(() {
      _currentTheme = mode;
      _themeMode = mode == 'light' || mode == 'sepia' 
          ? ThemeMode.light 
          : ThemeMode.dark;
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
        surface: const Color(0xFF0f172a),
      ),
      scaffoldBackgroundColor: const Color(0xFF020617),
      fontFamily: 'Amiri',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF0f172a),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0f172a).withValues(alpha: 0.85),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0f172a),
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
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
      scaffoldBackgroundColor: const Color(0xFFf8fafc),
      fontFamily: 'Amiri',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFf8fafc),
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

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.isBookmarked = false,
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

  Reciter({
    required this.id,
    required this.name,
    this.server,
    this.surahList = const [],
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

  RadioStation({
    required this.id,
    required this.name,
    required this.url,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class LiveTvChannel {
  final String id;
  final String name;
  final String url;

  LiveTvChannel({
    required this.id,
    required this.name,
    required this.url,
  });

  factory LiveTvChannel.fromJson(Map<String, dynamic> json) {
    return LiveTvChannel(
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

  LastRead({
    required this.surah,
    required this.ayah,
    required this.timestamp,
  });

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

class KhatmahGoal {
  final String type;
  final int start;
  final int end;
  final int duration;
  final DateTime startDate;

  KhatmahGoal({
    required this.type,
    required this.start,
    required this.end,
    required this.duration,
    required this.startDate,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'start': start,
    'end': end,
    'duration': duration,
    'startDate': startDate.toIso8601String(),
  };

  factory KhatmahGoal.fromJson(Map<String, dynamic> json) => KhatmahGoal(
    type: json['type'],
    start: json['start'],
    end: json['end'],
    duration: json['duration'],
    startDate: DateTime.parse(json['startDate']),
  );
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

  Future<List<Verse>> getVerses(int surahNumber, {String? reciterId}) async {
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

  Future<List<LiveTvChannel>> getLiveTv({String language = 'ar'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_mp3BaseUrl/live-tv?language=$language'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tvJson = data['livetv'] ?? [];
        return tvJson.map((j) => LiveTvChannel.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/$query/all/ar'),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['matches'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['matches']);
        }
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
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

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

  Future<void> playAdhkar(String url) async {
    try {
      _currentType = 'adhkar';
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

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final AudioService _audioService = AudioService();
  final QuranApiService _apiService = QuranApiService();
  
  List<Surah> _surahs = [];
  List<Reciter> _reciters = [];
  List<Bookmark> _bookmarks = [];
  LastRead? _lastRead;
  KhatmahGoal? _khatmahGoal;
  LastRead? _lastReadMarker;
  bool _isLoading = true;
  Reciter? _selectedReciter;
  
  double _fontSize = 24.0;
  bool _showTranslation = true;
  bool _showTafsir = false;
  String _arabicFont = 'naskh';

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkDevPrayerModal();
  }

  Future<void> _loadData() async {
    _loadSettings();
    _loadBookmarks();
    _loadLastRead();
    _loadKhatmahGoal();
    _loadLastReadMarker();
    
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
    _showTafsir = widget.prefs.getBool('show_tafsir') ?? false;
    _arabicFont = widget.prefs.getString('arabic_font') ?? 'naskh';
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
    _lastRead = LastRead(
      surah: surah,
      ayah: ayah,
      timestamp: DateTime.now(),
    );
    widget.prefs.setString('last_read', json.encode(_lastRead!.toJson()));
    setState(() {});
  }

  void _loadKhatmahGoal() {
    final jsonString = widget.prefs.getString('khatmah_goal');
    if (jsonString != null) {
      _khatmahGoal = KhatmahGoal.fromJson(json.decode(jsonString));
    }
  }

  void _saveKhatmahGoal(KhatmahGoal? goal) {
    if (goal != null) {
      widget.prefs.setString('khatmah_goal', json.encode(goal.toJson()));
    } else {
      widget.prefs.remove('khatmah_goal');
    }
    setState(() => _khatmahGoal = goal);
  }

  void _loadLastReadMarker() {
    final jsonString = widget.prefs.getString('last_read_marker');
    if (jsonString != null) {
      _lastReadMarker = LastRead.fromJson(json.decode(jsonString));
    }
  }

  void _saveLastReadMarker(int surah, int ayah) {
    if (_lastReadMarker?.surah == surah && _lastReadMarker?.ayah == ayah) {
      widget.prefs.remove('last_read_marker');
      setState(() => _lastReadMarker = null);
      _showSnackBar('تمت إزالة علامة التوقف');
    } else {
      _lastReadMarker = LastRead(
        surah: surah,
        ayah: ayah,
        timestamp: DateTime.now(),
      );
      widget.prefs.setString('last_read_marker', json.encode(_lastReadMarker!.toJson()));
      setState(() {});
      _showSnackBar('تم تحديد علامة التوقف');
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
        _showSnackBar('تمت الإزالة من المفضلة');
      } else {
        _bookmarks.add(Bookmark(
          surahNumber: surah,
          surahName: surahName,
          verseNumber: ayah,
          createdAt: DateTime.now(),
        ));
        _showSnackBar('تمت الإضافة للمفضلة');
      }
      _updateBookmarkedSurahs();
    });
    _saveBookmarks();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  void _checkDevPrayerModal() {
    final lastShown = widget.prefs.getInt('dev_prayer_last_shown') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if ((now - lastShown) > AppConstants.devPrayerModalInterval) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDevPrayerDialog();
      });
    }
  }

  void _showDevPrayerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.favorite, color: AppConstants.primaryColor),
            SizedBox(width: 8),
            Text('دعوة للمطور'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volunteer_activism, size: 64, color: AppConstants.primaryColor),
            SizedBox(height: 16),
            Text(
              'نسألكم الدعاء للمطور (محمد إبراهيم عبدالله) بالتوفيق والسداد وأن يجعل هذا العمل في ميزان حسناته.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.8),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              widget.prefs.setInt('dev_prayer_last_shown', DateTime.now().millisecondsSinceEpoch);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            surahs: _surahs,
            isLoading: _isLoading,
            lastRead: _lastRead,
            bookmarks: _bookmarks,
            khatmahGoal: _khatmahGoal,
            lastReadMarker: _lastReadMarker,
            onSurahTap: _openSurah,
            onContinueReading: _continueReading,
            onKhatmahGoalChanged: _saveKhatmahGoal,
          ),
          QuranNavigationTab(
            surahs: _surahs,
            khatmahGoal: _khatmahGoal,
            lastReadMarker: _lastReadMarker,
            onSurahTap: _openSurah,
            onKhatmahGoalChanged: _saveKhatmahGoal,
          ),
          AdhkarTab(audioService: _audioService),
          RadioTab(audioService: _audioService),
          const PrayerTimesTab(),
          MoreTab(
            prefs: widget.prefs,
            currentTheme: widget.currentTheme,
            fontSize: _fontSize,
            showTranslation: _showTranslation,
            showTafsir: _showTafsir,
            arabicFont: _arabicFont,
            reciters: _reciters,
            selectedReciter: _selectedReciter,
            onThemeChanged: widget.onThemeChanged,
            onFontSizeChanged: (value) {
              setState(() => _fontSize = value);
              widget.prefs.setDouble('font_size', value);
            },
            onShowTranslationChanged: (value) {
              setState(() => _showTranslation = value);
              widget.prefs.setBool('show_translation', value);
            },
            onShowTafsirChanged: (value) {
              setState(() => _showTafsir = value);
              widget.prefs.setBool('show_tafsir', value);
            },
            onArabicFontChanged: (value) {
              setState(() => _arabicFont = value);
              widget.prefs.setString('arabic_font', value);
            },
            onReciterChanged: (reciter) {
              setState(() => _selectedReciter = reciter);
              widget.prefs.setString('reciter_id', reciter.id);
            },
            bookmarks: _bookmarks,
            onBookmarkTap: (bookmark) {
              _openSurah(_surahs.firstWhere((s) => s.number == bookmark.surahNumber), bookmark.verseNumber);
            },
            onBookmarkDelete: (bookmark) {
              setState(() {
                _bookmarks.removeWhere((b) => 
                  b.surahNumber == bookmark.surahNumber && 
                  b.verseNumber == bookmark.verseNumber
                );
                _updateBookmarkedSurahs();
              });
              _saveBookmarks();
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.secondaryColor.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.menu_book, color: AppConstants.secondaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'القرآن الكريم',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'PRO • v1.9.2',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark),
          onPressed: () => _showBookmarksModal(),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => setState(() => _currentIndex = 5),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'القرآن',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'الأذكار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_outlined),
            activeIcon: Icon(Icons.radio),
            label: 'الراديو',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mosque_outlined),
            activeIcon: Icon(Icons.mosque),
            label: 'الصلاة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'المزيد',
          ),
        ],
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
          arabicFont: _arabicFont,
          bookmarks: _bookmarks,
          lastReadMarker: _lastReadMarker,
          scrollToAyah: scrollToAyah,
          onBookmarkToggle: (ayah) => _toggleBookmark(surah.number, ayah, surah.name),
          onLastReadMarkerSet: (ayah) => _saveLastReadMarker(surah.number, ayah),
          onPageChanged: (ayah) => _saveLastRead(surah.number, ayah),
          onReciterChanged: (reciter) {
            setState(() => _selectedReciter = reciter);
            widget.prefs.setString('reciter_id', reciter.id);
          },
        ),
      ),
    );
  }

  void _continueReading() {
    if (_lastRead != null) {
      final surah = _surahs.firstWhere((s) => s.number == _lastRead!.surah);
      _openSurah(surah, _lastRead!.ayah);
    } else if (_lastReadMarker != null) {
      final surah = _surahs.firstWhere((s) => s.number == _lastReadMarker!.surah);
      _openSurah(surah, _lastReadMarker!.ayah);
    }
  }

  void _showBookmarksModal() {
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'المفضلة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: _bookmarks.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('لا توجد آيات محفوظة', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _bookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = _bookmarks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.bookmark, color: AppConstants.accentColor),
                              title: Text(bookmark.surahName),
                              subtitle: Text('الآية ${bookmark.verseNumber}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _bookmarks.removeAt(index);
                                    _updateBookmarkedSurahs();
                                  });
                                  _saveBookmarks();
                                  Navigator.pop(context);
                                  _showBookmarksModal();
                                },
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                final surah = _surahs.firstWhere((s) => s.number == bookmark.surahNumber);
                                _openSurah(surah, bookmark.verseNumber);
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
}

// ==================== HOME TAB ====================

class HomeTab extends StatefulWidget {
  final List<Surah> surahs;
  final bool isLoading;
  final LastRead? lastRead;
  final List<Bookmark> bookmarks;
  final KhatmahGoal? khatmahGoal;
  final LastRead? lastReadMarker;
  final Function(Surah, [int?]) onSurahTap;
  final VoidCallback onContinueReading;
  final Function(KhatmahGoal?) onKhatmahGoalChanged;

  const HomeTab({
    super.key,
    required this.surahs,
    required this.isLoading,
    required this.lastRead,
    required this.bookmarks,
    required this.khatmahGoal,
    required this.lastReadMarker,
    required this.onSurahTap,
    required this.onContinueReading,
    required this.onKhatmahGoalChanged,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';
  String _currentFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

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
    }
    
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildLastReadCard(),
        ),
        SliverToBoxAdapter(
          child: _buildSearchBar(),
        ),
        SliverToBoxAdapter(
          child: _buildFilterChips(),
        ),
        SliverToBoxAdapter(
          child: _buildSurahsHeader(),
        ),
        widget.isLoading
            ? const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            : _filteredSurahs.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: Text('لا توجد نتائج')),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildSurahCard(_filteredSurahs[index]),
                      childCount: _filteredSurahs.length,
                    ),
                  ),
      ],
    );
  }

  Widget _buildLastReadCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppConstants.secondaryColor.withValues(alpha: 0.5)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.secondaryColor.withValues(alpha: 0.1),
            AppConstants.primaryColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'آخر قراءة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLastReadText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'نسخة احترافية',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'محسّنة للأجهزة المحمولة',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.lastRead != null || widget.lastReadMarker != null
                  ? widget.onContinueReading
                  : null,
              icon: const Icon(Icons.book_outlined),
              label: const Text('متابعة القراءة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث في السور...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppConstants.secondaryColor),
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('الكل', 'all', Colors.green),
          const SizedBox(width: 8),
          _buildFilterChip('مكية', 'makki', Colors.blue),
          const SizedBox(width: 8),
          _buildFilterChip('مدنية', 'madani', Colors.purple),
          const SizedBox(width: 8),
          _buildFilterChip('المفضلة', 'bookmarked', Colors.amber),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter, Color color) {
    final isActive = _currentFilter == filter;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isActive,
      onSelected: (selected) {
        setState(() => _currentFilter = selected ? filter : 'all');
      },
      selectedColor: AppConstants.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppConstants.primaryColor,
      side: BorderSide(
        color: isActive ? AppConstants.primaryColor : Colors.grey.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildSurahsHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'السور',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${_filteredSurahs.length} سورة',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(Surah surah) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF22c55e),
                Color(0xFF06b6d4),
                Color(0xFF3b82f6),
                Color(0xFF8b5cf6),
              ],
            ),
          ),
          child: Center(
            child: Text(
              '${surah.number}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          surah.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          surah.englishNameTranslation,
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${surah.numberOfAyahs} آية',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: surah.isMakki
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    surah.isMakki ? 'مكية' : 'مدنية',
                    style: TextStyle(
                      fontSize: 10,
                      color: surah.isMakki ? Colors.blue : Colors.purple,
                    ),
                  ),
                ),
                if (surah.isBookmarked) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.bookmark, size: 16, color: AppConstants.accentColor),
                ],
              ],
            ),
          ],
        ),
        onTap: () => widget.onSurahTap(surah),
      ),
    );
  }
}

// ==================== QURAN NAVIGATION TAB ====================

class QuranNavigationTab extends StatelessWidget {
  final List<Surah> surahs;
  final KhatmahGoal? khatmahGoal;
  final LastRead? lastReadMarker;
  final Function(Surah, [int?]) onSurahTap;
  final Function(KhatmahGoal?) onKhatmahGoalChanged;

  const QuranNavigationTab({
    super.key,
    required this.surahs,
    required this.khatmahGoal,
    required this.lastReadMarker,
    required this.onSurahTap,
    required this.onKhatmahGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'تصفح القرآن',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildKhatmahCard(context),
        const SizedBox(height: 24),
        _buildNavigationOption(
          context,
          icon: Icons.list_alt,
          title: 'حسب السورة',
          subtitle: 'تصفح جميع السور',
          color: AppConstants.secondaryColor,
          enabled: true,
          onTap: () {},
        ),
        _buildNavigationOption(
          context,
          icon: Icons.book,
          title: 'حسب الجزء',
          subtitle: 'قريباً',
          color: Colors.grey,
          enabled: false,
        ),
        _buildNavigationOption(
          context,
          icon: Icons.description,
          title: 'حسب الصفحة',
          subtitle: 'قريباً',
          color: Colors.grey,
          enabled: false,
        ),
        _buildNavigationOption(
          context,
          icon: Icons.star_outline,
          title: 'حسب الحزب',
          subtitle: 'قريباً',
          color: Colors.grey,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildKhatmahCard(BuildContext context) {
    if (khatmahGoal == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'لا يوجد هدف ختمة حالي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showKhatmahGoalDialog(context),
                icon: const Icon(Icons.flag),
                label: const Text('هدف ختمة جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final goal = khatmahGoal!;
    final totalUnits = goal.end - goal.start + 1;
    final completedUnits = lastReadMarker != null 
        ? (lastReadMarker!.surah - goal.start).clamp(0, totalUnits)
        : 0;
    final progressPercent = totalUnits > 0 ? (completedUnits / totalUnits) * 100 : 0.0;
    final dailyWird = totalUnits / goal.duration;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'هدف الختمة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showKhatmahGoalDialog(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => onKhatmahGoalChanged(null),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'من سورة ${goal.start} إلى سورة ${goal.end}',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الورد اليومي:', style: TextStyle(fontSize: 13)),
                    Text(
                      '${dailyWird.toStringAsFixed(1)} سورة',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('المتبقي:', style: TextStyle(fontSize: 13)),
                    Text(
                      '${totalUnits - completedUnits} سورة',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('التقدم:', style: TextStyle(fontSize: 13)),
                Text('${progressPercent.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressPercent / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            if (lastReadMarker != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final surah = surahs.firstWhere(
                      (s) => s.number == lastReadMarker!.surah,
                      orElse: () => surahs.first,
                    );
                    onSurahTap(surah, lastReadMarker!.ayah);
                  },
                  icon: const Icon(Icons.book_outlined),
                  label: Text(
                    'متابعة القراءة (${surahs.firstWhere((s) => s.number == lastReadMarker!.surah, orElse: () => surahs.first).name} - الآية ${lastReadMarker!.ayah})',
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showKhatmahGoalDialog(BuildContext context) {
    int startSurah = khatmahGoal?.start ?? 1;
    int endSurah = khatmahGoal?.end ?? 114;
    int duration = khatmahGoal?.duration ?? 30;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تحديد هدف الختمة'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('سورة البداية'),
                DropdownButton<int>(
                  value: startSurah,
                  isExpanded: true,
                  items: surahs.map((s) => DropdownMenuItem(
                    value: s.number,
                    child: Text('${s.number} - ${s.name}'),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() => startSurah = value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text('سورة النهاية'),
                DropdownButton<int>(
                  value: endSurah,
                  isExpanded: true,
                  items: surahs.map((s) => DropdownMenuItem(
                    value: s.number,
                    child: Text('${s.number} - ${s.name}'),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() => endSurah = value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text('المدة (أيام)'),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: duration.toString()),
                  onChanged: (value) {
                    duration = int.tryParse(value) ?? 30;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (startSurah > endSurah) {
                  final temp = startSurah;
                  startSurah = endSurah;
                  endSurah = temp;
                }
                onKhatmahGoalChanged(KhatmahGoal(
                  type: 'surah',
                  start: startSurah,
                  end: endSurah,
                  duration: duration,
                  startDate: DateTime.now(),
                ));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon, color: enabled ? color : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: enabled ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: enabled ? Colors.grey[500] : Colors.grey[700],
          ),
        ),
        trailing: enabled
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        onTap: enabled ? onTap : null,
      ),
    );
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد أذكار', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الأذكار',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final colors = [
              Colors.orange,
              Colors.indigo,
              Colors.purple,
              Colors.teal,
              Colors.green,
              Colors.red,
              Colors.blue,
              Colors.amber,
            ];
            final color = colors[index % colors.length];
            
            return _buildCategoryCard(category, color);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(AdhkarCategory category, Color color) {
    return InkWell(
      onTap: () => _openAdhkarCategory(category),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.7),
              color,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${category.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category.items.length} ذكر',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
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
  int? _playingAdhkarId;

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
    final isPlaying = _playingAdhkarId == item.id && widget.audioService.isPlaying;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isCompleted ? Colors.green.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: () => _incrementCounter(item),
        onLongPress: () => _resetCounter(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'التكرار: ${item.count}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ),
                  if (item.audio != null)
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.stop : Icons.play_arrow,
                        color: isPlaying ? AppConstants.primaryColor : null,
                      ),
                      onPressed: () => _toggleAudio(item),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.text,
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Amiri',
                  height: 2,
                  color: isCompleted ? Colors.green : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    item.count > 0 ? '$count / ${item.count}' : '$count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              if (item.reference != null) ...[
                const SizedBox(height: 12),
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
    );
  }

  void _incrementCounter(AdhkarItem item) {
    if (item.count == 0 || (_counters[item.id] ?? 0) < item.count) {
      setState(() {
        _counters[item.id] = (_counters[item.id] ?? 0) + 1;
      });

      if (item.count > 0 && _counters[item.id] == item.count) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('أحسنت! أكملت هذا الذكر'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      }
    }
  }

  void _resetCounter(AdhkarItem item) {
    setState(() {
      _counters[item.id] = 0;
    });
  }

  void _toggleAudio(AdhkarItem item) async {
    if (_playingAdhkarId == item.id && widget.audioService.isPlaying) {
      await widget.audioService.stop();
      setState(() => _playingAdhkarId = null);
    } else {
      if (item.audio != null) {
        try {
          await widget.audioService.playAdhkar('https://www.hisnmuslim.com${item.audio}');
          setState(() => _playingAdhkarId = item.id);
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
}

// ==================== RADIO TAB ====================

class RadioTab extends StatefulWidget {
  final AudioService audioService;

  const RadioTab({super.key, required this.audioService});

  @override
  State<RadioTab> createState() => _RadioTabState();
}

class _RadioTabState extends State<RadioTab> {
  final QuranApiService _apiService = QuranApiService();
  List<RadioStation> _radios = [];
  List<LiveTvChannel> _liveTv = [];
  bool _isLoading = true;
  RadioStation? _playingRadio;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _apiService.getRadios(),
      _apiService.getLiveTv(),
    ]);

    setState(() {
      _radios = results[0] as List<RadioStation>;
      _liveTv = results[1] as List<LiveTvChannel>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الراديو',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_playingRadio != null && widget.audioService.isPlaying)
          Card(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.radio, size: 48, color: AppConstants.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    _playingRadio!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 48,
                        icon: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppConstants.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.stop, color: Colors.white),
                        ),
                        onPressed: _stopRadio,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (_radios.isEmpty)
          const Center(child: Text('لا توجد محطات راديو'))
        else
          ...List.generate(_radios.length, (index) {
            final radio = _radios[index];
            final isPlaying = _playingRadio?.id == radio.id && widget.audioService.isPlaying;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isPlaying ? AppConstants.primaryColor.withValues(alpha: 0.1) : null,
              child: ListTile(
                leading: Icon(
                  isPlaying ? Icons.radio : Icons.radio_outlined,
                  color: isPlaying ? AppConstants.primaryColor : null,
                ),
                title: Text(
                  radio.name,
                  style: TextStyle(
                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                  onPressed: () => isPlaying ? _stopRadio() : _playRadio(radio),
                ),
              ),
            );
          }),
        const SizedBox(height: 24),
        const Row(
          children: [
            Icon(Icons.live_tv, color: AppConstants.secondaryColor),
            SizedBox(width: 8),
            Text(
              'البث المباشر',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_liveTv.isEmpty)
          const Center(child: Text('لا توجد قنوات بث مباشر'))
        else
          ...List.generate(_liveTv.length, (index) {
            final tv = _liveTv[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.tv),
                title: Text(tv.name),
                trailing: const Icon(Icons.play_arrow),
                onTap: () => _openLiveTv(tv),
              ),
            );
          }),
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

  void _openLiveTv(LiveTvChannel tv) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري فتح ${tv.name}...')),
    );
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
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final position = await _service.getCurrentLocation();
      
      if (position != null) {
        final timings = await _service.getPrayerTimes(
          position.latitude,
          position.longitude,
        );
        final qibla = _service.calculateQiblaDirection(
          position.latitude,
          position.longitude,
        );

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
      setState(() {
        _error = 'خطأ في تحميل مواقيت الصلاة';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadPrayerTimes,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'أوقات الصلاة والقبلة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPrayerTimes,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          else ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: AppConstants.primaryColor),
                title: Text(_cityName),
                subtitle: Text(
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadPrayerTimes,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_timings != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _timings!.toList().map((entry) {
                      final isNext = _isNextPrayer(entry.key);
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getPrayerIcon(entry.key),
                              color: isNext ? AppConstants.primaryColor : Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                                  color: isNext ? AppConstants.primaryColor : null,
                                ),
                              ),
                            ),
                            Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isNext ? AppConstants.primaryColor : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'اتجاه القبلة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                          width: 3,
                        ),
                        gradient: RadialGradient(
                          colors: [
                            AppConstants.secondaryColor.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: (_qiblaDirection ?? 0) * pi / 180,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppConstants.secondaryColor,
                                        AppConstants.primaryColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'اتجاه القبلة: ${_qiblaDirection?.toStringAsFixed(1) ?? '--'}°',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(الدقة تعتمد على حساسات الجهاز)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isNextPrayer(String prayerName) {
    return prayerName == 'الظهر';
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return Icons.nightlight_round;
      case 'الشروق':
        return Icons.wb_twilight;
      case 'الظهر':
        return Icons.wb_sunny;
      case 'العصر':
        return Icons.sunny_snowing;
      case 'المغرب':
        return Icons.wb_twilight;
      case 'العشاء':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}

// ==================== MORE TAB (SETTINGS) ====================

class MoreTab extends StatelessWidget {
  final SharedPreferences prefs;
  final String currentTheme;
  final double fontSize;
  final bool showTranslation;
  final bool showTafsir;
  final String arabicFont;
  final List<Reciter> reciters;
  final Reciter? selectedReciter;
  final Function(String) onThemeChanged;
  final Function(double) onFontSizeChanged;
  final Function(bool) onShowTranslationChanged;
  final Function(bool) onShowTafsirChanged;
  final Function(String) onArabicFontChanged;
  final Function(Reciter) onReciterChanged;
  final List<Bookmark> bookmarks;
  final Function(Bookmark) onBookmarkTap;
  final Function(Bookmark) onBookmarkDelete;

  const MoreTab({
    super.key,
    required this.prefs,
    required this.currentTheme,
    required this.fontSize,
    required this.showTranslation,
    required this.showTafsir,
    required this.arabicFont,
    required this.reciters,
    required this.selectedReciter,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onShowTranslationChanged,
    required this.onShowTafsirChanged,
    required this.onArabicFontChanged,
    required this.onReciterChanged,
    required this.bookmarks,
    required this.onBookmarkTap,
    required this.onBookmarkDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الإعدادات',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('المظهر'),
        Card(
          child: Column(
            children: [
              _buildThemeOption(context, 'داكن', 'dark'),
              _buildThemeOption(context, 'فاتح', 'light'),
              _buildThemeOption(context, 'بني داكن', 'sepia'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('القراءة'),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('حجم الخط'),
                subtitle: Slider(
                  value: fontSize,
                  min: 16,
                  max: 40,
                  divisions: 12,
                  label: fontSize.round().toString(),
                  onChanged: onFontSizeChanged,
                ),
              ),
              ListTile(
                title: const Text('خط النص العربي'),
                trailing: DropdownButton<String>(
                  value: arabicFont,
                  items: const [
                    DropdownMenuItem(value: 'naskh', child: Text('Noto Naskh')),
                    DropdownMenuItem(value: 'amiri', child: Text('Amiri')),
                  ],
                  onChanged: (value) => onArabicFontChanged(value!),
                ),
              ),
              SwitchListTile(
                title: const Text('إظهار الترجمة'),
                value: showTranslation,
                onChanged: onShowTranslationChanged,
              ),
              SwitchListTile(
                title: const Text('إظهار التفسير'),
                value: showTafsir,
                onChanged: onShowTafsirChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('القارئ الافتراضي'),
        Card(
          child: ListTile(
            title: Text(selectedReciter?.name ?? 'اختر قارئ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showReciterPicker(context),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('حول التطبيق'),
        Card(
          child: Column(
            children: [
              const ListTile(
                title: Text('الإصدار'),
                trailing: Text('1.9.2 PRO'),
              ),
              const ListTile(
                title: Text('المطور'),
                trailing: Text('محمد إبراهيم عبدالله'),
              ),
              ListTile(
                title: const Text('تقييم التطبيق'),
                trailing: const Icon(Icons.star, color: Colors.amber),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شكراً لك!')),
                  );
                },
              ),
              ListTile(
                title: const Text('مشاركة التطبيق'),
                trailing: const Icon(Icons.share),
                onTap: () {
                  Share.share('تطبيق القرآن الكريم - أفضل تطبيق لقراءة القرآن');
                },
              ),
              ListTile(
                title: const Text('دعاء للمطور'),
                trailing: const Icon(Icons.favorite, color: Colors.red),
                onTap: () => _showDevPrayerDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String label, String value) {
    final isSelected = currentTheme == value;
    return ListTile(
      leading: Radio<String>(
        value: value,
        groupValue: currentTheme,
        onChanged: (v) => onThemeChanged(v!),
      ),
      title: Text(label),
      onTap: () => onThemeChanged(value),
      trailing: isSelected ? const Icon(Icons.check, color: AppConstants.primaryColor) : null,
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'اختر القارئ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = reciters[index];
                    final isSelected = selectedReciter?.id == reciter.id;
                    return ListTile(
                      leading: Radio<String>(
                        value: reciter.id,
                        groupValue: selectedReciter?.id,
                        onChanged: (value) {
                          onReciterChanged(reciter);
                          Navigator.pop(context);
                        },
                      ),
                      title: Text(reciter.name),
                      trailing: isSelected ? const Icon(Icons.check, color: AppConstants.primaryColor) : null,
                      onTap: () {
                        onReciterChanged(reciter);
                        Navigator.pop(context);
                      },
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

  void _showDevPrayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.favorite, color: AppConstants.primaryColor),
            SizedBox(width: 8),
            Text('دعوة للمطور'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volunteer_activism, size: 64, color: AppConstants.primaryColor),
            SizedBox(height: 16),
            Text(
              'نسألكم الدعاء للمطور (محمد إبراهيم عبدالله) بالتوفيق والسداد وأن يجعل هذا العمل في ميزان حسناته.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.8),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('إغلاق'),
          ),
        ],
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
  final String arabicFont;
  final List<Bookmark> bookmarks;
  final LastRead? lastReadMarker;
  final int? scrollToAyah;
  final Function(int) onBookmarkToggle;
  final Function(int) onLastReadMarkerSet;
  final Function(int) onPageChanged;
  final Function(Reciter) onReciterChanged;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    required this.audioService,
    required this.reciters,
    required this.selectedReciter,
    required this.fontSize,
    required this.showTranslation,
    required this.arabicFont,
    required this.bookmarks,
    required this.lastReadMarker,
    required this.scrollToAyah,
    required this.onBookmarkToggle,
    required this.onLastReadMarkerSet,
    required this.onPageChanged,
    required this.onReciterChanged,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranApiService _apiService = QuranApiService();
  List<Verse> _verses = [];
  bool _isLoading = true;
  bool _isAudioControlsVisible = false;
  Reciter? _currentReciter;
  bool _isPlaying = false;
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
      if (mounted) {
        setState(() => _isPlaying = state.playing);
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.audioService.stop();
            Navigator.pop(context);
          },
        ),
        title: Text(widget.surah.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: Icon(
              _isAudioControlsVisible ? Icons.headphones : Icons.headphones_outlined,
              color: _isAudioControlsVisible ? AppConstants.primaryColor : null,
            ),
            onPressed: () {
              setState(() => _isAudioControlsVisible = !_isAudioControlsVisible);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSurahHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _verses.length,
                    itemBuilder: (context, index) {
                      final verse = _verses[index];
                      return _buildVerseCard(verse);
                    },
                  ),
          ),
          if (_isAudioControlsVisible) _buildAudioControls(),
        ],
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          if (widget.surah.number != 9 && widget.surah.number != 1)
            const Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Text(
            '${widget.surah.englishName} - ${widget.surah.numberOfAyahs} آية',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(Verse verse) {
    final isBookmarked = widget.bookmarks.any(
      (b) => b.surahNumber == widget.surah.number && b.verseNumber == verse.numberInSurah,
    );
    final isLastReadMarker = widget.lastReadMarker?.surah == widget.surah.number &&
        widget.lastReadMarker?.ayah == verse.numberInSurah;

    String verseText = verse.text;
    if (verse.numberInSurah == 1 && widget.surah.number != 1 && widget.surah.number != 9) {
      verseText = verseText.replaceFirst(
        RegExp(r'^(بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ|بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ)\s*'),
        '',
      );
    }

    return Card(
      key: _verseKeys[verse.numberInSurah],
      margin: const EdgeInsets.only(bottom: 12),
      color: isLastReadMarker
          ? Colors.amber.withValues(alpha: 0.1)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLastReadMarker
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF22c55e),
                        Color(0xFF06b6d4),
                        Color(0xFF3b82f6),
                        Color(0xFF8b5cf6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${verse.numberInSurah}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.push_pin,
                    size: 20,
                    color: isLastReadMarker ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => widget.onLastReadMarkerSet(verse.numberInSurah),
                  tooltip: 'تحديد كموضع قراءة',
                ),
                IconButton(
                  icon: Icon(
                    Icons.bookmark,
                    size: 20,
                    color: isBookmarked ? AppConstants.accentColor : Colors.grey,
                  ),
                  onPressed: () => widget.onBookmarkToggle(verse.numberInSurah),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyVerse(verse, verseText),
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  onPressed: () => _shareVerse(verse, verseText),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              verseText,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontFamily: widget.arabicFont == 'amiri' ? 'Amiri' : null,
                height: 2.2,
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
            if (widget.showTranslation && verse.translation != null) ...[
              const Divider(height: 24),
              Text(
                verse.translation!,
                style: TextStyle(
                  fontSize: widget.fontSize - 6,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'الجزء ${verse.juz} - الصفحة ${verse.page}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            iconSize: 48,
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            onPressed: _togglePlayPause,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
                    onChanged: (value) {
                      widget.audioService.seek(Duration(seconds: value.toInt()));
                    },
                    activeColor: AppConstants.primaryColor,
                  ),
                ),
                Row(
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
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showReciterPicker,
          ),
        ],
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
        final url = _apiService.getSurahAudioUrl(_currentReciter!, widget.surah.number);
        try {
          await widget.audioService.playSurah(url);
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'اختر القارئ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = widget.reciters[index];
                    final isAvailable = reciter.surahList.contains(widget.surah.number);
                    final isSelected = _currentReciter?.id == reciter.id;
                    return ListTile(
                      leading: Radio<String>(
                        value: reciter.id,
                        groupValue: _currentReciter?.id,
                        onChanged: isAvailable
                            ? (value) {
                                setState(() => _currentReciter = reciter);
                                widget.onReciterChanged(reciter);
                                Navigator.pop(context);
                                if (_isPlaying) {
                                  _togglePlayPause();
                                  _togglePlayPause();
                                }
                              }
                            : null,
                      ),
                      title: Text(
                        reciter.name,
                        style: TextStyle(
                          color: isAvailable ? null : Colors.grey,
                        ),
                      ),
                      subtitle: isAvailable ? null : const Text('غير متوفر لهذه السورة'),
                      trailing: isSelected ? const Icon(Icons.check, color: AppConstants.primaryColor) : null,
                      onTap: isAvailable
                          ? () {
                              setState(() => _currentReciter = reciter);
                              widget.onReciterChanged(reciter);
                              Navigator.pop(context);
                              if (_isPlaying) {
                                _togglePlayPause();
                                _togglePlayPause();
                              }
                            }
                          : null,
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات السورة'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('يمكنك تغيير الإعدادات من صفحة المزيد'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _copyVerse(Verse verse, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم النسخ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppConstants.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _shareVerse(Verse verse, String text) {
    Share.share(
      '${widget.surah.name} - الآية ${verse.numberInSurah}\n\n$text\n\n(القرآن الكريم)',
    );
  }
}