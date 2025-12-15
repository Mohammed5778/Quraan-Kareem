import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/reciter.dart';

class ApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<Surah>> getSurahs() async {
    final response = await http.get(Uri.parse('$_baseUrl/surah'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> surahs = data['data'];
      return surahs.map((json) => Surah.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  Future<List<Ayah>> getAyahs(int surahNumber, {String reciter = 'ar.alafasy'}) async {
    final response = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber/editions/$reciter'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ayahsData = data['data'][0]['ayahs'];
      return ayahsData.map((json) => Ayah.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ayahs');
    }
  }

  Future<List<Reciter>> getReciters() async {
    final response = await http.get(Uri.parse('$_baseUrl/edition/format/audio'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> reciters = data['data'];
      return reciters.map((json) => Reciter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reciters');
    }
  }
}