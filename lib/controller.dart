// controller.dart

import 'package:flutter/material.dart';
import 'model.dart';

class BowlingScoreController {
  final BowlingScoreModel model;
  final VoidCallback updateUI;

  BowlingScoreController(this.model, this.updateUI);

  void ballInputChanged(int frameIndex) {
    model.calculateScores();
    model.checkFrameTotal(frameIndex);
    updateUI();
  }

  void resetPressed() {
    model.resetGame();
    updateUI();
  }

  void loadScores() {
    model.loadScoresFromAsset().then((_) {
      updateUI();
    });
  }
}
