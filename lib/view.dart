// view.dart

import 'package:flutter/material.dart';
import 'controller.dart';
import 'model.dart';

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
    controller.loadScores(); // Load initial scores from the assets
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.loadScores,
                child: Text("Load Scores from Assets"),
              ),
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
