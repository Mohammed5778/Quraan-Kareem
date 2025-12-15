// main.dart - تطبيق القرآن الكريم الشامل
// All-in-one Quran App

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  final prefs = await SharedPreferences.getInstance();
  
  runApp(QuranApp(prefs: prefs));
}

// ==================== MAIN APP ====================

class QuranApp extends StatefulWidget {
  final SharedPreferences prefs;
  
  const QuranApp({super.key, required this.prefs});

  @override
  State<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends State<QuranApp> {
  ThemeMode _themeMode = ThemeMode.system;
  
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }
  
  void _loadTheme() {
    final theme = widget.prefs.getString('theme_mode') ?? 'system';
    setState(() {
      _themeMode = theme == 'dark' 
          ? ThemeMode.dark 
          : theme == 'light' 
              ? ThemeMode.light 
              : ThemeMode.system;
    });
  }
  
  void updateTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.prefs.setString('theme_mode', 
        mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'القرآن الكريم',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        fontFamily: 'Amiri',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Amiri',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: HomeScreen(
        prefs: widget.prefs,
        onThemeChanged: updateTheme,
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

// ==================== MODELS ====================

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
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
  final String? translation;
  final String? tafsir;
  final int juz;
  final int page;
  final int hizbQuarter;
  final String? audioUrl;

  Verse({
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.translation,
    this.tafsir,
    required this.juz,
    required this.page,
    required this.hizbQuarter,
    this.audioUrl,
  });

  Verse copyWith({
    int? number,
    int? numberInSurah,
    String? text,
    String? translation,
    String? tafsir,
    int? juz,
    int? page,
    int? hizbQuarter,
    String? audioUrl,
  }) {
    return Verse(
      number: number ?? this.number,
      numberInSurah: numberInSurah ?? this.numberInSurah,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      tafsir: tafsir ?? this.tafsir,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      hizbQuarter: hizbQuarter ?? this.hizbQuarter,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}

class Reciter {
  final String id;
  final String name;
  final String englishName;
  final String style;
  final String audioBaseUrl;

  Reciter({
    required this.id,
    required this.name,
    required this.englishName,
    required this.style,
    required this.audioBaseUrl,
  });
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
      fajr: json['Fajr'] ?? '',
      sunrise: json['Sunrise'] ?? '',
      dhuhr: json['Dhuhr'] ?? '',
      asr: json['Asr'] ?? '',
      maghrib: json['Maghrib'] ?? '',
      isha: json['Isha'] ?? '',
    );
  }
}

class Zikr {
  final int id;
  final String category;
  final String text;
  final String? translation;
  final int count;
  final String? reference;
  final String? virtue;

  Zikr({
    required this.id,
    required this.category,
    required this.text,
    this.translation,
    required this.count,
    this.reference,
    this.virtue,
  });
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
}

// ==================== API SERVICE ====================

class QuranApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/surah'));
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

