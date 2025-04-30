// view.dart
// 4/29/2025
// Leland Jones
// This is the view file for the bowling score calculator app.
// It contains the UI for displaying the scorecard and handling user input.

import 'package:flutter/material.dart';
import 'bowlingcontroller.dart';
import 'bowlingmodel.dart';

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
      // AppBar with title and background color
      appBar: AppBar(
        title: Text('Bowling Scorecard'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      // Body of the app with a centered column of widgets
      // The column contains the score frames, total score, error message, and buttons
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildFrameRow(0, 5), // First 5 frames
              _buildFrameRow(5, 10), // Last 5 frames
              SizedBox(height: 20),
              Divider(thickness: 2),
              Text(
                "Total Score: ${model.totalScore}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ), // Display total score
              SizedBox(height: 10),
              Text(
                model.errorMessage,
                style: TextStyle(color: Colors.red),
              ), // Display error message if any
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: controller.resetPressed,
                icon: Icon(Icons.refresh),
                label: Text("Reset"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ), // Reset button to clear the scores
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.loadScores,
                child: Text("Load Scores from Assets"),
              ), // Load scores button to load from JSON file
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrameRow(
    int start,
    int end,
  ) // Builds a row of frames for the scorecard
  {
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
                  ), // Display frame number
                  Row(
                    children: [
                      _buildTextField(
                        model.scoreControllers[frame][0],
                        "B1",
                        frame,
                      ), // First ball input field
                      SizedBox(width: 4),
                      _buildTextField(
                        model.scoreControllers[frame][1],
                        "B2",
                        frame,
                        enabled: model.enableSecondBall(frame),
                      ), // Second ball input field
                      if (frame == 9) SizedBox(width: 4),
                      if (frame == 9)
                        _buildTextField(
                          model.scoreControllers[frame][2],
                          "B3",
                          frame,
                          enabled: model.tenthFrameThirdBall(),
                        ), // Third ball input field for the 10th frame
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
  }) // Builds a text field for user input
  {
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
