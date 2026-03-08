import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  //ip locale
  static const String baseUrl = 'http://127.0.0.1:8000';

  //recupera tutti i libri
  Future<List<Book>> getBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Errore nel caricamento dei libri');
    }
  }

  Future<Book> getBook(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/books/$id'));

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Libro non trovato');
    }
  }

  Future<void> deleteBook(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/books/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Libro non trovato');
    } else {
      throw Exception('Errore durante l\'eliminazione del libro');
    }
  }
}
