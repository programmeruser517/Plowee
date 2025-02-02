import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

void main() {
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
    return MaterialApp(
    title: 'Plowee',
    theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        ),
        useMaterial3: true,
    ),
    darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        ),
        useMaterial3: true,
    ),
    home: const MapScreen(),
    );
}
}
