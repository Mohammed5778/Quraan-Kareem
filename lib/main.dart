// main.dart - تطبيق القرآن الكريم الذكي الشامل
// Quran Smart Pro v3.0.0 - Complete Offline Experience

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:share_plus/share_plus.dart';

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                              التطبيق الرئيسي                                  ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // قفل الاتجاه للوضع العمودي
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // تخصيص شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
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
  late ThemeMode _themeMode;
  bool _setupComplete = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final isDark = widget.prefs.getBool('dark_mode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _setupComplete = widget.prefs.getBool('setup_complete') ?? false;
    setState(() {});
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    widget.prefs.setBool('dark_mode', _themeMode == ThemeMode.dark);
  }

  void _completeSetup() {
    widget.prefs.setBool('setup_complete', true);
    setState(() => _setupComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'القرآن الكريم',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _setupComplete
          ? MainScreen(
              prefs: widget.prefs,
              onToggleTheme: _toggleTheme,
              isDarkMode: _themeMode == ThemeMode.dark,
            )
          : SetupScreen(
              prefs: widget.prefs,
              onComplete: _completeSetup,
            ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                              الثوابت والألوان                                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class AppColors {
  // الألوان الرئيسية
  static const Color primary = Color(0xFF00D9A5);
  static const Color primaryDark = Color(0xFF00B386);
  static const Color secondary = Color(0xFF6C63FF);
  static const Color accent = Color(0xFFFF6B9D);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFFFA000);
  
  // ألوان الخلفية الداكنة
  static const Color bgDark = Color(0xFF0A0E21);
  static const Color cardDark = Color(0xFF1D1F33);
  static const Color surfaceDark = Color(0xFF161A2C);
  
  // ألوان الخلفية الفاتحة
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // التدرجات
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D9A5), Color(0xFF00B386)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF4777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Amiri',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardDark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Amiri',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                                 النماذج                                       ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

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
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'name': name,
    'englishName': englishName,
    'englishNameTranslation': englishNameTranslation,
    'numberOfAyahs': numberOfAyahs,
    'revelationType': revelationType,
  };

  bool get isMakki => revelationType == 'Meccan';
}

class Ayah {
  final int number;
  final int numberInSurah;
  final String text;
  final int juz;
  final int page;
  final String? audio;
  String? translation;

  Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.juz,
    required this.page,
    this.audio,
    this.translation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] ?? 0,
      numberInSurah: json['numberInSurah'] ?? 0,
      text: json['text'] ?? '',
      juz: json['juz'] ?? 1,
      page: json['page'] ?? 1,
      audio: json['audio'],
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'numberInSurah': numberInSurah,
    'text': text,
    'juz': juz,
    'page': page,
    'audio': audio,
    'translation': translation,
  };
}

class Reciter {
  final String id;
  final String name;
  final String server;
  final String? rewaya;
  final List<int> surahList;

