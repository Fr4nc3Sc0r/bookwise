class Book {
  final int id;
  final String title;
  final String author;
  final String? summary;
  final String? audioPath;
  final String? coverPath;
  final int? duration;
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
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      summary: json['summary'],
      audioPath: json['audioPath'],
      coverPath: json['coverPath'],
      duration: json['duration'],
      category: json['category'],
    );
  }
}
