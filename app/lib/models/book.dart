class Book {
  final int id;
  final String title;
  final String author;
  final String? summary;
  final String? audioPath;
  final String? coverPath;
  final int duration;
  final String? category;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.summary,
    this.audioPath,
    this.coverPath,
    this.duration,
    this.category,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    String _parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      return value.toString();
    }

    return Book(
      id: _parseInt(json['id']),
      title: _parseString(json['title']),
      author: _parseString(json['author']),
      summary: json.containsKey('summary') ? _parseString(json['summary']) : null,
      audioPath: json.containsKey('audioPath') ? _parseString(json['audioPath']) : null,
      coverPath: json.containsKey('coverPath') ? _parseString(json['coverPath']) : null,
      duration: _parseInt(json['duration']) _parseString(json['duration']) : null,
      category: json.containsKey('category') ? _parseString(json['category']) : null,
    );
  }
}
