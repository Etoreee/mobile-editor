import 'package:flutter/material.dart';
import 'package:mobile_red/pages/project_list.dart';

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOBILE-EDITOR',
      theme: ThemeData.dark(),
      home: ProjectList(), 
    );
  }
}