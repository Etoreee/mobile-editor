import 'package:flutter/material.dart';
import 'pages/home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOBILE-EDITOR',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}