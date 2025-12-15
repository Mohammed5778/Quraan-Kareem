import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bookmark.dart';
import '../models/last_read.dart';
import '../models/khatmah_goal.dart';

class StorageService {
  static const String _bookmarksKey = 'bookmarks';
  static const String _lastReadKey = 'last_read';
  static const String _lastReadMarkerKey = 'last_read_marker';
  static const String _khatmahGoalKey = 'khatmah_goal';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _fontSizeKey = 'font_size';
  static const String _translationKey = 'translation';
  static const String _reciterKey = 'reciter';
  static const String _showTranslationKey = 'show_translation';
  static const String _showTafsirKey = 'show_tafsir';
  static const String _dailyReminderKey = 'daily_reminder';
  static const String _prayerNotificationsKey = 'prayer_notifications';

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Bookmarks
  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    final jsonList = bookmarks.map((b) => b.toJson()).toList();
    await _prefs.setString(_bookmarksKey, json.encode(jsonList));
  }

  List<Bookmark> getBookmarks() {
    final jsonString = _prefs.getString(_bookmarksKey);
    if (jsonString == null) return [];
    
    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((j) => Bookmark.fromJson(j)).toList();
  }

  // Last Read (auto-save position)
  Future<void> saveLastRead(LastRead lastRead) async {
    await _prefs.setString(_lastReadKey, json.encode(lastRead.toJson()));
  }

  LastRead? getLastRead() {
    final jsonString = _prefs.getString(_lastReadKey);
    if (jsonString == null) return null;
    return LastRead.fromJson(json.decode(jsonString));
  }

  // Last Read Marker (user-set marker)
  Future<void> saveLastReadMarker(LastRead marker) async {
    await _prefs.setString(_lastReadMarkerKey, json.encode(marker.toJson()));
  }

  LastRead? getLastReadMarker() {
    final jsonString = _prefs.getString(_lastReadMarkerKey);
    if (jsonString == null) return null;
    return LastRead.fromJson(json.decode(jsonString));
  }

  Future<void> clearLastReadMarker() async {
    await _prefs.remove(_lastReadMarkerKey);
  }

  // Khatmah Goal
  Future<void> saveKhatmahGoal(KhatmahGoal goal) async {
    await _prefs.setString(_khatmahGoalKey, json.encode(goal.toJson()));
  }

  KhatmahGoal? getKhatmahGoal() {
    final jsonString = _prefs.getString(_khatmahGoalKey);
    if (jsonString == null) return null;
    return KhatmahGoal.fromJson(json.decode(jsonString));
  }

  Future<void> clearKhatmahGoal() async {
    await _prefs.remove(_khatmahGoalKey);
  }

  // Theme
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  // Language
  Future<void> saveLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'ar';
  }

  // Font Size
  Future<void> saveFontSize(double size) async {
    await _prefs.setDouble(_fontSizeKey, size);
  }

  double getFontSize() {
    return _prefs.getDouble(_fontSizeKey) ?? 24.0;
  }

  // Translation
  Future<void> saveTranslation(String translation) async {
    await _prefs.setString(_translationKey, translation);
  }

  String getTranslation() {
    return _prefs.getString(_translationKey) ?? 'en.sahih';
  }

  // Reciter
  Future<void> saveReciter(String reciterId) async {
    await _prefs.setString(_reciterKey, reciterId);
  }

  String getReciter() {
    return _prefs.getString(_reciterKey) ?? 'ar.alafasy';
  }

  // Show Translation
  Future<void> saveShowTranslation(bool show) async {
    await _prefs.setBool(_showTranslationKey, show);
  }

  bool getShowTranslation() {
    return _prefs.getBool(_showTranslationKey) ?? false;
  }

  // Show Tafsir
  Future<void> saveShowTafsir(bool show) async {
    await _prefs.setBool(_showTafsirKey, show);
  }

  bool getShowTafsir() {
    return _prefs.getBool(_showTafsirKey) ?? false;
  }

  // Daily Reminder
  Future<void> saveDailyReminder(bool enabled) async {
    await _prefs.setBool(_dailyReminderKey, enabled);
  }

  bool getDailyReminder() {
    return _prefs.getBool(_dailyReminderKey) ?? false;
  }

  // Prayer Notifications
  Future<void> savePrayerNotifications(bool enabled) async {
    await _prefs.setBool(_prayerNotificationsKey, enabled);
  }

  bool getPrayerNotifications() {
    return _prefs.getBool(_prayerNotificationsKey) ?? true;
  }
}