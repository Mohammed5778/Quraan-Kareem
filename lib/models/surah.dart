class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int versesCount;
  final String revelationType;
  bool isBookmarked;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.versesCount,
    required this.revelationType,
    this.isBookmarked = false,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      versesCount: json['numberOfAyahs'] ?? json['versesCount'] ?? 0,
      revelationType: json['revelationType'] ?? '',
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'versesCount': versesCount,
      'revelationType': revelationType,
      'isBookmarked': isBookmarked,
    };
  }

  bool get isMeccan => revelationType == 'Meccan';
  bool get isMedinan => revelationType == 'Medinan';
}