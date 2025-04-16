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
  String errorMessage = '';

  void calculateScores() {
    scores = List.generate(10, (_) => 0);
    errorMessage = ''; // Reset error message on score calculation.

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
    errorMessage = ''; // Clear error message
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

    // For the 10th frame, we always allow input on the second ball.
    if (frameIndex == 9) {
      return firstInput.isNotEmpty;
    }

    int first = _getRoll(frameIndex, 0);
    int second = _getRoll(frameIndex, 1);

    // Enable second ball only if the first ball isn't a strike and their sum is <= 10
    return first != 10 && first + second <= 10;
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

  void checkFrameTotal(int frameIndex) {
    String firstInput = scoreControllers[frameIndex][0].text;
    String secondInput = scoreControllers[frameIndex][1].text;
    String thirdInput = scoreControllers[frameIndex][2].text;

    int firstBall = int.tryParse(firstInput) ?? 0;
    int secondBall = int.tryParse(secondInput) ?? 0;
    int thridBall = int.tryParse(thirdInput) ?? 0;

    // For the 10th frame, ensure no ball exceeds 10 pins and handle spare rule
    if (frameIndex == 9) {
      if (firstBall > 10 || secondBall > 10 || thridBall > 10) {
        errorMessage =
            'Each ball in the 10th frame can only have up to 10 pins.';
        scoreControllers[frameIndex][0].clear(); // Clear the first ball input
        scoreControllers[frameIndex][1].clear(); // Clear the second ball input
      } else if (firstBall + secondBall == 10 && secondBall > 10 - firstBall) {
        errorMessage =
            'The second ball in the 10th frame cannot exceed ${10 - firstBall} pins when the total is 10.';
        scoreControllers[frameIndex][1].clear(); // Clear the second ball input
      } else {
        errorMessage = ''; // Reset error message if input is valid
      }
    } else {
      // Ensure the total of the first and second ball does not exceed 10
      if (firstBall + secondBall > 10) {
        errorMessage = 'The total of both balls in a frame cannot exceed 10.';
        scoreControllers[frameIndex][0].clear(); // Clear the first ball input
        scoreControllers[frameIndex][1].clear(); // Clear the second ball input
      } else {
        errorMessage = ''; // Reset error message if input is valid
      }
    }
  }
}

// --- Controller ---
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
              Text(
                model.errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
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