  Future<List<Verse>> getVerses(int surahNumber, {String? translation}) async {
    try {
      final arabicResponse = await http.get(
        Uri.parse('$_baseUrl/surah/$surahNumber/ar.alafasy'),
      );

      List<Verse> verses = [];

      if (arabicResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final List<dynamic> ayahs = arabicData['data']['ayahs'];

        verses = ayahs.map((ayah) => Verse(
          number: ayah['number'],
          numberInSurah: ayah['numberInSurah'],
          text: ayah['text'],
          juz: ayah['juz'],
          page: ayah['page'],
          hizbQuarter: ayah['hizbQuarter'],
          audioUrl: ayah['audio'],
        )).toList();
      }

      if (translation != null && verses.isNotEmpty) {
        final translationResponse = await http.get(
          Uri.parse('$_baseUrl/surah/$surahNumber/$translation'),
        );

        if (translationResponse.statusCode == 200) {
          final translationData = json.decode(translationResponse.body);
          final List<dynamic> translatedAyahs = translationData['data']['ayahs'];

          for (int i = 0; i < verses.length && i < translatedAyahs.length; i++) {
            verses[i] = verses[i].copyWith(
              translation: translatedAyahs[i]['text'],
            );
          }
        }
      }

      return verses;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/$query/all/ar'),
      );
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

  List<Reciter> getReciters() {
    return [
      Reciter(
        id: 'ar.alafasy',
        name: 'مشاري راشد العفاسي',
        englishName: 'Mishary Rashid Alafasy',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/',
      ),
      Reciter(
        id: 'ar.abdulbasit',
        name: 'عبد الباسط عبد الصمد',
        englishName: 'Abdul Basit Abdul Samad',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.abdulbasitmurattal/',
      ),
      Reciter(
        id: 'ar.husary',
        name: 'محمود خليل الحصري',
        englishName: 'Mahmoud Khalil Al-Husary',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.husary/',
      ),
      Reciter(
        id: 'ar.minshawi',
        name: 'محمد صديق المنشاوي',
        englishName: 'Mohamed Siddiq Al-Minshawi',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.minshawi/',
      ),
      Reciter(
        id: 'ar.sudais',
        name: 'عبد الرحمن السديس',
        englishName: 'Abdurrahman As-Sudais',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.abdurrahmansudais/',
      ),
    ];
  }
}

// ==================== PRAYER TIME SERVICE ====================

class PrayerTimeService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  Future<PrayerTimings> getPrayerTimes(double lat, double lng) async {
    try {
      final now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/timings/${now.day}-${now.month}-${now.year}?latitude=$lat&longitude=$lng&method=4',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimings.fromJson(data['data']['timings']);
      }
      throw Exception('Failed to load prayer times');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}

// ==================== AUDIO SERVICE ====================

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Duration? get duration => _player.duration;
  Duration get position => _player.position;

  Future<void> playVerse(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
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
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void dispose() {
    _player.dispose();
  }
}

// ==================== HOME SCREEN ====================

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final Function(ThemeMode) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.prefs,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      QuranScreen(prefs: widget.prefs),
      AzkarScreen(),
      PrayerTimesScreen(),
      RadioScreen(),
      SettingsScreen(prefs: widget.prefs, onThemeChanged: widget.onThemeChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'القرآن',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time_filled),
            label: 'الصلاة',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_outlined),
            selectedIcon: Icon(Icons.radio),
            label: 'الراديو',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

// ==================== QURAN SCREEN ====================

class QuranScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const QuranScreen({super.key, required this.prefs});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final QuranApiService _apiService = QuranApiService();
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final surahs = await _apiService.getSurahs();
      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل السور: $e')),
        );
      }
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSurahs = _surahs;
      } else {
        _filteredSurahs = _surahs.where((surah) {
          return surah.name.contains(query) ||
              surah.englishName.toLowerCase().contains(query.toLowerCase()) ||
              surah.number.toString() == query;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'السور'),
            Tab(text: 'الأجزاء'),
            Tab(text: 'المفضلة'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن سورة...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterSurahs('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: _filterSurahs,
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Surahs Tab
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSurahsList(),
                
                // Juz Tab
                _buildJuzList(),
                
                // Bookmarks Tab
                BookmarksTab(prefs: widget.prefs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahsList() {
    if (_filteredSurahs.isEmpty) {
      return const Center(
        child: Text('لا توجد نتائج'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            title: Text(
              surah.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${surah.englishName} - ${surah.numberOfAyahs} آية',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: surah.isMakki
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                surah.isMakki ? 'مكية' : 'مدنية',
                style: TextStyle(
                  fontSize: 12,
                  color: surah.isMakki ? Colors.orange : Colors.green,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahDetailScreen(
                    surah: surah,
                    prefs: widget.prefs,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$juzNumber',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            title: Text(
              'الجزء $juzNumber',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(_getJuzName(juzNumber)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Juz
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('الجزء $juzNumber')),
              );
            },
          ),
        );
      },
    );
  }

  String _getJuzName(int juz) {
    const juzNames = [
      'آلم', 'سيقول', 'تلك الرسل', 'لن تنالوا', 'والمحصنات',
      'لا يحب الله', 'وإذا سمعوا', 'ولو أننا', 'قال الملأ',
      'واعلموا', 'يعتذرون', 'وما من دابة', 'وما أبرئ',
      'ربما', 'سبحان الذي', 'قال ألم', 'اقترب للناس',
      'قد أفلح', 'وقال الذين', 'أمن خلق', 'اتل ما أوحي',
      'ومن يقنت', 'وما لي', 'فمن أظلم', 'إليه يرد',
      'حم', 'قال فما خطبكم', 'قد سمع الله', 'تبارك', 'عم'
    ];
    return juzNames[juz - 1];
  }
}

// ==================== BOOKMARKS TAB ====================

class BookmarksTab extends StatefulWidget {
  final SharedPreferences prefs;

  const BookmarksTab({super.key, required this.prefs});

  @override
  State<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends State<BookmarksTab> {
  List<Bookmark> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    final jsonString = widget.prefs.getString('bookmarks');
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      setState(() {
        _bookmarks = jsonList.map((j) => Bookmark.fromJson(j)).toList();
      });
    }
  }

  void _deleteBookmark(int index) {
    setState(() {
      _bookmarks.removeAt(index);
    });
    _saveBookmarks();
  }

  void _saveBookmarks() {
    final jsonList = _bookmarks.map((b) => b.toJson()).toList();
    widget.prefs.setString('bookmarks', json.encode(jsonList));
  }

  @override
  Widget build(BuildContext context) {
    if (_bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد علامات مرجعية',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط مطولاً على أي آية لإضافتها للمفضلة',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = _bookmarks[index];
        return Dismissible(
          key: Key('${bookmark.surahNumber}-${bookmark.verseNumber}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => _deleteBookmark(index),
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text(bookmark.surahName),
              subtitle: Text('الآية ${bookmark.verseNumber}'),
              trailing: Text(
                '${bookmark.createdAt.day}/${bookmark.createdAt.month}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== SURAH DETAIL SCREEN ====================

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final SharedPreferences prefs;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    required this.prefs,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranApiService _apiService = QuranApiService();
  final AudioService _audioService = AudioService();
  List<Verse> _verses = [];
  bool _isLoading = true;
  bool _showTranslation = false;
  double _fontSize = 24.0;
  int? _playingVerse;
  Reciter? _selectedReciter;
  List<Reciter> _reciters = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVerses();
    _reciters = _apiService.getReciters();
    _selectedReciter = _reciters.first;
  }

  void _loadSettings() {
    _fontSize = widget.prefs.getDouble('font_size') ?? 24.0;
    _showTranslation = widget.prefs.getBool('show_translation') ?? false;
  }

  Future<void> _loadVerses() async {
    try {
      final verses = await _apiService.getVerses(
        widget.surah.number,
        translation: _showTranslation ? 'en.sahih' : null,
      );
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _playVerse(Verse verse) async {
    if (_selectedReciter == null) return;
    
    setState(() => _playingVerse = verse.number);
    
    final url = '${_selectedReciter!.audioBaseUrl}${verse.number}.mp3';
    await _audioService.playVerse(url);
  }

  void _addBookmark(Verse verse) {
    final bookmark = Bookmark(
      surahNumber: widget.surah.number,
      surahName: widget.surah.name,
      verseNumber: verse.numberInSurah,
      createdAt: DateTime.now(),
    );

    final jsonString = widget.prefs.getString('bookmarks');
    List<Bookmark> bookmarks = [];
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      bookmarks = jsonList.map((j) => Bookmark.fromJson(j)).toList();
    }

    bookmarks.add(bookmark);
    final jsonList = bookmarks.map((b) => b.toJson()).toList();
    widget.prefs.setString('bookmarks', json.encode(jsonList));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت الإضافة للمفضلة')),
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
      appBar: AppBar(
        title: Text(widget.surah.name),
        actions: [
          // Font size
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: _showFontSizeDialog,
          ),
          // Translation toggle
          IconButton(
            icon: Icon(
              _showTranslation ? Icons.translate : Icons.translate_outlined,
            ),
            onPressed: () {
              setState(() => _showTranslation = !_showTranslation);
              widget.prefs.setBool('show_translation', _showTranslation);
              _loadVerses();
            },
          ),
          // Reciter selection
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            onPressed: _showReciterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Surah Info Header
                Container(
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
                      // Bismillah (except for Surah At-Tawbah)
                      if (widget.surah.number != 9)
                        const Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Amiri',
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
                ),

                // Verses List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _verses.length,
                    itemBuilder: (context, index) {
                      final verse = _verses[index];
                      final isPlaying = _playingVerse == verse.number;

                      return GestureDetector(
                        onLongPress: () => _addBookmark(verse),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isPlaying
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Verse Header
                                Row(
                                  children: [
                                    Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${verse.numberInSurah}',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    // Play button
                                    IconButton(
                                      icon: Icon(
                                        isPlaying ? Icons.pause : Icons.play_arrow,
                                      ),
                                      onPressed: () {
                                        if (isPlaying) {
                                          _audioService.pause();
                                          setState(() => _playingVerse = null);
                                        } else {
                                          _playVerse(verse);
                                        }
                                      },
                                    ),
                                    // Bookmark button
                                    IconButton(
                                      icon: const Icon(Icons.bookmark_add_outlined),
                                      onPressed: () => _addBookmark(verse),
                                    ),
                                    // Share button
                                    IconButton(
                                      icon: const Icon(Icons.share_outlined),
                                      onPressed: () {
                                        // Share functionality
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Arabic Text
                                Text(
                                  verse.text,
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    fontFamily: 'Amiri',
                                    height: 2,
                                  ),
                                  textAlign: TextAlign.justify,
                                  textDirection: TextDirection.rtl,
                                ),

                                // Translation
                                if (_showTranslation && verse.translation != null) ...[
                                  const Divider(height: 24),
                                  Text(
                                    verse.translation!,
                                    style: TextStyle(
                                      fontSize: _fontSize - 6,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ],

                                // Page & Juz Info
                                const SizedBox(height: 8),
                                Text(
                                  'الجزء ${verse.juz} - الصفحة ${verse.page}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حجم الخط'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'بِسْمِ اللَّهِ',
                  style: TextStyle(fontSize: _fontSize, fontFamily: 'Amiri'),
                ),
                Slider(
                  value: _fontSize,
                  min: 16,
                  max: 40,
                  divisions: 12,
                  label: _fontSize.round().toString(),
                  onChanged: (value) {
                    setDialogState(() => _fontSize = value);
                    setState(() => _fontSize = value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.prefs.setDouble('font_size', _fontSize);
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showReciterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر القارئ'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _reciters.length,
            itemBuilder: (context, index) {
              final reciter = _reciters[index];
              return RadioListTile<Reciter>(
                title: Text(reciter.name),
                subtitle: Text(reciter.englishName),
                value: reciter,
                groupValue: _selectedReciter,
                onChanged: (value) {
                  setState(() => _selectedReciter = value);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==================== AZKAR SCREEN ====================

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'أذكار الصباح', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {'name': 'أذكار المساء', 'icon': Icons.nights_stay, 'color': Colors.indigo},
    {'name': 'أذكار النوم', 'icon': Icons.bedtime, 'color': Colors.purple},
    {'name': 'أذكار الاستيقاظ', 'icon': Icons.alarm, 'color': Colors.teal},
    {'name': 'أذكار بعد الصلاة', 'icon': Icons.mosque, 'color': Colors.green},
    {'name': 'أدعية متنوعة', 'icon': Icons.favorite, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AzkarDetailScreen(
                      categoryName: category['name'],
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (category['color'] as Color).withOpacity(0.7),
                      category['color'] as Color,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== AZKAR DETAIL SCREEN ====================

class AzkarDetailScreen extends StatefulWidget {
  final String categoryName;

  const AzkarDetailScreen({super.key, required this.categoryName});

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  late List<Zikr> _azkar;
  Map<int, int> _counters = {};

  @override
  void initState() {
    super.initState();
    _loadAzkar();
  }

  void _loadAzkar() {
    // Sample azkar data
    _azkar = _getAzkarByCategory(widget.categoryName);
    for (var zikr in _azkar) {
      _counters[zikr.id] = 0;
    }
  }

  List<Zikr> _getAzkarByCategory(String category) {
    if (category == 'أذكار الصباح') {
      return [
        Zikr(
          id: 1,
          category: category,
          text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          count: 1,
          reference: 'مسلم',
        ),
        Zikr(
          id: 2,
          category: category,
          text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
          count: 1,
          reference: 'الترمذي',
        ),
        Zikr(
          id: 3,
          category: category,
          text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
          count: 100,
          reference: 'مسلم',
          virtue: 'من قالها مائة مرة حين يصبح وحين يمسي لم يأت أحد يوم القيامة بأفضل مما جاء به',
        ),
        Zikr(
          id: 4,
          category: category,
          text: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          count: 100,
          reference: 'البخاري ومسلم',
          virtue: 'كانت له عدل عشر رقاب، وكتبت له مائة حسنة، ومحيت عنه مائة سيئة',
        ),
      ];
    } else if (category == 'أذكار المساء') {
      return [
        Zikr(
          id: 5,
          category: category,
          text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          count: 1,
          reference: 'مسلم',
        ),
        Zikr(
          id: 6,
          category: category,
          text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
          count: 1,
          reference: 'الترمذي',
        ),
      ];
    } else if (category == 'أذكار النوم') {
      return [
        Zikr(
          id: 7,
          category: category,
          text: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
          count: 1,
          reference: 'البخاري',
        ),
        Zikr(
          id: 8,
          category: category,
          text: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
          count: 3,
          reference: 'أبو داود',
        ),
      ];
    } else if (category == 'أذكار بعد الصلاة') {
      return [
        Zikr(
          id: 9,
          category: category,
          text: 'أَسْتَغْفِرُ اللهَ',
          count: 3,
          reference: 'مسلم',
        ),
        Zikr(
          id: 10,
          category: category,
          text: 'اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
          count: 1,
          reference: 'مسلم',
        ),
        Zikr(
          id: 11,
          category: category,
          text: 'سُبْحَانَ اللهِ',
          count: 33,
          reference: 'مسلم',
        ),
        Zikr(
          id: 12,
          category: category,
          text: 'الْحَمْدُ لِلَّهِ',
          count: 33,
          reference: 'مسلم',
        ),
        Zikr(
          id: 13,
          category: category,
          text: 'اللهُ أَكْبَرُ',
          count: 34,
          reference: 'مسلم',
        ),
      ];
    }
    return [
      Zikr(
        id: 14,
        category: category,
        text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ الْعَظِيمِ',
        count: 0,
        reference: 'البخاري ومسلم',
        virtue: 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن',
      ),
    ];
  }

  void _incrementCounter(Zikr zikr) {
    if (zikr.count == 0 || _counters[zikr.id]! < zikr.count) {
      setState(() {
        _counters[zikr.id] = _counters[zikr.id]! + 1;
      });

      if (zikr.count > 0 && _counters[zikr.id] == zikr.count) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('أحسنت! أكملت هذا الذكر'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _resetCounter(Zikr zikr) {
    setState(() {
      _counters[zikr.id] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _azkar.length,
        itemBuilder: (context, index) {
          final zikr = _azkar[index];
          final count = _counters[zikr.id] ?? 0;
          final isCompleted = zikr.count > 0 && count >= zikr.count;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: isCompleted
                ? Colors.green.withOpacity(0.1)
                : null,
            child: InkWell(
              onTap: () => _incrementCounter(zikr),
              onLongPress: () => _resetCounter(zikr),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Zikr Text
                    Text(
                      zikr.text,
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Amiri',
                        height: 2,
                        color: isCompleted ? Colors.green : null,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            zikr.count > 0
                                ? '$count / ${zikr.count}'
                                : '$count',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Reference
                    if (zikr.reference != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        zikr.reference!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // Virtue
                    if (zikr.virtue != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          zikr.virtue!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== PRAYER TIMES SCREEN ====================

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimeService _service = PrayerTimeService();
  PrayerTimings? _timings;
  bool _isLoading = true;
  String? _error;
  String _cityName = 'جاري التحديد...';

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
      final timings = await _service.getPrayerTimes(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _timings = timings;
        _cityName = 'موقعك الحالي';
        _isLoading = false;
      });
    } catch (e) {
      // Use default location (Mecca) if location fails
      try {
        final timings = await _service.getPrayerTimes(21.4225, 39.8262);
        setState(() {
          _timings = timings;
          _cityName = 'مكة المكرمة';
          _isLoading = false;
        });
      } catch (e2) {
        setState(() {
          _error = 'خطأ في تحميل مواقيت الصلاة';
          _isLoading = false;
        });
      }
    }
  }

  String _getNextPrayer() {
    if (_timings == null) return '';

    final now = DateTime.now();
    final prayers = [
      {'name': 'الفجر', 'time': _parseTime(_timings!.fajr)},
      {'name': 'الشروق', 'time': _parseTime(_timings!.sunrise)},
      {'name': 'الظهر', 'time': _parseTime(_timings!.dhuhr)},
      {'name': 'العصر', 'time': _parseTime(_timings!.asr)},
      {'name': 'المغرب', 'time': _parseTime(_timings!.maghrib)},
      {'name': 'العشاء', 'time': _parseTime(_timings!.isha)},
    ];

    for (var prayer in prayers) {
      if ((prayer['time'] as DateTime).isAfter(now)) {
        return prayer['name'] as String;
      }
    }
    return 'الفجر';
  }

  DateTime _parseTime(String timeString) {
    final now = DateTime.now();
    final parts = timeString.split(' ')[0].split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrayerTimes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
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
              : RefreshIndicator(
                  onRefresh: _loadPrayerTimes,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Location Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _cityName,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Text(
                                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Next Prayer Card
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                'الصلاة القادمة',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getNextPrayer(),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Prayer Times List
                      _buildPrayerTile('الفجر', _timings!.fajr, Icons.dark_mode),
                      _buildPrayerTile('الشروق', _timings!.sunrise, Icons.wb_twilight),
                      _buildPrayerTile('الظهر', _timings!.dhuhr, Icons.wb_sunny),
                      _buildPrayerTile('العصر', _timings!.asr, Icons.sunny_snowing),
                      _buildPrayerTile('المغرب', _timings!.maghrib, Icons.wb_twilight),
                      _buildPrayerTile('العشاء', _timings!.isha, Icons.nights_stay),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPrayerTile(String name, String time, IconData icon) {
    final isNext = _getNextPrayer() == name;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isNext ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isNext
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(
          time.split(' ')[0],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isNext ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}

// ==================== RADIO SCREEN ====================

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final AudioPlayer _player = AudioPlayer();
  RadioStation? _currentStation;
  bool _isPlaying = false;

  final List<RadioStation> _stations = [
    RadioStation(
      id: '1',
      name: 'إذاعة القرآن الكريم - السعودية',
      url: 'https://stream.radiojar.com/0tpy1h0kxtzuv',
    ),
    RadioStation(
      id: '2',
      name: 'إذاعة القرآن الكريم - مصر',
      url: 'https://stream.radiojar.com/4wqre23fytzuv',
    ),
    RadioStation(
      id: '3',
      name: 'إذاعة الشيخ مشاري العفاسي',
      url: 'https://qurango.net/radio/mishary_alafasi',
    ),
    RadioStation(
      id: '4',
      name: 'إذاعة الشيخ عبد الباسط',
      url: 'https://qurango.net/radio/abdulbasit_mujawwad',
    ),
    RadioStation(
      id: '5',
      name: 'إذاعة الشيخ الحصري',
      url: 'https://qurango.net/radio/mahmoud_alhasry',
    ),
    RadioStation(
      id: '6',
      name: 'إذاعة السديس والشريم',
      url: 'https://qurango.net/radio/sudais_and_shuraim',
    ),
  ];

  Future<void> _playStation(RadioStation station) async {
    try {
      if (_currentStation?.id == station.id && _isPlaying) {
        await _player.pause();
        setState(() => _isPlaying = false);
      } else {
        await _player.setUrl(station.url);
        await _player.play();
        setState(() {
          _currentStation = station;
          _isPlaying = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تشغيل الراديو: $e')),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('راديو القرآن الكريم'),
      ),
      body: Column(
        children: [
          // Now Playing Card
          if (_currentStation != null)
            Container(
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
                  const Icon(Icons.radio, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    _currentStation!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 64,
                        ),
                        onPressed: () => _playStation(_currentStation!),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Stations List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _stations.length,
              itemBuilder: (context, index) {
                final station = _stations[index];
                final isPlaying = _currentStation?.id == station.id && _isPlaying;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isPlaying
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    leading: Icon(
                      isPlaying ? Icons.radio : Icons.radio_outlined,
                      color: isPlaying
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(
                      station.name,
                      style: TextStyle(
                        fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onTap: () => _playStation(station),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SETTINGS SCREEN ====================

class SettingsScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.prefs,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _themeMode;
  late double _fontSize;
  late bool _showTranslation;
  late bool _dailyReminder;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _themeMode = widget.prefs.getString('theme_mode') ?? 'system';
    _fontSize = widget.prefs.getDouble('font_size') ?? 24.0;
    _showTranslation = widget.prefs.getBool('show_translation') ?? false;
    _dailyReminder = widget.prefs.getBool('daily_reminder') ?? false;
  }

  void _setTheme(String mode) {
    setState(() => _themeMode = mode);
    widget.prefs.setString('theme_mode', mode);
    
    ThemeMode themeMode;
    switch (mode) {
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'light':
        themeMode = ThemeMode.light;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    widget.onThemeChanged(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        children: [
          // Theme Section
          _buildSectionTitle('المظهر'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('تلقائي (حسب النظام)'),
                  value: 'system',
                  groupValue: _themeMode,
                  onChanged: (value) => _setTheme(value!),
                ),
                RadioListTile<String>(
                  title: const Text('فاتح'),
                  value: 'light',
                  groupValue: _themeMode,
                  onChanged: (value) => _setTheme(value!),
                ),
                RadioListTile<String>(
                  title: const Text('داكن'),
                  value: 'dark',
                  groupValue: _themeMode,
                  onChanged: (value) => _setTheme(value!),
                ),
              ],
            ),
          ),

          // Reading Section
          _buildSectionTitle('القراءة'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('حجم الخط'),
                  subtitle: Slider(
                    value: _fontSize,
                    min: 16,
                    max: 40,
                    divisions: 12,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() => _fontSize = value);
                      widget.prefs.setDouble('font_size', value);
                    },
                  ),
                ),
                SwitchListTile(
                  title: const Text('إظهار الترجمة'),
                  subtitle: const Text('عرض ترجمة الآيات'),
                  value: _showTranslation,
                  onChanged: (value) {
                    setState(() => _showTranslation = value);
                    widget.prefs.setBool('show_translation', value);
                  },
                ),
              ],
            ),
          ),

          // Notifications Section
          _buildSectionTitle('الإشعارات'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تذكير يومي'),
                  subtitle: const Text('تذكير بقراءة القرآن'),
                  value: _dailyReminder,
                  onChanged: (value) {
                    setState(() => _dailyReminder = value);
                    widget.prefs.setBool('daily_reminder', value);
                  },
                ),
              ],
            ),
          ),

          // About Section
          _buildSectionTitle('حول التطبيق'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const ListTile(
                  title: Text('الإصدار'),
                  trailing: Text('1.0.0'),
                ),
                ListTile(
                  title: const Text('المطور'),
                  trailing: const Text('تطبيق القرآن الكريم'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('تقييم التطبيق'),
                  trailing: const Icon(Icons.star),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('شكراً لك!')),
                    );
                  },
                ),
                ListTile(
                  title: const Text('مشاركة التطبيق'),
                  trailing: const Icon(Icons.share),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}