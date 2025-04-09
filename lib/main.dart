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
  // List of controllers for each frame and ball input (Frame 10 has 3 balls)
  List<List<TextEditingController>> scoreControllers = List.generate(
    9,
    (_) => [TextEditingController(), TextEditingController()],
  )..add([
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ]); // Frame 10 has 3 inputs

  // List of scores for each frame
  List<int> scores = List.generate(10, (_) => 0);
}

class BowlingScoreController {
  final BowlingScoreModel model;
  final Function updateUI;

  BowlingScoreController(this.model, this.updateUI);
}

// View Class

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
              // First Row for Frames 1-5
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
                        Text(
                          "Score: ${model.scores[index]}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // Second Row for Frames 6-10
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          "Frame ${index + 6}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            _buildTextField(
                              model.scoreControllers[index + 5][0],
                              "Ball 1",
                              index + 5,
                            ),
                            _buildTextField(
                              model.scoreControllers[index + 5][1],
                              "Ball 2",
                              index + 5,
                            ),
                            if (index == 4) ...[
                              // Frame 10
                              _buildTextField(
                                model.scoreControllers[9][2],
                                "Ball 3",
                                9,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          "Score: ${model.scores[index + 5]}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextField widget to take user input for a given ball in a frame
  Widget _buildTextField(
    TextEditingController textEditingController,
    String hint,
    int frameIndex,
  ) {
    return Container(
      width: 50,
      child: TextField(
        controller: textEditingController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          controller.onBallInputChanged(
            frameIndex,
          ); // Update the score when input changes
        },
      ),
    );
  }
}
