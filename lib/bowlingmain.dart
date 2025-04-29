// bowlingmain.dart
// 4/29/2025
// Leland Jones
// This is the main file for to run the bowling score calculator app.
// It initializes the app

import 'package:flutter/material.dart';
import 'bowlingview.dart';

/// This is the main function that runs the app.
void main() {
  runApp(FinalProject());
}

/// This is the main widget for the app.
class FinalProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BowlingScoreView(),
    );
  }
}
