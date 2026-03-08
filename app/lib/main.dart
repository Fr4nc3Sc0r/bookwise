import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BookwiseApp());
}

class BookwiseApp extends StatelessWidget {
  const BookwiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookwise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
