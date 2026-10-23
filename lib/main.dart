import 'package:flutter/material.dart';
import 'package:learning_map/openstreetmap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Maps',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      
      home:OpenstreetmapScreen()
    );
  }
}
