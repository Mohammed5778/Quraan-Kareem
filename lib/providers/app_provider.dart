import 'package:flutter/material.dart';
import '../services/quran_api_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/surah.dart';
import '../models/verse.dart';
import '../models/reciter.dart';
import '../models/bookmark.dart';
import '../models/last_read.dart';
import '../models/khatmah_goal.dart';

class AppProvider with ChangeNotifier {
  final QuranApiService _quranApiService = QuranApiService();
  final AudioService _audioService = AudioService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  List<Verse> _currentVerses = [];
  Surah? _currentSurah;
  bool _isLoading = false;
  String _themeMode = 'system';
  String _currentLanguage = 'en';
  double _fontSize = 24.0;
  bool _showTranslation = false;
  bool _showTafsir = false;
  String _reciter = 'ar.alafasy';
  List<Reciter> _reciters = [];
  List<Bookmark> _bookmarks = [];
  LastRead? _lastRead;
  KhatmahGoal? _khatmahGoal;
  bool _dailyReminder = false;
  bool _prayerNotifications = true;

  List<Surah> get surahs => _surahs;
  List<Surah> get filteredSurahs => _filteredSurahs;
  List<Verse> get currentVerses => _currentVerses;
  Surah? get currentSurah => _currentSurah;
  bool get isLoading => _isLoading;
  String get themeMode => _themeMode;
  String get currentLanguage => _currentLanguage;
  double get fontSize => _fontSize;
  bool get showTranslation => _showTranslation;
  bool get showTafsir => _showTafsir;
  String get reciter => _reciter;
  List<Reciter> get reciters => _reciters;
  List<Bookmark> get bookmarks => _bookmarks;
  LastRead? get lastRead => _lastRead;
  KhatmahGoal? get khatmahGoal => _khatmahGoal;
  bool get dailyReminder => _dailyReminder;
  bool get prayerNotifications => _prayerNotifications;
  AudioService get audioService => _audioService;

  AppProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    await _storageService.initialize();
    await _notificationService.initialize();

    _themeMode = _storageService.getThemeMode();
    _currentLanguage = _storageService.getLanguage();
    _fontSize = _storageService.getFontSize();
    _showTranslation = _storageService.getShowTranslation();
    _showTafsir = _storageService.getShowTafsir();
    _reciter = _storageService.getReciter();
    _bookmarks = _storageService.getBookmarks();
    _lastRead = _storageService.getLastRead();
    _khatmahGoal = _storageService.getKhatmahGoal();
    _dailyReminder = _storageService.getDailyReminder();
    _prayerNotifications = _storageService.getPrayerNotifications();

    _surahs = await _quranApiService.getSurahs();
    _filteredSurahs = _surahs;
    _reciters = await _quranApiService.getReciters();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSurahVerses(int surahNumber) async {
    _isLoading = true;
    notifyListeners();

    _currentSurah = _surahs.firstWhere((s) => s.number == surahNumber);
    _currentVerses = await _quranApiService.getVerses(surahNumber, translation: _storageService.getTranslation());
    
    _isLoading = false;
    notifyListeners();
  }

  void filterSurahs(String query) {
    if (query.isEmpty) {
      _filteredSurahs = _surahs;
    } else {
      _filteredSurahs = _surahs
          .where((surah) =>
              surah.name.toLowerCase().contains(query.toLowerCase()) ||
              surah.englishName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void setThemeMode(String mode) {
    _themeMode = mode;
    _storageService.saveThemeMode(mode);
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    _storageService.saveLanguage(language);
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    _storageService.saveFontSize(size);
    notifyListeners();
  }

  void setShowTranslation(bool show) {
    _showTranslation = show;
    _storageService.saveShowTranslation(show);
    notifyListeners();
  }

  void setShowTafsir(bool show) {
    _showTafsir = show;
    _storageService.saveShowTafsir(show);
    notifyListeners();
  }

  void setReciter(String reciterId) {
    _reciter = reciterId;
    _storageService.saveReciter(reciterId);
    notifyListeners();
  }

  Reciter? getCurrentReciter() {
    return _reciters.firstWhere((r) => r.id == _reciter);
  }

  void toggleBookmark(int surahNumber, int ayahNumber) {
    final bookmark = Bookmark(surah: surahNumber, verse: ayahNumber);
    if (_bookmarks.contains(bookmark)) {
      _bookmarks.remove(bookmark);
    } else {
      _bookmarks.add(bookmark);
    }
    _storageService.saveBookmarks(_bookmarks);
    notifyListeners();
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return _bookmarks.contains(Bookmark(surah: surahNumber, verse: ayahNumber));
  }

  void setDailyReminder(bool enabled) {
    _dailyReminder = enabled;
    _storageService.saveDailyReminder(enabled);
    if (enabled) {
      _notificationService.scheduleDailyNotification(
        id: 0,
        title: 'Daily Quran Reminder',
        body: 'Time to read your daily portion of the Quran.',
        hour: 8,
        minute: 0,
      );
    } else {
      _notificationService.cancelNotification(0);
    }
    notifyListeners();
  }

  void setPrayerNotifications(bool enabled) {
    _prayerNotifications = enabled;
    _storageService.savePrayerNotifications(enabled);
    // Logic to schedule/cancel prayer notifications
    notifyListeners();
  }
}
