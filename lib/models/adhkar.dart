class AdhkarCategory {
  final int id;
  final String category;
  final List<AdhkarItem> items;

  AdhkarCategory({
    required this.id,
    required this.category,
    required this.items,
  });

  factory AdhkarCategory.fromJson(Map<String, dynamic> json) {
    return AdhkarCategory(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      items: (json['array'] as List?)
          ?.map((item) => AdhkarItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class AdhkarItem {
  final int id;
  final String text;
  final int count;
  final String? audio;
  final String? description;

  AdhkarItem({
    required this.id,
    required this.text,
    required this.count,
    this.audio,
    this.description,
  });

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      count: json['count'] ?? 1,
      audio: json['audio'],
      description: json['description'],
    );
  }
}