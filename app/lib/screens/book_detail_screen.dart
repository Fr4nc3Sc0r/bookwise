import 'package:flutter/material.dart';
import '../models/book.dart';
import 'player_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  String _formatDuration(int? seconds) {
    if (seconds == null) return '';
    final minutes = seconds ~/ 60;
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Dettaglio Libro',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //copertina placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.book, size: 80, color: Colors.orange),
            ),
            const SizedBox(height: 24),

            //Titolo
            Text(
              book.title,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 8),

            //Autore
            Text(
              book.author,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 8),

            //  Categoria e durata
            Row(
              children: [
                if (book.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      book.category!,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                const SizedBox(width: 12),
                if (book.duration != null)
                  Text(
                    _formatDuration(book.duration),
                    style: TextStyle(color: Colors.grey[400]),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            //Riassunto
            if (book.summary != null) ...[
              const Text(
                'Riassunto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                book.summary!,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.headphones, color: Colors.white),
                label: const Text(
                  'Ascolta il riassunto',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(book: book),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
