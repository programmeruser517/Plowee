import 'package:flutter/material.dart';
import 'dart:async';
import 'map_screen.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
@override
void initState() {
    super.initState();
    Timer(
    const Duration(seconds: 3),
    () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
        builder: (context) => const MapScreen(),
        ),
    ),
    );
}

@override
Widget build(BuildContext context) {
    return Scaffold(
    body: Container(
        decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/image.jpg'),
            fit: BoxFit.cover,
        ),
        ),
    ),
    );
}
}

