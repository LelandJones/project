// model.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class BowlingScoreModel {
  List<List<TextEditingController>> scoreControllers = List.generate(
    9,
    (_) => [TextEditingController(), TextEditingController()],
  )..add([
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ]);

  List<int> scores = List.filled(10, 0);
  String errorMessage = '';

  void calculateScores() {
    scores = List.filled(10, 0);
    errorMessage = '';

    for (int i = 0; i < 10; i++) {
      int first = _getRoll(i, 0);
      int second = _getRoll(i, 1);
      int third = i == 9 ? _getRoll(i, 2) : 0;

      if (i == 9) {
        scores[i] = first + second + third;
      } else if (first == 10) {
        scores[i] = 10 + _strikeBonus(i);
      } else if (first + second == 10) {
        scores[i] = 10 + _getRoll(i + 1, 0);
      } else {
        scores[i] = first + second;
      }
    }
  }

  Future<void> loadScoresFromAsset() async {
    final String jsonString = await rootBundle.loadString(
      'assets/bowling_data.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    final List<dynamic> frames = jsonMap['frames'];

    for (int i = 0; i < frames.length && i < scoreControllers.length; i++) {
      List<dynamic> rolls = frames[i]['rolls'];
      for (int j = 0; j < rolls.length && j < scoreControllers[i].length; j++) {
        scoreControllers[i][j].text = rolls[j].toString();
      }
    }

    calculateScores();
  }

  void resetGame() {
    for (var frame in scoreControllers) {
      for (var controller in frame) {
        controller.clear();
      }
    }
    scores = List.filled(10, 0);
    errorMessage = '';
  }

  int get totalScore => scores.reduce((a, b) => a + b);

  int _getRoll(int frame, int roll) {
    if (frame >= scoreControllers.length ||
        roll >= scoreControllers[frame].length)
      return 0;
    return int.tryParse(scoreControllers[frame][roll].text) ?? 0;
  }

  int _strikeBonus(int frame) {
    if (frame >= 9) return 0;
    int first = _getRoll(frame + 1, 0);
    int second =
        (first == 10 && frame < 8)
            ? _getRoll(frame + 2, 0)
            : _getRoll(frame + 1, 1);
    return first + second;
  }

  bool enableSecondBall(int frame) {
    int first = _getRoll(frame, 0);
    return frame == 9 || (first != 10);
  }

  bool tenthFrameThirdBall() {
    int first = _getRoll(9, 0);
    int second = _getRoll(9, 1);
    return first == 10 || second == 10 || (first + second == 10);
  }

  void checkFrameTotal(int frame) {
    int first = _getRoll(frame, 0);
    int second = _getRoll(frame, 1);
    int third = frame == 9 ? _getRoll(frame, 2) : 0;

    if (frame < 9 && first + second > 10) {
      errorMessage = 'Frame total can’t exceed 10 pins.';
      scoreControllers[frame][0].clear();
      scoreControllers[frame][1].clear();
    } else if (frame == 9 && (first > 10 || second > 10 || third > 10)) {
      errorMessage = 'Each ball in 10th frame must be ≤ 10 pins.';
      scoreControllers[frame][0].clear();
      scoreControllers[frame][1].clear();
    } else {
      errorMessage = '';
    }
  }
}
