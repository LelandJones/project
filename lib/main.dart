import 'package:flutter/material.dart';

void main() {
  runApp(FinalProject());
}

class FinalProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BowlingScoreView(),
    );
  }
}

class BowlingScoreModel {
  List<List<TextEditingController>> scoreControllers = List.generate(
    9,
    (_) => [TextEditingController(), TextEditingController()],
  )..add([
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ]);

  List<int> scores = List.generate(10, (_) => 0);

  void calculateScores() {
    scores = List.generate(10, (_) => 0);

    for (int i = 0; i < 10; i++) {
      int first = _getRoll(i, 0);
      int second = _getRoll(i, 1);
      int third = i == 9 ? _getRoll(i, 2) : 0;

      // Handle the 10th frame (adding all three rolls)
      if (i == 9) {
        scores[i] = first + second + third;
      }
      // Strike in any frame (1-9)
      else if (first == 10) {
        scores[i] = 10 + _strikeBonus(i);
      }
      // Spare in any frame (1-9)
      else if (first + second == 10) {
        scores[i] = 10 + _getRoll(i + 1, 0);
      }
      // Open frame (no strike or spare)
      else {
        scores[i] = first + second;
      }
    }
  }

  int get totalScore => scores.reduce((a, b) => a + b);

  // ---------- Helpers ----------

  /// Returns the roll value from a specific frame and roll index
  int _getRoll(int frame, int roll) {
    if (frame >= scoreControllers.length) return 0;
    if (roll >= scoreControllers[frame].length) return 0;
    return int.tryParse(scoreControllers[frame][roll].text) ?? 0;
  }

  /// Calculate the strike bonus: next two rolls after a strike
  int _strikeBonus(int frame) {
    // If it's the 10th frame, no bonus
    if (frame >= 9) return 0;

    // If frame 9 is a strike, get the next two rolls
    if (frame == 8) {
      int nextRoll1 = _getRoll(frame + 1, 0); // First roll of frame 10
      int nextRoll2 = _getRoll(frame + 1, 1); // Second roll of frame 10
      return nextRoll1 + nextRoll2;
    }

    // For other frames (1-8), normal strike bonus calculation
    int nextRoll1 = _getRoll(frame + 1, 0);
    int nextRoll2 = 0;

    // If the next frame is a strike, look ahead to the frame after that
    if (nextRoll1 == 10) {
      nextRoll2 = _getRoll(frame + 2, 0);
    } else {
      nextRoll2 = _getRoll(frame + 1, 1);
    }

    return nextRoll1 + nextRoll2;
  }
}

class BowlingScoreController {
  final BowlingScoreModel model;
  final VoidCallback updateUI;

  BowlingScoreController(this.model, this.updateUI);

  void onBallInputChanged(int frameIndex) {
    model.calculateScores();
    updateUI();
  }
}

class BowlingScoreView extends StatefulWidget {
  @override
  _BowlingScoreViewState createState() => _BowlingScoreViewState();
}

class _BowlingScoreViewState extends State<BowlingScoreView> {
  final BowlingScoreModel model = BowlingScoreModel();
  late BowlingScoreController controller;

  @override
  void initState() {
    super.initState();
    controller = BowlingScoreController(model, _updateUI);
  }

  void _updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bowling Scorecard')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Frames 1–5
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          "Frame ${index + 1}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            _buildTextField(
                              model.scoreControllers[index][0],
                              "Ball 1",
                              index,
                            ),
                            _buildTextField(
                              model.scoreControllers[index][1],
                              "Ball 2",
                              index,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // Frames 6–10
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  int frameIndex = index + 5;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          "Frame ${frameIndex + 1}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            _buildTextField(
                              model.scoreControllers[frameIndex][0],
                              "Ball 1",
                              frameIndex,
                            ),
                            _buildTextField(
                              model.scoreControllers[frameIndex][1],
                              "Ball 2",
                              frameIndex,
                            ),
                            if (index == 4)
                              _buildTextField(
                                model.scoreControllers[9][2],
                                "Ball 3",
                                9,
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
              Text(
                "Total Score: ${model.totalScore}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    int frameIndex,
  ) {
    return Container(
      width: 50,
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => this.controller.onBallInputChanged(frameIndex),
      ),
    );
  }
}
