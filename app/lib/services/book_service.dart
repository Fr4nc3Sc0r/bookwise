import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/book.dart';
import 'auth_manager.dart';

class BookService {
  //ip locale
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  static Future<Map<String, String>> getHeaders() async {
    final token = await AuthManager.getToken();
    return {
      'X-API-Key': apiKey,
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  //recupera tutti i libri
  Future<List<Book>> getBooks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Errore nel caricamento dei libri');
    }
  }

  Future<Book> getBook(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Libro non trovato');
    }
  }

  Future<void> deleteBook(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/books/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Libro non trovato');
    } else {
      throw Exception('Errore durante l\'eliminazione del libro');
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/search?q=$query'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Errore nella ricerca, libro inesistente');
    }
  }
}
