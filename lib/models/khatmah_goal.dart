enum KhatmahType { surah, page }

class KhatmahGoal {
  final KhatmahType type;
  final int start;
  final int end;
  final int duration;
  final DateTime startDate;

  KhatmahGoal({
    required this.type,
    required this.start,
    required this.end,
    required this.duration,
    required this.startDate,
  });

  factory KhatmahGoal.fromJson(Map<String, dynamic> json) {
    return KhatmahGoal(
      type: json['type'] == 'page' ? KhatmahType.page : KhatmahType.surah,
      start: json['start'] ?? 1,
      end: json['end'] ?? 114,
      duration: json['duration'] ?? 30,
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type == KhatmahType.page ? 'page' : 'surah',
      'start': start,
      'end': end,
      'duration': duration,
      'startDate': startDate.toIso8601String(),
    };
  }

  int get totalUnits => (end - start) + 1;
  double get dailyWird => totalUnits / duration;
}

class LastReadMarker {
  final int surah;
  final int ayah;
  final DateTime timestamp;

  LastReadMarker({
    required this.surah,
  required this.ayah,
    required this.timestamp,
  });

  factory LastReadMarker.fromJson(Map<String, dynamic> json) {
    return LastReadMarker(
      surah: json['surah'] ?? 1,
      ayah: json['ayah'] ?? 1,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah': surah,
      'ayah': ayah,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Bookmark {
  final int surah;
  final int ayah;
  final DateTime timestamp;

  Bookmark({
    required this.surah,
    required this.ayah,
    required this.timestamp,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      surah: json['surah'] ?? 1,
      ayah: json['ayah'] ?? 1,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah': surah,
      'ayah': ayah,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}