  Reciter({
    required this.id,
    required this.name,
    required this.server,
    this.rewaya,
    this.surahList = const [],
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    final moshaf = json['moshaf'] as List?;
    String server = '';
    String? rewaya;
    List<int> surahList = [];
    
    if (moshaf != null && moshaf.isNotEmpty) {
      server = moshaf[0]['server'] ?? '';
      rewaya = moshaf[0]['name'];
      final surahStr = moshaf[0]['surah_list'] as String?;
      if (surahStr != null) {
        surahList = surahStr.split(',').map((s) => int.tryParse(s) ?? 0).toList();
      }
    }

    return Reciter(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      server: server,
      rewaya: rewaya,
      surahList: surahList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'server': server,
    'rewaya': rewaya,
    'surahList': surahList,
  };

  factory Reciter.fromLocalJson(Map<String, dynamic> json) => Reciter(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    server: json['server'] ?? '',
    rewaya: json['rewaya'],
    surahList: (json['surahList'] as List?)?.cast<int>() ?? [],
  );

  String getAudioUrl(int surahNumber) {
    return '$server${surahNumber.toString().padLeft(3, '0')}.mp3';
  }
}

class Bookmark {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final DateTime createdAt;

  Bookmark({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'surahName': surahName,
    'ayahNumber': ayahNumber,
    'ayahText': ayahText,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    surahNumber: json['surahNumber'],
    surahName: json['surahName'],
    ayahNumber: json['ayahNumber'],
    ayahText: json['ayahText'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class DownloadedAudio {
  final int surahNumber;
  final String surahName;
  final String reciterId;
  final String reciterName;
  final String filePath;
  final DateTime downloadedAt;
  final int fileSize;

  DownloadedAudio({
    required this.surahNumber,
    required this.surahName,
    required this.reciterId,
    required this.reciterName,
    required this.filePath,
    required this.downloadedAt,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'surahName': surahName,
    'reciterId': reciterId,
    'reciterName': reciterName,
    'filePath': filePath,
    'downloadedAt': downloadedAt.toIso8601String(),
    'fileSize': fileSize,
  };

  factory DownloadedAudio.fromJson(Map<String, dynamic> json) => DownloadedAudio(
    surahNumber: json['surahNumber'],
    surahName: json['surahName'] ?? '',
    reciterId: json['reciterId'],
    reciterName: json['reciterName'],
    filePath: json['filePath'],
    downloadedAt: DateTime.parse(json['downloadedAt']),
    fileSize: json['fileSize'] ?? 0,
  );
}

class LastRead {
  final int surahNumber;
  final int ayahNumber;
  final DateTime timestamp;

  LastRead({
    required this.surahNumber,
    required this.ayahNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LastRead.fromJson(Map<String, dynamic> json) => LastRead(
    surahNumber: json['surahNumber'],
    ayahNumber: json['ayahNumber'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class AdhkarCategory {
  final int id;
  final String name;
  final List<Dhikr> items;
  final IconData icon;
  final List<Color> colors;

  AdhkarCategory({
    required this.id,
    required this.name,
    required this.items,
    required this.icon,
    required this.colors,
  });
}

class Dhikr {
  final int id;
  final String text;
  final int count;
  final String? reference;

  Dhikr({
    required this.id,
    required this.text,
    required this.count,
    this.reference,
  });
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                             خدمات البيانات                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class DataService {
  static const String _quranApi = 'https://api.alquran.cloud/v1';
  static const String _recitersApi = 'https://mp3quran.net/api/v3/reciters?language=ar';
  
  final SharedPreferences prefs;
  late Directory _appDir;
  
  DataService(this.prefs);
  
  Future<void> init() async {
    _appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${_appDir.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
  }

  // ======= API Calls =======
  
  Future<List<Surah>> fetchSurahs() async {
    try {
      final response = await http.get(Uri.parse('$_quranApi/surah'))
          .timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahsJson = data['data'];
        return surahsJson.map((j) => Surah.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching surahs: $e');
    }
    return [];
  }

  Future<List<Ayah>> fetchAyahs(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_quranApi/surah/$surahNumber/ar.alafasy'),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ayahsJson = data['data']['ayahs'];
        return ayahsJson.map((j) => Ayah.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching ayahs: $e');
    }
    return [];
  }

  Future<List<Ayah>> fetchAyahsWithTranslation(int surahNumber, String edition) async {
    try {
      final response = await http.get(
        Uri.parse('$_quranApi/surah/$surahNumber/editions/quran-uthmani,$edition'),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> editions = data['data'];
        
        final arabicAyahs = editions[0]['ayahs'] as List;
        final translationAyahs = editions.length > 1 ? editions[1]['ayahs'] as List : [];
        
        return List.generate(arabicAyahs.length, (i) {
          final ayah = Ayah.fromJson(arabicAyahs[i]);
          if (i < translationAyahs.length) {
            ayah.translation = translationAyahs[i]['text'];
          }
          return ayah;
        });
      }
    } catch (e) {
      debugPrint('Error fetching ayahs with translation: $e');
    }
    return [];
  }

  Future<List<Reciter>> fetchReciters() async {
    try {
      final response = await http.get(Uri.parse(_recitersApi))
          .timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recitersJson = data['reciters'] ?? [];
        return recitersJson
            .map((j) => Reciter.fromJson(j))
            .where((r) => r.server.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching reciters: $e');
    }
    return [];
  }

  // ======= Local Storage =======
  
  Future<void> saveSurahs(List<Surah> surahs) async {
    final jsonList = surahs.map((s) => s.toJson()).toList();
    await prefs.setString('cached_surahs', json.encode(jsonList));
  }

  List<Surah> getSurahs() {
    final jsonStr = prefs.getString('cached_surahs');
    if (jsonStr == null) return [];
    final jsonList = json.decode(jsonStr) as List;
    return jsonList.map((j) => Surah.fromJson(j)).toList();
  }

  Future<void> saveAyahs(int surahNumber, List<Ayah> ayahs) async {
    final jsonList = ayahs.map((a) => a.toJson()).toList();
    await prefs.setString('ayahs_$surahNumber', json.encode(jsonList));
  }

  List<Ayah> getAyahs(int surahNumber) {
    final jsonStr = prefs.getString('ayahs_$surahNumber');
    if (jsonStr == null) return [];
    final jsonList = json.decode(jsonStr) as List;
    return jsonList.map((j) => Ayah.fromJson(j)).toList();
  }

  Future<void> saveReciters(List<Reciter> reciters) async {
    final jsonList = reciters.map((r) => r.toJson()).toList();
    await prefs.setString('cached_reciters', json.encode(jsonList));
  }

  List<Reciter> getReciters() {
    final jsonStr = prefs.getString('cached_reciters');
    if (jsonStr == null) return [];
    final jsonList = json.decode(jsonStr) as List;
    return jsonList.map((j) => Reciter.fromLocalJson(j)).toList();
  }

  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    final jsonList = bookmarks.map((b) => b.toJson()).toList();
    await prefs.setString('bookmarks', json.encode(jsonList));
  }

  List<Bookmark> getBookmarks() {
    final jsonStr = prefs.getString('bookmarks');
    if (jsonStr == null) return [];
    final jsonList = json.decode(jsonStr) as List;
    return jsonList.map((j) => Bookmark.fromJson(j)).toList();
  }

  Future<void> saveDownloads(List<DownloadedAudio> downloads) async {
    final jsonList = downloads.map((d) => d.toJson()).toList();
    await prefs.setString('downloads', json.encode(jsonList));
  }

  List<DownloadedAudio> getDownloads() {
    final jsonStr = prefs.getString('downloads');
    if (jsonStr == null) return [];
    final jsonList = json.decode(jsonStr) as List;
    return jsonList.map((j) => DownloadedAudio.fromJson(j)).toList();
  }

  Future<void> saveLastRead(LastRead lastRead) async {
    await prefs.setString('last_read', json.encode(lastRead.toJson()));
  }

  LastRead? getLastRead() {
    final jsonStr = prefs.getString('last_read');
    if (jsonStr == null) return null;
    return LastRead.fromJson(json.decode(jsonStr));
  }

  // ======= Download Audio =======
  
  Future<String?> downloadAudio({
    required int surahNumber,
    required Reciter reciter,
    required Function(double) onProgress,
  }) async {
    try {
      final url = reciter.getAudioUrl(surahNumber);
      final filePath = '${_appDir.path}/audio/${reciter.id}_${surahNumber.toString().padLeft(3, '0')}.mp3';
      
      final file = File(filePath);
      if (await file.exists()) return filePath;
      
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      
      final contentLength = response.contentLength ?? 0;
      int receivedBytes = 0;
      
      final sink = file.openWrite();
      
      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          onProgress(receivedBytes / contentLength);
        }
      }
      
      await sink.close();
      return filePath;
    } catch (e) {
      debugPrint('Error downloading audio: $e');
      return null;
    }
  }

  Future<void> deleteAudio(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting audio: $e');
    }
  }

  // ======= Settings =======
  
  double get fontSize => prefs.getDouble('font_size') ?? 26.0;
  set fontSize(double value) => prefs.setDouble('font_size', value);
  
  String? get selectedReciterId => prefs.getString('reciter_id');
  set selectedReciterId(String? value) {
    if (value != null) prefs.setString('reciter_id', value);
  }

  bool get showTranslation => prefs.getBool('show_translation') ?? false;
  set showTranslation(bool value) => prefs.setBool('show_translation', value);
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                             خدمة الصوت                                        ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  
  bool _isPlaying = false;
  String? _currentSource;
  
  bool get isPlaying => _isPlaying;
  String? get currentSource => _currentSource;
  AudioPlayer get player => _player;
  
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Duration? get duration => _player.duration;
  Duration get position => _player.position;

  Future<void> play(String source, {bool isFile = false}) async {
    try {
      _currentSource = source;
      if (isFile) {
        await _player.setFilePath(source);
      } else {
        await _player.setUrl(source);
      }
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      _currentSource = null;
      debugPrint('Error playing audio: $e');
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
    _currentSource = null;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  void dispose() {
    _player.dispose();
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                           بيانات الأذكار                                      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class AdhkarData {
  static List<AdhkarCategory> getCategories() {
    return [
      AdhkarCategory(
        id: 1,
        name: 'أذكار الصباح',
        icon: Icons.wb_sunny_rounded,
        colors: [const Color(0xFFFF9800), const Color(0xFFFF5722)],
        items: [
          Dhikr(id: 1, text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', count: 1, reference: 'أبو داود'),
          Dhikr(id: 2, text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ', count: 1, reference: 'الترمذي'),
          Dhikr(id: 3, text: 'اللَّهُمَّ أَنْتَ رَبِّي لّا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِر لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ', count: 1, reference: 'البخاري'),
          Dhikr(id: 4, text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ', count: 100, reference: 'مسلم'),
          Dhikr(id: 5, text: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', count: 10, reference: 'متفق عليه'),
          Dhikr(id: 6, text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ', count: 3, reference: 'ابن ماجه'),
          Dhikr(id: 7, text: 'بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ', count: 3, reference: 'الترمذي'),
        ],
      ),
      AdhkarCategory(
        id: 2,
        name: 'أذكار المساء',
        icon: Icons.nights_stay_rounded,
        colors: [const Color(0xFF5C6BC0), const Color(0xFF3949AB)],
        items: [
          Dhikr(id: 8, text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ للهِ، وَالْحَمْدُ للهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', count: 1, reference: 'أبو داود'),
          Dhikr(id: 9, text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ', count: 1, reference: 'الترمذي'),
          Dhikr(id: 10, text: 'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ', count: 1, reference: 'أبو داود'),
          Dhikr(id: 11, text: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ', count: 3, reference: 'أبو داود'),
          Dhikr(id: 12, text: 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ', count: 3, reference: 'مسلم'),
        ],
      ),
      AdhkarCategory(
        id: 3,
        name: 'أذكار النوم',
        icon: Icons.bedtime_rounded,
        colors: [const Color(0xFF7E57C2), const Color(0xFF512DA8)],
        items: [
          Dhikr(id: 13, text: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', count: 1, reference: 'البخاري'),
          Dhikr(id: 14, text: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ', count: 3, reference: 'أبو داود'),
          Dhikr(id: 15, text: 'سُبْحَانَ اللهِ', count: 33, reference: 'متفق عليه'),
          Dhikr(id: 16, text: 'الْحَمْدُ للهِ', count: 33, reference: 'متفق عليه'),
          Dhikr(id: 17, text: 'اللهُ أَكْبَرُ', count: 34, reference: 'متفق عليه'),
          Dhikr(id: 18, text: 'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ', count: 1, reference: 'متفق عليه'),
        ],
      ),
      AdhkarCategory(
        id: 4,
        name: 'أذكار الصلاة',
        icon: Icons.mosque_rounded,
        colors: [const Color(0xFF26A69A), const Color(0xFF00897B)],
        items: [
          Dhikr(id: 19, text: 'أَسْتَغْفِرُ اللهَ', count: 3, reference: 'مسلم'),
          Dhikr(id: 20, text: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ', count: 1, reference: 'مسلم'),
          Dhikr(id: 21, text: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ', count: 1, reference: 'متفق عليه'),
          Dhikr(id: 22, text: 'سُبْحَانَ اللهِ', count: 33, reference: 'مسلم'),
          Dhikr(id: 23, text: 'الْحَمْدُ للهِ', count: 33, reference: 'مسلم'),
          Dhikr(id: 24, text: 'اللهُ أَكْبَرُ', count: 33, reference: 'مسلم'),
        ],
      ),
      AdhkarCategory(
        id: 5,
        name: 'أدعية متنوعة',
        icon: Icons.favorite_rounded,
        colors: [const Color(0xFFEC407A), const Color(0xFFD81B60)],
        items: [
          Dhikr(id: 25, text: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ', count: 1, reference: 'القرآن الكريم'),
          Dhikr(id: 26, text: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ', count: 1, reference: 'البخاري'),
          Dhikr(id: 27, text: 'اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي، وَاجْعَلِ الْحَيَاةَ زِيَادَةً لِي فِي كُلِّ خَيْرٍ، وَاجْعَلِ الْمَوْتَ رَاحَةً لِي مِنْ كُلِّ شَرٍّ', count: 1, reference: 'مسلم'),
          Dhikr(id: 28, text: 'اللَّهُمَّ اغْفِرْ لِي خَطِيئَتِي وَجَهْلِي، وَإِسْرَافِي فِي أَمْرِي، وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي', count: 1, reference: 'متفق عليه'),
          Dhikr(id: 29, text: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ', count: 100, reference: 'الترمذي'),
        ],
      ),
      AdhkarCategory(
        id: 6,
        name: 'الاستغفار',
        icon: Icons.auto_fix_high_rounded,
        colors: [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
        items: [
          Dhikr(id: 30, text: 'أَسْتَغْفِرُ اللهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ', count: 3, reference: 'الترمذي'),
          Dhikr(id: 31, text: 'أَسْتَغْفِرُ اللهَ وَأَتُوبُ إِلَيْهِ', count: 100, reference: 'متفق عليه'),
          Dhikr(id: 32, text: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الْغَفُورُ', count: 100, reference: 'الترمذي'),
          Dhikr(id: 33, text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ أَسْتَغْفِرُ اللهَ وَأَتُوبُ إِلَيْهِ', count: 100),
        ],
      ),
    ];
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                           شاشة الإعداد الأولي                                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class SetupScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onComplete;

  const SetupScreen({
    super.key,
    required this.prefs,
    required this.onComplete,
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isLoading = false;
  double _progress = 0.0;
  String _statusText = '';
  
  late DataService _dataService;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _dataService = DataService(widget.prefs);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.bgDark,
              AppColors.surfaceDark,
              AppColors.primaryDark.withAlpha(50),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildDownloadStep();
      case 2:
        return _buildCompleteStep();
      default:
        return _buildWelcomeStep();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      children: [
        const Spacer(),
        
        // الشعار
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(100),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 70,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 48),
        
        // العنوان
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            'القرآن الكريم',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // الوصف
        Text(
          'تطبيق شامل للقرآن الكريم والأذكار\nيعمل بدون إنترنت',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
        // المميزات
        _buildFeatureItem(Icons.wifi_off_rounded, 'يعمل بدون إنترنت'),
        _buildFeatureItem(Icons.headphones_rounded, 'استمع لأشهر القراء'),
        _buildFeatureItem(Icons.bookmark_rounded, 'احفظ الآيات المفضلة'),
        _buildFeatureItem(Icons.favorite_rounded, 'الأذكار والأدعية'),
        
        const Spacer(),
        
        // زر البدء
        _buildGradientButton(
          text: 'ابدأ الآن',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => setState(() => _currentStep = 1),
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadStep() {
    return Column(
      children: [
        const Spacer(),
        
        // أيقونة التحميل
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withAlpha(100),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Icon(
              _isLoading ? Icons.downloading_rounded : Icons.cloud_download_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        Text(
          _isLoading ? 'جاري التحميل...' : 'تحميل البيانات',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          _isLoading 
              ? _statusText
              : 'سيتم تحميل بيانات التطبيق\nللعمل بدون إنترنت',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (_isLoading) ...[
          const SizedBox(height: 40),
          
          // شريط التقدم
          Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(50),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '${(_progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
        
        const Spacer(),
        
        if (!_isLoading)
          _buildGradientButton(
            text: 'بدء التحميل',
            icon: Icons.download_rounded,
            onPressed: _startDownload,
          ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCompleteStep() {
    return Column(
      children: [
        const Spacer(),
        
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.green, Color(0xFF2E7D32)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withAlpha(100),
                blurRadius: 40,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 70,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 48),
        
        const Text(
          'تم بنجاح! 🎉',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'التطبيق جاهز للاستخدام\nاستمتع بقراءة القرآن الكريم',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[400],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const Spacer(),
        
        _buildGradientButton(
          text: 'ابدأ الاستخدام',
          icon: Icons.arrow_forward_rounded,
          onPressed: widget.onComplete,
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(100),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _isLoading = true;
      _progress = 0;
      _statusText = 'جاري التهيئة...';
    });

    try {
      await _dataService.init();
      
      // تحميل السور
      setState(() {
        _progress = 0.1;
        _statusText = 'جاري تحميل قائمة السور...';
      });
      
      final surahs = await _dataService.fetchSurahs();
      if (surahs.isNotEmpty) {
        await _dataService.saveSurahs(surahs);
      }
      
      // تحميل القراء
      setState(() {
        _progress = 0.5;
        _statusText = 'جاري تحميل قائمة القراء...';
      });
      
      final reciters = await _dataService.fetchReciters();
      if (reciters.isNotEmpty) {
        await _dataService.saveReciters(reciters);
      }
      
      setState(() {
        _progress = 1.0;
        _statusText = 'اكتمل التحميل!';
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _currentStep = 2);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusText = 'فشل التحميل';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                             الشاشة الرئيسية                                   ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class MainScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainScreen({
    super.key,
    required this.prefs,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  late DataService _dataService;
  late AudioService _audioService;
  
  List<Surah> _surahs = [];
  List<Reciter> _reciters = [];
  List<Bookmark> _bookmarks = [];
  List<DownloadedAudio> _downloads = [];
  LastRead? _lastRead;
  Reciter? _selectedReciter;
  bool _isOnline = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataService = DataService(widget.prefs);
    _audioService = AudioService();
    _initData();
  }

  Future<void> _initData() async {
    await _dataService.init();
    
    // التحقق من الاتصال
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);
    
    // تحميل البيانات المحفوظة
    _surahs = _dataService.getSurahs();
    _reciters = _dataService.getReciters();
    _bookmarks = _dataService.getBookmarks();
    _downloads = _dataService.getDownloads();
    _lastRead = _dataService.getLastRead();
    
    // تحديد القارئ المختار
    final reciterId = _dataService.selectedReciterId;
    if (reciterId != null && _reciters.isNotEmpty) {
      _selectedReciter = _reciters.firstWhere(
        (r) => r.id == reciterId,
        orElse: () => _reciters.first,
      );
    } else if (_reciters.isNotEmpty) {
      _selectedReciter = _reciters.first;
    }
    
    // تحديث حالة التحميل
    _updateDownloadStatus();
    _updateBookmarkStatus();
    
    setState(() => _isLoading = false);
    
    // تحديث البيانات من الإنترنت
    if (_isOnline) {
      _refreshData();
    }
    
    // مراقبة تغييرات الاتصال
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = !result.contains(ConnectivityResult.none);
      });
    });
  }

  Future<void> _refreshData() async {
    try {
      final surahs = await _dataService.fetchSurahs();
      if (surahs.isNotEmpty) {
        await _dataService.saveSurahs(surahs);
        setState(() => _surahs = surahs);
        _updateDownloadStatus();
        _updateBookmarkStatus();
      }
      
      final reciters = await _dataService.fetchReciters();
      if (reciters.isNotEmpty) {
        await _dataService.saveReciters(reciters);
        setState(() => _reciters = reciters);
      }
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    }
  }

  void _updateDownloadStatus() {
    for (var surah in _surahs) {
      surah.isDownloaded = _downloads.any(
        (d) => d.surahNumber == surah.number && d.reciterId == _selectedReciter?.id,
      );
    }
  }

  void _updateBookmarkStatus() {
    for (var surah in _surahs) {
      surah.isBookmarked = _bookmarks.any((b) => b.surahNumber == surah.number);
    }
  }

  void _saveLastRead(int surahNumber, int ayahNumber) {
    _lastRead = LastRead(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      timestamp: DateTime.now(),
    );
    _dataService.saveLastRead(_lastRead!);
    setState(() {});
  }

  void _toggleBookmark(int surahNumber, int ayahNumber, String surahName, String ayahText) {
    final existingIndex = _bookmarks.indexWhere(
      (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
    );
    
    setState(() {
      if (existingIndex >= 0) {
        _bookmarks.removeAt(existingIndex);
        _showSnackBar('تمت الإزالة من المفضلة', Icons.bookmark_remove);
      } else {
        _bookmarks.add(Bookmark(
          surahNumber: surahNumber,
          surahName: surahName,
          ayahNumber: ayahNumber,
          ayahText: ayahText,
          createdAt: DateTime.now(),
        ));
        _showSnackBar('تمت الإضافة للمفضلة', Icons.bookmark_add);
      }
      _updateBookmarkStatus();
    });
    _dataService.saveBookmarks(_bookmarks);
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
        backgroundColor: AppColors.primary,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _downloadSurah(Surah surah) async {
    if (_selectedReciter == null) {
      _showSnackBar('يرجى اختيار قارئ أولاً', Icons.error);
      return;
    }

    try {
      final filePath = await _dataService.downloadAudio(
        surahNumber: surah.number,
        reciter: _selectedReciter!,
        onProgress: (progress) {
          setState(() {
            surah.downloadProgress = progress;
          });
        },
      );

      if (filePath != null) {
        final download = DownloadedAudio(
          surahNumber: surah.number,
          surahName: surah.name,
          reciterId: _selectedReciter!.id,
          reciterName: _selectedReciter!.name,
          filePath: filePath,
          downloadedAt: DateTime.now(),
          fileSize: await File(filePath).length(),
        );

        setState(() {
          _downloads.add(download);
          surah.isDownloaded = true;
          surah.downloadProgress = 0.0;
        });
        _dataService.saveDownloads(_downloads);
        _showSnackBar('تم تحميل السورة بنجاح', Icons.check_circle);
      }
    } catch (e) {
      setState(() {
        surah.downloadProgress = 0.0;
      });
      _showSnackBar('فشل التحميل', Icons.error);
    }
  }

  Future<void> _deleteDownload(DownloadedAudio download) async {
    await _dataService.deleteAudio(download.filePath);
    setState(() {
      _downloads.removeWhere(
        (d) => d.surahNumber == download.surahNumber && d.reciterId == download.reciterId,
      );
      _updateDownloadStatus();
    });
    _dataService.saveDownloads(_downloads);
    _showSnackBar('تم حذف التحميل', Icons.delete);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // زخرفة الخلفية
          _buildBackgroundDecorations(),
          
          // المحتوى
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(),
              _buildQuranTab(),
              _buildAdhkarTab(),
              _buildSettingsTab(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
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
                  AppColors.primary.withAlpha(20),
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
                  AppColors.secondary.withAlpha(20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? AppColors.surfaceDark.withAlpha(250)
            : Colors.white.withAlpha(250),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'الرئيسية'),
              _buildNavItem(1, Icons.menu_book_rounded, Icons.menu_book_outlined, 'القرآن'),
              _buildNavItem(2, Icons.favorite_rounded, Icons.favorite_outline, 'الأذكار'),
              _buildNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'الإعدادات'),
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
              ? AppColors.primary.withAlpha(40)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== تبويب الرئيسية ==========
  
  Widget _buildHomeTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        // الهيدر
        SliverToBoxAdapter(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'القرآن الكريم',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'SMART PRO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isOnline 
                                  ? Colors.green.withAlpha(50)
                                  : Colors.orange.withAlpha(50),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isOnline ? Icons.wifi : Icons.wifi_off,
                                  size: 10,
                                  color: _isOnline ? Colors.green : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isOnline ? 'متصل' : 'غير متصل',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: _isOnline ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_downloads.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.download_done, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            '${_downloads.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // المحتوى
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // بطاقة آخر قراءة
              _buildLastReadCard(),
              const SizedBox(height: 20),
              
              // الوصول السريع
              _buildQuickAccessSection(),
              const SizedBox(height: 24),
              
              // السور المقترحة
              _buildSuggestedSurahsSection(),
              
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildLastReadCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(40),
            AppColors.secondary.withAlpha(25),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withAlpha(80),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 24),
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
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _lastRead != null ? _continueReading : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withAlpha(100),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'متابعة القراءة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLastReadText() {
    if (_lastRead != null && _surahs.isNotEmpty) {
      final surah = _surahs.firstWhere(
        (s) => s.number == _lastRead!.surahNumber,
        orElse: () => _surahs.first,
      );
      return '${surah.name} - الآية ${_lastRead!.ayahNumber}';
    }
    return 'لم تبدأ القراءة بعد';
  }

  void _continueReading() {
    if (_lastRead != null && _surahs.isNotEmpty) {
      final surah = _surahs.firstWhere(
        (s) => s.number == _lastRead!.surahNumber,
        orElse: () => _surahs.first,
      );
      _openSurah(surah, scrollToAyah: _lastRead!.ayahNumber);
    }
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'وصول سريع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildQuickAccessItem('الفاتحة', '1', AppColors.primaryGradient, 1)),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickAccessItem('الكهف', '18', AppColors.blueGradient, 18)),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickAccessItem('يس', '36', AppColors.purpleGradient, 36)),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickAccessItem('الملك', '67', AppColors.orangeGradient, 67)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(String name, String number, LinearGradient gradient, int surahNumber) {
    return GestureDetector(
      onTap: () {
        if (_surahs.length >= surahNumber) {
          _openSurah(_surahs[surahNumber - 1]);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(80),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                color: Colors.white.withAlpha(230),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedSurahsSection() {
    final suggestedSurahs = <Surah>[];
    
    // إضافة آخر قراءة
    if (_lastRead != null && _surahs.isNotEmpty) {
      final surah = _surahs.firstWhere(
        (s) => s.number == _lastRead!.surahNumber,
        orElse: () => _surahs.first,
      );
      suggestedSurahs.add(surah);
    }
    
    // إضافة المفضلة
    for (var bookmark in _bookmarks.take(3)) {
      final surah = _surahs.firstWhere(
        (s) => s.number == bookmark.surahNumber,
        orElse: () => _surahs.first,
      );
      if (!suggestedSurahs.contains(surah)) {
        suggestedSurahs.add(surah);
      }
    }
    
    // إكمال القائمة
    while (suggestedSurahs.length < 4 && _surahs.length > suggestedSurahs.length) {
      final surah = _surahs[suggestedSurahs.length];
      if (!suggestedSurahs.contains(surah)) {
        suggestedSurahs.add(surah);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'السور المقترحة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...suggestedSurahs.map((surah) => _buildSurahListItem(surah)),
      ],
    );
  }

  Widget _buildSurahListItem(Surah surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${surah.numberOfAyahs} آية',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (surah.isDownloaded)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.download_done, size: 14, color: Colors.green),
              ),
            if (surah.isBookmarked)
              Icon(Icons.bookmark, size: 16, color: Colors.amber[600]),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
        onTap: () => _openSurah(surah),
      ),
    );
  }

  // ========== تبويب القرآن ==========
  
  Widget _buildQuranTab() {
    return QuranListScreen(
      surahs: _surahs,
      downloads: _downloads,
      selectedReciter: _selectedReciter,
      isOnline: _isOnline,
      onSurahTap: _openSurah,
      onDownload: _downloadSurah,
      onDeleteDownload: _deleteDownload,
    );
  }

  // ========== تبويب الأذكار ==========
  
  Widget _buildAdhkarTab() {
    return AdhkarScreen(audioService: _audioService);
  }

  // ========== تبويب الإعدادات ==========
  
  Widget _buildSettingsTab() {
    return SettingsScreen(
      dataService: _dataService,
      reciters: _reciters,
      selectedReciter: _selectedReciter,
      downloads: _downloads,
      bookmarks: _bookmarks,
      isDarkMode: widget.isDarkMode,
      onToggleTheme: widget.onToggleTheme,
      onReciterChanged: (reciter) {
        setState(() {
          _selectedReciter = reciter;
          _dataService.selectedReciterId = reciter.id;
          _updateDownloadStatus();
        });
      },
      onClearDownloads: () async {
        for (var download in _downloads) {
          await _dataService.deleteAudio(download.filePath);
        }
        setState(() {
          _downloads.clear();
          _updateDownloadStatus();
        });
        _dataService.saveDownloads(_downloads);
        _showSnackBar('تم حذف جميع التحميلات', Icons.delete_sweep);
      },
    );
  }

  // ========== فتح السورة ==========
  
  void _openSurah(Surah surah, {int? scrollToAyah}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahScreen(
          surah: surah,
          dataService: _dataService,
          audioService: _audioService,
          reciters: _reciters,
          selectedReciter: _selectedReciter,
          downloads: _downloads,
          bookmarks: _bookmarks,
          isOnline: _isOnline,
          scrollToAyah: scrollToAyah,
          onBookmarkToggle: _toggleBookmark,
          onSaveLastRead: _saveLastRead,
          onDownload: _downloadSurah,
          onReciterChanged: (reciter) {
            setState(() {
              _selectedReciter = reciter;
              _dataService.selectedReciterId = reciter.id;
              _updateDownloadStatus();
            });
          },
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                              شاشة قائمة السور                                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class QuranListScreen extends StatefulWidget {
  final List<Surah> surahs;
  final List<DownloadedAudio> downloads;
  final Reciter? selectedReciter;
  final bool isOnline;
  final Function(Surah) onSurahTap;
  final Function(Surah) onDownload;
  final Function(DownloadedAudio) onDeleteDownload;

  const QuranListScreen({
    super.key,
    required this.surahs,
    required this.downloads,
    required this.selectedReciter,
    required this.isOnline,
    required this.onSurahTap,
    required this.onDownload,
    required this.onDeleteDownload,
  });

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  String _searchQuery = '';
  String _filter = 'all';
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
    
    switch (_filter) {
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // الهيدر
        SliverToBoxAdapter(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'القرآن الكريم',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),
        ),
        
        // عدد السور
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredSurahs.length} سورة',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.downloads.isNotEmpty)
                  Text(
                    '${widget.downloads.length} محملة',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        
        // قائمة السور
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSurahCard(_filteredSurahs[index]),
              childCount: _filteredSurahs.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('الكل', 'all', Icons.apps_rounded),
          const SizedBox(width: 8),
          _buildFilterChip('مكية', 'makki', Icons.location_city_rounded),
          const SizedBox(width: 8),
          _buildFilterChip('مدنية', 'madani', Icons.mosque_rounded),
          const SizedBox(width: 8),
          _buildFilterChip('المفضلة', 'bookmarked', Icons.bookmark_rounded),
          const SizedBox(width: 8),
          _buildFilterChip('المحملة', 'downloaded', Icons.download_done_rounded),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter, IconData icon) {
    final isActive = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive ? null : AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahCard(Surah surah) {
    final isDownloaded = widget.downloads.any(
      (d) => d.surahNumber == surah.number && d.reciterId == widget.selectedReciter?.id,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
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
                // رقم السورة
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // معلومات السورة
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
                                fontSize: 17,
                              ),
                            ),
                          ),
                          if (isDownloaded)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.download_done, size: 14, color: Colors.green),
                            ),
                          if (surah.isBookmarked) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.bookmark, size: 16, color: Colors.amber[600]),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surah.englishNameTranslation,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildSurahBadge('${surah.numberOfAyahs} آية', AppColors.primary),
                          const SizedBox(width: 8),
                          _buildSurahBadge(
                            surah.isMakki ? 'مكية' : 'مدنية',
                            surah.isMakki ? Colors.blue : Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // زر التحميل
                if (widget.selectedReciter != null && widget.isOnline)
                  surah.downloadProgress > 0 && surah.downloadProgress < 1
                      ? SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: surah.downloadProgress,
                            strokeWidth: 3,
                            color: AppColors.primary,
                          ),
                        )
                      : isDownloaded
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                final download = widget.downloads.firstWhere(
                                  (d) => d.surahNumber == surah.number && 
                                         d.reciterId == widget.selectedReciter?.id,
                                );
                                widget.onDeleteDownload(download);
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.download_outlined),
                              onPressed: () => widget.onDownload(surah),
                            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                               شاشة السورة                                     ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class SurahScreen extends StatefulWidget {
  final Surah surah;
  final DataService dataService;
  final AudioService audioService;
  final List<Reciter> reciters;
  final Reciter? selectedReciter;
  final List<DownloadedAudio> downloads;
  final List<Bookmark> bookmarks;
  final bool isOnline;
  final int? scrollToAyah;
  final Function(int, int, String, String) onBookmarkToggle;
  final Function(int, int) onSaveLastRead;
  final Function(Surah) onDownload;
  final Function(Reciter) onReciterChanged;

  const SurahScreen({
    super.key,
    required this.surah,
    required this.dataService,
    required this.audioService,
    required this.reciters,
    required this.selectedReciter,
    required this.downloads,
    required this.bookmarks,
    required this.isOnline,
    this.scrollToAyah,
    required this.onBookmarkToggle,
    required this.onSaveLastRead,
    required this.onDownload,
    required this.onReciterChanged,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  List<Ayah> _ayahs = [];
  bool _isLoading = true;
  bool _isPlaying = false;
  int? _playingAyah;
  final ScrollController _scrollController = ScrollController();
  double _fontSize = 26.0;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.dataService.fontSize;
    _showTranslation = widget.dataService.showTranslation;
    _loadAyahs();
    
    widget.audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  Future<void> _loadAyahs() async {
    // محاولة تحميل من الكاش أولاً
    var ayahs = widget.dataService.getAyahs(widget.surah.number);
    
    if (ayahs.isEmpty && widget.isOnline) {
      // تحميل من الإنترنت
      if (_showTranslation) {
        ayahs = await widget.dataService.fetchAyahsWithTranslation(
          widget.surah.number,
          'ar.muyassar',
        );
      } else {
        ayahs = await widget.dataService.fetchAyahs(widget.surah.number);
      }
      
      if (ayahs.isNotEmpty) {
        await widget.dataService.saveAyahs(widget.surah.number, ayahs);
      }
    }
    
    setState(() {
      _ayahs = ayahs;
      _isLoading = false;
    });
    
    // التمرير للآية المحددة
    if (widget.scrollToAyah != null && _ayahs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(widget.scrollToAyah!);
      });
    }
  }

  void _scrollToAyah(int ayahNumber) {
    final index = _ayahs.indexWhere((a) => a.numberInSurah == ayahNumber);
    if (index >= 0) {
      _scrollController.animateTo(
        index * 150.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _playAyah(Ayah ayah) async {
    try {
      // التحقق من وجود ملف محمل
      final download = widget.downloads.firstWhere(
        (d) => d.surahNumber == widget.surah.number && 
               d.reciterId == widget.selectedReciter?.id,
        orElse: () => DownloadedAudio(
          surahNumber: 0,
          surahName: '',
          reciterId: '',
          reciterName: '',
          filePath: '',
          downloadedAt: DateTime.now(),
          fileSize: 0,
        ),
      );
      
      if (download.filePath.isNotEmpty) {
        await widget.audioService.play(download.filePath, isFile: true);
      } else if (ayah.audio != null && widget.isOnline) {
        await widget.audioService.play(ayah.audio!);
      } else if (widget.selectedReciter != null && widget.isOnline) {
        final url = widget.selectedReciter!.getAudioUrl(widget.surah.number);
        await widget.audioService.play(url);
      }
      
      setState(() {
        _playingAyah = ayah.numberInSurah;
      });
    } catch (e) {
      debugPrint('Error playing ayah: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تشغيل الصوت')),
        );
      }
    }
  }

  Future<void> _stopPlaying() async {
    await widget.audioService.stop();
    setState(() {
      _playingAyah = null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // الهيدر
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.surfaceDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
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
                        widget.surah.englishNameTranslation,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoBadge('${widget.surah.numberOfAyahs} آية'),
                          const SizedBox(width: 12),
                          _buildInfoBadge(widget.surah.isMakki ? 'مكية' : 'مدنية'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.settings_rounded, color: Colors.white),
                ),
                onPressed: _showSettings,
              ),
            ],
          ),
          
          // البسملة
          if (widget.surah.number != 1 && widget.surah.number != 9)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontFamily: 'Amiri',
                    color: AppColors.gold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          
          // الآيات
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _ayahs.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off, size: 64, color: Colors.grey[600]),
                            const SizedBox(height: 16),
                            Text(
                              'لا يمكن تحميل الآيات',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() => _isLoading = true);
                                _loadAyahs();
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildAyahCard(_ayahs[index]),
                          childCount: _ayahs.length,
                        ),
                      ),
                    ),
        ],
      ),
      
      // شريط التحكم بالصوت
      floatingActionButton: widget.selectedReciter != null
          ? FloatingActionButton(
              onPressed: () {
                if (_isPlaying) {
                  _stopPlaying();
                } else if (_ayahs.isNotEmpty) {
                  _playAyah(_ayahs.first);
                }
              },
              backgroundColor: AppColors.primary,
              child: Icon(
                _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildInfoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAyahCard(Ayah ayah) {
    final isBookmarked = widget.bookmarks.any(
      (b) => b.surahNumber == widget.surah.number && b.ayahNumber == ayah.numberInSurah,
    );
    final isCurrentlyPlaying = _playingAyah == ayah.numberInSurah && _isPlaying;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCurrentlyPlaying 
            ? AppColors.primary.withAlpha(30)
            : AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: isCurrentlyPlaying
            ? Border.all(color: AppColors.primary.withAlpha(100))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس البطاقة
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // أزرار الإجراءات
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.gold : Colors.grey,
                    size: 22,
                  ),
                  onPressed: () {
                    widget.onBookmarkToggle(
                      widget.surah.number,
                      ayah.numberInSurah,
                      widget.surah.name,
                      ayah.text.length > 100 ? '${ayah.text.substring(0, 100)}...' : ayah.text,
                    );
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(
                    isCurrentlyPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  onPressed: () {
                    if (isCurrentlyPlaying) {
                      _stopPlaying();
                    } else {
                      _playAyah(ayah);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 22),
                  onPressed: () => _shareAyah(ayah),
                ),
              ],
            ),
          ),
          
          // نص الآية
          GestureDetector(
            onTap: () {
              widget.onSaveLastRead(widget.surah.number, ayah.numberInSurah);
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                ayah.text,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontFamily: 'Amiri',
                  height: 2.0,
                  color: isCurrentlyPlaying ? AppColors.primary : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // الترجمة
          if (_showTranslation && ayah.translation != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ayah.translation!,
                style: TextStyle(
                  fontSize: _fontSize * 0.6,
                  color: Colors.grey[400],
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // معلومات إضافية
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _buildAyahInfo('جزء ${ayah.juz}'),
                const SizedBox(width: 12),
                _buildAyahInfo('صفحة ${ayah.page}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahInfo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  void _shareAyah(Ayah ayah) {
    final text = '''
${ayah.text}

[${widget.surah.name} - الآية ${ayah.numberInSurah}]

من تطبيق القرآن الكريم
''';
    Share.share(text);
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'إعدادات القراءة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // حجم الخط
              Row(
                children: [
                  const Text('حجم الخط'),
                  const Spacer(),
                  Text('${_fontSize.round()}'),
                ],
              ),
              Slider(
                value: _fontSize,
                min: 18,
                max: 40,
                divisions: 11,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setModalState(() => _fontSize = value);
                  setState(() {});
                  widget.dataService.fontSize = value;
                },
              ),
              
              const SizedBox(height: 16),
              
              // إظهار الترجمة
              SwitchListTile(
                title: const Text('إظهار التفسير'),
                value: _showTranslation,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setModalState(() => _showTranslation = value);
                  setState(() {});
                  widget.dataService.showTranslation = value;
                  if (value && _ayahs.isNotEmpty && _ayahs.first.translation == null) {
                    _loadAyahs();
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // اختيار القارئ
              ListTile(
                title: const Text('القارئ'),
                subtitle: Text(widget.selectedReciter?.name ?? 'اختر قارئ'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(context);
                  _showReciterPicker();
                },
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showReciterPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'اختر القارئ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = widget.reciters[index];
                    final isSelected = widget.selectedReciter?.id == reciter.id;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary.withAlpha(30)
                            : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: AppColors.primary.withAlpha(80))
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.primaryGradient : null,
                            color: isSelected ? null : Colors.grey.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                        title: Text(
                          reciter.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: reciter.rewaya != null
                            ? Text(
                                reciter.rewaya!,
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              )
                            : null,
                        trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : null,
                        onTap: () {
                          widget.onReciterChanged(reciter);
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
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                              شاشة الأذكار                                     ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class AdhkarScreen extends StatelessWidget {
  final AudioService audioService;

  const AdhkarScreen({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    final categories = AdhkarData.getCategories();
    
    return CustomScrollView(
      slivers: [
        // الهيدر
        SliverToBoxAdapter(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الأذكار والأدعية',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
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
        ),
        
        // الفئات
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
                final category = categories[index];
                return _buildCategoryCard(context, category);
              },
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, AdhkarCategory category) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => _openCategory(context, category),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: category.colors,
            ),
            boxShadow: [
              BoxShadow(
                color: category.colors[0].withAlpha(100),
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
                    color: Colors.white.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.items.length} ذكر',
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 11,
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

  void _openCategory(BuildContext context, AdhkarCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdhkarDetailScreen(
          category: category,
          audioService: audioService,
        ),
      ),
    );
  }
}

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
  late Map<int, int> _counters;

  @override
  void initState() {
    super.initState();
    _counters = {for (var item in widget.category.items) item.id: 0};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.items.length,
        itemBuilder: (context, index) {
          final dhikr = widget.category.items[index];
          return _buildDhikrCard(dhikr);
        },
      ),
    );
  }

  Widget _buildDhikrCard(Dhikr dhikr) {
    final count = _counters[dhikr.id] ?? 0;
    final isCompleted = dhikr.count > 0 && count >= dhikr.count;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isCompleted 
            ? Colors.green.withAlpha(25)
            : AppColors.cardDark,
        border: isCompleted 
            ? Border.all(color: Colors.green.withAlpha(80))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _incrementCounter(dhikr),
          onLongPress: () => _resetCounter(dhikr),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الهيدر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'التكرار: ${dhikr.count}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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
                
                // النص
                Text(
                  dhikr.text,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Amiri',
                    height: 2,
                    color: isCompleted ? Colors.green[700] : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // العداد
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isCompleted 
                          ? const LinearGradient(colors: [Colors.green, Color(0xFF2E7D32)])
                          : AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      dhikr.count > 0 ? '$count / ${dhikr.count}' : '$count',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // المرجع
                if (dhikr.reference != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    dhikr.reference!,
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

  void _incrementCounter(Dhikr dhikr) {
    if (dhikr.count == 0 || (_counters[dhikr.id] ?? 0) < dhikr.count) {
      setState(() {
        _counters[dhikr.id] = (_counters[dhikr.id] ?? 0) + 1;
      });

      if (dhikr.count > 0 && _counters[dhikr.id] == dhikr.count) {
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
          ),
        );
      }
    }
  }

  void _resetCounter(Dhikr dhikr) {
    setState(() {
      _counters[dhikr.id] = 0;
    });
    HapticFeedback.lightImpact();
  }
}

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                             شاشة الإعدادات                                    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

class SettingsScreen extends StatelessWidget {
  final DataService dataService;
  final List<Reciter> reciters;
  final Reciter? selectedReciter;
  final List<DownloadedAudio> downloads;
  final List<Bookmark> bookmarks;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Function(Reciter) onReciterChanged;
  final VoidCallback onClearDownloads;

  const SettingsScreen({
    super.key,
    required this.dataService,
    required this.reciters,
    required this.selectedReciter,
    required this.downloads,
    required this.bookmarks,
    required this.isDarkMode,
    required this.onToggleTheme,
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
    final totalSize = downloads.fold<int>(0, (sum, d) => sum + d.fileSize);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SafeArea(
          child: Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // الإحصائيات
        _buildSection(context, 'الإحصائيات', [
          _buildStatItem(
            context,
            'المفضلة',
            '${bookmarks.length} آية',
            Icons.bookmark_rounded,
            AppColors.goldGradient,
          ),
          _buildStatItem(
            context,
            'التحميلات',
            '${downloads.length} سورة',
            Icons.download_rounded,
            AppColors.blueGradient,
          ),
          _buildStatItem(
            context,
            'حجم التخزين',
            _formatFileSize(totalSize),
            Icons.storage_rounded,
            AppColors.orangeGradient,
          ),
        ]),
        
        const SizedBox(height: 24),
        
        // الإعدادات
        _buildSection(context, 'الإعدادات', [
          _buildSettingItem(
            context,
            'المظهر',
            isDarkMode ? 'داكن' : 'فاتح',
            Icons.palette_rounded,
            onToggleTheme,
          ),
          _buildSettingItem(
            context,
            'القارئ الافتراضي',
            selectedReciter?.name ?? 'اختر قارئ',
            Icons.person_rounded,
            () => _showReciterPicker(context),
          ),
        ]),
        
        const SizedBox(height: 24),
        
        // الخيارات
        _buildSection(context, 'الخيارات', [
          _buildSettingItem(
            context,
            'حذف جميع التحميلات',
            _formatFileSize(totalSize),
            Icons.delete_sweep_rounded,
            () => _confirmClearDownloads(context),
            isDestructive: true,
          ),
          _buildSettingItem(
            context,
            'مشاركة التطبيق',
            '',
            Icons.share_rounded,
            () => Share.share('تطبيق القرآن الكريم SMART PRO - أفضل تطبيق للقرآن يعمل بدون إنترنت'),
          ),
        ]),
        
        const SizedBox(height: 24),
        
        // حول التطبيق
        _buildSection(context, 'حول التطبيق', [
          _buildInfoItem('الإصدار', 'v3.0.0 SMART PRO'),
          _buildInfoItem('المطور', 'محمد إبراهيم عبدالله'),
        ]),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    LinearGradient gradient,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withAlpha(30)
              : AppColors.primary.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            Text(value, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.info_outline_rounded, color: Colors.grey, size: 22),
      ),
      title: Text(title),
      trailing: Text(value, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
    );
  }

  void _showReciterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'اختر القارئ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                            ? AppColors.primary.withAlpha(30)
                            : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: AppColors.primary.withAlpha(80))
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.primaryGradient : null,
                            color: isSelected ? null : Colors.grey.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                        title: Text(
                          reciter.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: reciter.rewaya != null
                            ? Text(
                                reciter.rewaya!,
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              )
                            : null,
                        trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
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

  void _confirmClearDownloads(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف التحميلات'),
        content: const Text('هل أنت متأكد من حذف جميع التحميلات؟'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}