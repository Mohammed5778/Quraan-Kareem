import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/juz.dart';

class QuranMeta {
  static List<Juz> _juzData = [];

  static Future<void> load() async {
    final String response = await rootBundle.loadString('assets/meta/juz.json');
    final data = await json.decode(response);
    _juzData = (data as List).map((item) => Juz.fromJson(item)).toList();
  }

  static List<Juz> get juz => _juzData;

  static int getJuzNumber(int surah, int ayah) {
    for (var juz in _juzData) {
      if (juz.hasVerse(surah, ayah)) {
        return juz.juzNumber;
      }
    }
    return 1;
  }

  static int getPageNumber(int surah, int ayah) {
    // This is a simplified mapping and may not be perfectly accurate.
    // A more precise mapping would require a larger dataset.
    if (surah == 1) return 1;
    if (surah == 2 && ayah <= 141) return (ayah / 8).ceil() + 1;
    // ... and so on
    return 1;
  }
}