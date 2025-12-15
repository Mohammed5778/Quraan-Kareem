import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/surah.dart';
import '../models/verse.dart';
import '../models/reciter.dart';

class QuranApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _quranUrl = 'https://api.quran.com/api/v4';
  
  // Get all surahs
  Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/surah'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahsJson = data['data'];
        return surahsJson.map((json) => Surah.fromJson(json)).toList();
      }
      throw Exception('Failed to load surahs');
    } catch (e) {
      throw Exception('Error fetching surahs: $e');
    }
  }

  // Get verses of a surah
  Future<List<Verse>> getVerses(int surahNumber, {String? translation}) async {
    try {
      // Get Arabic text
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
        )).toList();
      }

      // Get translation if requested
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
      throw Exception('Error fetching verses: $e');
    }
  }

  // Get tafsir
  Future<List<Verse>> getTafsir(int surahNumber, String tafsirEdition) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surah/$surahNumber/$tafsirEdition'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ayahs = data['data']['ayahs'];
        
        return ayahs.map((ayah) => Verse(
          number: ayah['number'],
          numberInSurah: ayah['numberInSurah'],
          text: '',
          tafsir: ayah['text'],
          juz: ayah['juz'],
          page: ayah['page'],
          hizbQuarter: ayah['hizbQuarter'],
        )).toList();
      }
      throw Exception('Failed to load tafsir');
    } catch (e) {
      throw Exception('Error fetching tafsir: $e');
    }
  }

  // Search in Quran
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

  // Get available reciters
  Future<List<Reciter>> getReciters() async {
    // Return predefined reciters with their audio URLs
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
        id: 'ar.minshawi',
        name: 'محمد صديق المنشاوي',
        englishName: 'Mohamed Siddiq Al-Minshawi',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.minshawi/',
      ),
      Reciter(
        id: 'ar.husary',
        name: 'محمود خليل الحصري',
        englishName: 'Mahmoud Khalil Al-Husary',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.husary/',
      ),
      Reciter(
        id: 'ar.sudais',
        name: 'عبد الرحمن السديس',
        englishName: 'Abdurrahman As-Sudais',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.abdurrahmansudais/',
      ),
      Reciter(
        id: 'ar.shuraym',
        name: 'سعود الشريم',
        englishName: 'Saud Al-Shuraim',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.shuraym/',
      ),
      Reciter(
        id: 'ar.mahermuaiqly',
        name: 'ماهر المعيقلي',
        englishName: 'Maher Al Muaiqly',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.mahermuaiqly/',
      ),
      Reciter(
        id: 'ar.ahmedajamy',
        name: 'أحمد العجمي',
        englishName: 'Ahmed Al Ajamy',
        style: 'Murattal',
        audioBaseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.ahmedajamy/',
      ),
    ];
  }

  // Get Quran page image
  String getPageImageUrl(int pageNumber) {
    final paddedPage = pageNumber.toString().padLeft(3, '0');
    return 'https://www.searchtruth.org/quran/images2/large/page-$paddedPage.jpeg';
  }

  // Get verse audio URL
  String getVerseAudioUrl(Reciter reciter, int verseNumber) {
    return '${reciter.audioBaseUrl}$verseNumber.mp3';
  }
}