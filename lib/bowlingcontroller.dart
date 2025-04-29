// controller.dart
// 4/29/2025
// Leland Jones
// This is the controller file for the bowling score calculator app.
// It handles user input and updates the model accordingly.

import 'package:flutter/material.dart';
import 'bowlingmodel.dart';

class BowlingScoreController {
  final BowlingScoreModel
  model; // The model that contains the game logic and state
  final VoidCallback
  updateUI; // A callback function to update the UI when the model changes

  BowlingScoreController(this.model, this.updateUI);

  // This method is called when the user inputs a score for a roll
  // It updates the model with the new score and checks if the frame total is valid
  void ballInputChanged(int frameIndex) {
    model.calculateScores();
    model.checkFrameTotal(frameIndex);
    updateUI();
  }

  // This method is called when the user presses the reset button
  void resetPressed() {
    model.resetGame();
    updateUI();
  }

  // This method is called to load scores from a JSON file in the assets folder
  void loadScores() {
    model.loadScoresFromAsset().then((_) {
      updateUI();
    });
  }
}
