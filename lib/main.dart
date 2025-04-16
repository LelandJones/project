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

// --- Model ---
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

  void resetGame() {
    for (var controllerList in scoreControllers) {
      for (var controller in controllerList) {
        controller.clear();
      }
    }
    scores.fillRange(0, 10, 0);
  }

  int get totalScore => scores.reduce((a, b) => a + b);

  int _getRoll(int frame, int roll) {
    if (frame >= scoreControllers.length) return 0;
    if (roll >= scoreControllers[frame].length) return 0;
    return int.tryParse(scoreControllers[frame][roll].text) ?? 0;
  }

  int _strikeBonus(int frame) {
    if (frame >= 9) return 0;
    if (frame == 8) {
      int nextRoll1 = _getRoll(frame + 1, 0);
      int nextRoll2 = _getRoll(frame + 1, 1);
      return nextRoll1 + nextRoll2;
    }
    int nextRoll1 = _getRoll(frame + 1, 0);
    int nextRoll2 = 0;
    if (nextRoll1 == 10) {
      nextRoll2 = _getRoll(frame + 2, 0);
    } else {
      nextRoll2 = _getRoll(frame + 1, 1);
    }
    return nextRoll1 + nextRoll2;
  }

  bool enableSecondBall(int frameIndex) {
    String firstInput = scoreControllers[frameIndex][0].text;

    if (frameIndex == 9) {
      return firstInput.isNotEmpty;
    }

    return firstInput.isNotEmpty && int.tryParse(firstInput) != 10;
  }

  bool tenthFrameThirdBall() {
    String secondText = scoreControllers[9][1].text;
    if (secondText.isEmpty) return false;

    int first = _getRoll(9, 0);
    int second = _getRoll(9, 1);

    // Enable third ball if the first ball is a strike,
    // or the second ball is a strike (regardless of the first ball).
    return (first == 10) || (second == 10) || (first + second == 10);
  }
}

// --- Controller ---
class BowlingScoreController {
  final BowlingScoreModel model;
  final VoidCallback updateUI;

  BowlingScoreController(this.model, this.updateUI);

  void ballInputChanged(int frameIndex) {
    model.calculateScores();
    updateUI();
  }

  void resetPressed() {
    model.resetGame();
    updateUI();
  }
}

// --- View ---
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
      appBar: AppBar(
        title: Text('🎳 Bowling Scorecard'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
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
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "Frame ${index + 1}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTextField(
                                  model.scoreControllers[index][0],
                                  "B1",
                                  index,
                                ),
                                _buildTextField(
                                  model.scoreControllers[index][1],
                                  "B2",
                                  index,
                                  enabled: model.enableSecondBall(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "Frame ${frameIndex + 1}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTextField(
                                  model.scoreControllers[frameIndex][0],
                                  "B1",
                                  frameIndex,
                                ),
                                _buildTextField(
                                  model.scoreControllers[frameIndex][1],
                                  "B2",
                                  frameIndex,
                                  enabled: model.enableSecondBall(frameIndex),
                                ),
                                if (index == 4)
                                  _buildTextField(
                                    model.scoreControllers[9][2],
                                    "B3",
                                    9,
                                    enabled: model.tenthFrameThirdBall(),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              Divider(thickness: 2),
              SizedBox(height: 10),
              Text(
                "Total Score: ${model.totalScore}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: controller.resetPressed,
                icon: Icon(Icons.refresh),
                label: Text("Reset"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    int frameIndex, {
    bool enabled = true,
  }) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[300],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onChanged: (_) => this.controller.ballInputChanged(frameIndex),
      ),
    );
  }
}
