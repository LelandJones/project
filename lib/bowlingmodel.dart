// model.dart
// 4/29/2025
// Leland Jones
// This is the model file for the bowling score calculator app.
// It handles the logic for calculating scores and managing the state of the game.

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

// BowlingScoreModel is responsible for managing the state of the bowling game
// It contains a list of TextEditingControllers for each frame's rolls
// It also contains a list of scores, an error message, and methods to calculate scores, load scores from assets, reset the game, and check frame totals
class BowlingScoreModel {
  List<List<TextEditingController>> scoreControllers = List.generate(
    9,
    (_) => [TextEditingController(), TextEditingController()],
  )..add([
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ]);

  //Makes sure the inputs for the rolls is between 0 and 10, otherwise it outputs an error message
  List<int> scores = List.filled(10, 0);
  String errorMessage = '';

  // calculateScores calculates the scores for each frame based on the rolls entered
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

  // loadScoresFromAsset loads the scores from a JSON file and fills the TextEditingControllers with the data
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

  // resetGame resets the game by clearing all TextEditingControllers and scores
  void resetGame() {
    for (var frame in scoreControllers) {
      for (var controller in frame) {
        controller.clear();
      }
    }
    scores = List.filled(10, 0);
    errorMessage = '';
  }

  // totalScore calculates the total score by summing up the scores of all frames
  int get totalScore => scores.reduce((a, b) => a + b);

  // _getRoll retrieves the roll value from the TextEditingController for a specific frame and roll
  // It returns 0 if the frame or roll is out of bounds or if the value is not a valid integer
  int _getRoll(int frame, int roll) {
    if (frame >= scoreControllers.length ||
        roll >= scoreControllers[frame].length) {
      return 0;
    }
    final value = int.tryParse(scoreControllers[frame][roll].text) ?? 0;
    return value < 0 ? 0 : value;
  }

  // _strikeBonus calculates the bonus score for a strike in the current frame
  int _strikeBonus(int frame) {
    if (frame >= 9) return 0;
    int first = _getRoll(frame + 1, 0);
    int second =
        (first == 10 && frame < 8)
            ? _getRoll(frame + 2, 0)
            : _getRoll(frame + 1, 1);
    return first + second;
  }

  // enableSecondBall checks if the second ball is enabled for a specific frame
  // It returns true if the frame is the 10th frame or if the first roll is not a strike
  bool enableSecondBall(int frame) {
    int first = _getRoll(frame, 0);
    return frame == 9 || (first != 10);
  }

  // tenthFrameThirdBall checks if the third ball is enabled for the 10th frame
  // It returns true if the first or second roll is a strike or if they add up to a spare
  bool tenthFrameThirdBall() {
    int first = _getRoll(9, 0);
    int second = _getRoll(9, 1);
    return first == 10 || second == 10 || (first + second == 10);
  }

  // checkFrameTotal checks if the total score for a frame exceeds 10 pins
  // It clears the TextEditingControllers if the total is invalid and sets an error message
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
