import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Editor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          maxLines: null, // Необмежена кількість рядків
          expands: true, // Поле займає весь доступний простір
          style: GoogleFonts.robotoMono(), // Використовуємо моноширний шрифт Roboto Mono
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Start type',
          ),
        ),
      ),
    );
  }
}