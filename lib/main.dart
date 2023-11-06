import 'package:flutter/material.dart';
import 'package:skribble/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scribble Clone',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            background: Color.fromARGB(255, 18, 18, 18),
          ),
          useMaterial3: true,
        ),
        home: const HomePage());
  }
}
