import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/zikr.dart';

class AzkarService {
  List<Zikr>? _cachedAzkar;
  Map<String, List<Zikr>>? _categorizedAzkar;

  // Load azkar from local JSON file
  Future<List<Zikr>> loadAzkar() async {
    if (_cachedAzkar != null) return _cachedAzkar!;

    try {
      final jsonString = await rootBundle.loadString('assets/data/azkar.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedAzkar = jsonList.map((json) => Zikr.fromJson(json)).toList();
      return _cachedAzkar!;
    } catch (e) {
      // Return default azkar if file not found
      return _getDefaultAzkar();
    }
  }

  // Get azkar by category
  Future<List<Zikr>> getAzkarByCategory(String category) async {
    final allAzkar = await loadAzkar();
    return allAzkar.where((zikr) => zikr.category == category).toList();
  }

  // Get categorized azkar
  Future<Map<String, List<Zikr>>> getCategorizedAzkar() async {
    if (_categorizedAzkar != null) return _categorizedAzkar!;

    final allAzkar = await loadAzkar();
    _categorizedAzkar = {};

    for (var zikr in allAzkar) {
      if (_categorizedAzkar!.containsKey(zikr.category)) {
        _categorizedAzkar![zikr.category]!.add(zikr);
      } else {
        _categorizedAzkar![zikr.category] = [zikr];
      }
    }

    return _categorizedAzkar!;
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    final categorized = await getCategorizedAzkar();
    return categorized.keys.toList();
  }

  // Default azkar data
  List<Zikr> _getDefaultAzkar() {
    return [
      // أذكار الصباح
      Zikr(
        id: 1,
        category: 'أذكار الصباح',
        categoryEnglish: 'Morning Azkar',
        text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        translation: 'We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshipped except Allah, alone, without partner, to Him belongs all sovereignty and praise and He is over all things omnipotent.',
        count: 1,
        reference: 'مسلم',
        virtue: 'من قالها حين يصبح وحين يمسي كان حقاً على الله أن يرضيه يوم القيامة',
      ),
      Zikr(
        id: 2,
        category: 'أذكار الصباح',
        categoryEnglish: 'Morning Azkar',
        text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
        translation: 'O Allah, by Your leave we have reached the morning and by Your leave we have reached the evening, by Your leave we live and die and unto You is our resurrection.',
        count: 1,
        reference: 'الترمذي',
        virtue: '',
      ),
      Zikr(
        id: 3,
        category: 'أذكار الصباح',
        categoryEnglish: 'Morning Azkar',
        text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        translation: 'Glory is to Allah and praise is to Him.',
        count: 100,
        reference: 'مسلم',
        virtue: 'من قالها مائة مرة حين يصبح وحين يمسي لم يأت أحد يوم القيامة بأفضل مما جاء به',
      ),

      // أذكار المساء
      Zikr(
        id: 4,
        category: 'أذكار المساء',
        categoryEnglish: 'Evening Azkar',
        text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        translation: 'We have reached the evening and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshipped except Allah, alone, without partner, to Him belongs all sovereignty and praise and He is over all things omnipotent.',
        count: 1,
        reference: 'مسلم',
        virtue: '',
      ),
      Zikr(
        id: 5,
        category: 'أذكار المساء',
        categoryEnglish: 'Evening Azkar',
        text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
        translation: 'O Allah, by Your leave we have reached the evening and by Your leave we have reached the morning, by Your leave we live and die and unto You is our return.',
        count: 1,
        reference: 'الترمذي',
        virtue: '',
      ),

      // أذكار النوم
      Zikr(
        id: 6,
        category: 'أذكار النوم',
        categoryEnglish: 'Sleep Azkar',
        text: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        translation: 'In Your name O Allah, I die and I live.',
        count: 1,
        reference: 'البخاري',
        virtue: '',
      ),
      Zikr(
        id: 7,
        category: 'أذكار النوم',
        categoryEnglish: 'Sleep Azkar',
        text: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
        translation: 'O Allah, protect me from Your punishment on the Day You resurrect Your servants.',
        count: 3,
        reference: 'أبو داود والترمذي',
        virtue: 'كان النبي ﷺ يقولها إذا أراد أن ينام',
      ),

      // أذكار الاستيقاظ
      Zikr(
        id: 8,
        category: 'أذكار الاستيقاظ',
        categoryEnglish: 'Waking Up Azkar',
        text: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
        translation: 'All praise is for Allah who gave us life after having taken it from us and unto Him is the resurrection.',
        count: 1,
        reference: 'البخاري',
        virtue: '',
      ),

      // أذكار بعد الصلاة
      Zikr(
        id: 9,
        category: 'أذكار بعد الصلاة',
        categoryEnglish: 'After Prayer Azkar',
        text: 'أَسْتَغْفِرُ اللهَ',
        translation: 'I seek Allah\'s forgiveness.',
        count: 3,
        reference: 'مسلم',
        virtue: '',
      ),
      Zikr(
        id: 10,
        category: 'أذكار بعد الصلاة',
        categoryEnglish: 'After Prayer Azkar',
        text: 'اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
        translation: 'O Allah, You are Peace and from You is peace. Blessed are You, O Possessor of Glory and Honor.',
        count: 1,
        reference: 'مسلم',
        virtue: '',
      ),
      Zikr(
        id: 11,
        category: 'أذكار بعد الصلاة',
        categoryEnglish: 'After Prayer Azkar',
        text: 'سُبْحَانَ اللهِ',
        translation: 'Glory is to Allah.',
        count: 33,
        reference: 'مسلم',
        virtue: 'التسبيح والتحميد والتكبير بعد كل صلاة',
      ),
      Zikr(
        id: 12,
        category: 'أذكار بعد الصلاة',
        categoryEnglish: 'After Prayer Azkar',
        text: 'الْحَمْدُ لِلَّهِ',
        translation: 'All praise is for Allah.',
        count: 33,
        reference: 'مسلم',
        virtue: '',
      ),
      Zikr(
        id: 13,
        category: 'أذكار بعد الصلاة',
        categoryEnglish: 'After Prayer Azkar',
        text: 'اللهُ أَكْبَرُ',
        translation: 'Allah is the Greatest.',
        count: 34,
        reference: 'مسلم',
        virtue: '',
      ),

      // أذكار متنوعة
      Zikr(
        id: 14,
        category: 'أذكار متنوعة',
        categoryEnglish: 'Various Azkar',
        text: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        translation: 'None has the right to be worshipped except Allah, alone, without partner, to Him belongs all sovereignty and praise and He is over all things omnipotent.',
        count: 100,
        reference: 'البخاري ومسلم',
        virtue: 'كانت له عدل عشر رقاب، وكتبت له مائة حسنة، ومحيت عنه مائة سيئة، وكانت له حرزاً من الشيطان',
      ),
      Zikr(
        id: 15,
        category: 'أذكار متنوعة',
        categoryEnglish: 'Various Azkar',
        text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ الْعَظِيمِ',
        translation: 'Glory is to Allah and praise is to Him. Glory is to Allah, the Most Great.',
        count: 0,
        reference: 'البخاري ومسلم',
        virtue: 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن',
      ),

      // دعاء الدخول إلى المسجد
      Zikr(
        id: 16,
        category: 'أدعية الدخول والخروج',
        categoryEnglish: 'Entry and Exit Duas',
        text: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
        translation: 'O Allah, open the gates of Your mercy for me.',
        count: 1,
        reference: 'مسلم',
        virtue: 'دعاء الدخول إلى المسجد',
      ),
      Zikr(
        id: 17,
        category: 'أدعية الدخول والخروج',
        categoryEnglish: 'Entry and Exit Duas',
        text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
        translation: 'O Allah, I ask You from Your favor.',
        count: 1,
        reference: 'مسلم',
        virtue: 'دعاء الخروج من المسجد',
      ),
    ];
  }
}