import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/last_read.dart';
import '../models/bookmark.dart';
import '../models/khatmah_goal.dart';

class LocalStorageService {
  static const String _lastRead = 'lastRead';
  static const String _bookmarks = 'bookmarks';
  static const String _khatmahGoal = 'khatmahGoal';
  static const String _themeMode = 'themeMode';
  static const String _fontSize = 'fontSize';
  static const String _showTranslation = 'showTranslation';
  static const String _showTafsir = 'showTafsir';
  static const String _reciter = 'reciter';

  Future<void> saveLastRead(LastRead lastRead) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_lastRead, json.encode(lastRead.toJson()));
  }

  Future<LastRead?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadString = prefs.getString(_lastRead);
    if (lastReadString != null) {
      return LastRead.fromJson(json.decode(lastReadString));
    }
    return null;
  }

  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksString = json.encode(bookmarks.map((b) => b.toJson()).toList());
    prefs.setString(_bookmarks, bookmarksString);
  }

  Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksString = prefs.getString(_bookmarks);
    if (bookmarksString != null) {
      final List<dynamic> bookmarksJson = json.decode(bookmarksString);
      return bookmarksJson.map((json) => Bookmark.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveKhatmahGoal(KhatmahGoal khatmahGoal) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_khatmahGoal, json.encode(khatmahGoal.toJson()));
  }

  Future<KhatmahGoal?> getKhatmahGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final khatmahGoalString = prefs.getString(_khatmahGoal);
    if (khatmahGoalString != null) {
      return KhatmahGoal.fromJson(json.decode(khatmahGoalString));
    }
    return null;
  }

  Future<void> deleteKhatmahGoal() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_khatmahGoal);
  }

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_themeMode, themeMode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeMode);
  }

  Future<void> saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_fontSize, fontSize);
  }

  Future<double?> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSize);
  }

  Future<void> saveShowTranslation(bool showTranslation) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_showTranslation, showTranslation);
  }

  Future<bool?> getShowTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showTranslation);
  }

  Future<void> saveShowTafsir(bool showTafsir) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_showTafsir, showTafsir);
  }

  Future<bool?> getShowTafsir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showTafsir);
  }

  Future<void> saveReciter(String reciter) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_reciter, reciter);
  }

  Future<String?> getReciter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_reciter);
  }
}