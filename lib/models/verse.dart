class Verse {
  final int number;
  final int numberInSurah;
  final String text;
  final int surahNumber;
  final Map<String, String> translations;
  final Map<String, String> tafsirs;

  Verse({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.surahNumber,
    this.translations = const {},
    this.tafsirs = const {},
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: json['number'] ?? 0,
      numberInSurah: json['numberInSurah'] ?? 0,
      text: json['text'] ?? '',
      surahNumber: json['surah']?['number'] ?? json['surahNumber'] ?? 0,
      translations: Map<String, String>.from(json['translations'] ?? {}),
      tafsirs: Map<String, String>.from(json['tafsirs'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'numberInSurah': numberInSurah,
      'text': text,
      'surahNumber': surahNumber,
      'translations': translations,
      'tafsirs': tafsirs,
    };
  }
}