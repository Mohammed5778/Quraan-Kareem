class Reciter {
  final String id;
  final String name;
  final String? server;
  final List<int> surahList;

  Reciter({
    required this.id,
    required this.name,
    this.server,
    this.surahList = const [],
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    final moshaf = json['moshaf'] as List?;
    String? server;
    List<int> surahList = [];
    
    if (moshaf != null && moshaf.isNotEmpty) {
      server = moshaf[0]['server'];
      final surahListStr = moshaf[0]['surah_list'] as String?;
      if (surahListStr != null) {
        surahList = surahListStr.split(',').map((s) => int.tryParse(s) ?? 0).toList();
      }
    }
    
    return Reciter(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      server: server,
      surahList: surahList,
    );
  }

  bool hasSurah(int surahNumber) => surahList.contains(surahNumber);
}