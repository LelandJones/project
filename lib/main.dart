import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(FinalProject());
}

// --- App Root ---
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

  Future<void> loadFromJson() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/bowling_data.json',
      );
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      List<dynamic> frames = jsonData['frames'];

      for (int i = 0; i < frames.length; i++) {
        for (int j = 0; j < frames[i].length; j++) {
          model.scoreControllers[i][j].text = frames[i][j].toString();
        }
      }

      model.calculateScores();
      updateUI();
    } catch (e) {
      print("Error loading JSON: $e");
    }
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
    controller = BowlingScoreController(model, () => setState(() {}));
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
            children: [
              _buildFrameRow(0, 5),
              _buildFrameRow(5, 10),
              SizedBox(height: 20),
              Divider(thickness: 2),
              Text(
                "Total Score: ${model.totalScore}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(model.errorMessage, style: TextStyle(color: Colors.red)),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: controller.resetPressed,
                icon: Icon(Icons.refresh),
                label: Text("Reset"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: controller.loadFromJson,
                icon: Icon(Icons.download),
                label: Text("Load Sample Game"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrameRow(int start, int end) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start, (i) {
        int frame = start + i;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    "Frame ${frame + 1}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      _buildTextField(
                        model.scoreControllers[frame][0],
                        "B1",
                        frame,
                      ),
                      SizedBox(width: 4),
                      _buildTextField(
                        model.scoreControllers[frame][1],
                        "B2",
                        frame,
                        enabled: model.enableSecondBall(frame),
                      ),
                      if (frame == 9) SizedBox(width: 4),
                      if (frame == 9)
                        _buildTextField(
                          model.scoreControllers[frame][2],
                          "B3",
                          frame,
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
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    int frameIndex, {
    bool enabled = true,
  }) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[300],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (_) => this.controller.ballInputChanged(frameIndex),
      ),
    );
  }
}
