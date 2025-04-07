import 'package:flutter/material.dart';

void main() {
  runApp(FinalProject());
}

class FinalProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BowlingScorecard(),
    );
  }
}

class BowlingScorecard extends StatefulWidget {
  @override
  _BowlingScorecardState createState() => _BowlingScorecardState();
}

class _BowlingScorecardState extends State<BowlingScorecard> {
  final List<List<TextEditingController>> scoreControllers = List.generate(
    9,
    (_) => [TextEditingController(), TextEditingController()],
  )..add([
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ]); // Frame 10 has 3 inputs

  List<int> scores = List.generate(10, (_) => 0);

  void _updateScore(int frameIndex) {
    int ball1 = int.tryParse(scoreControllers[frameIndex][0].text) ?? 0;
    int ball2 = int.tryParse(scoreControllers[frameIndex][1].text) ?? 0;
    int ball3 =
        frameIndex == 9 ? (int.tryParse(scoreControllers[9][2].text) ?? 0) : 0;

    // Simple score calculation, replace this with actual scoring rules for strikes and spares
    int score = ball1 + ball2 + ball3;
    setState(() {
      scores[frameIndex] = score;
    });
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
                              scoreControllers[index][0],
                              "Ball 1",
                              index,
                            ),
                            _buildTextField(
                              scoreControllers[index][1],
                              "Ball 2",
                              index,
                            ),
                          ],
                        ),
                        Text(
                          "Score: ${scores[index]}",
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
                              scoreControllers[index + 5][0],
                              "Ball 1",
                              index + 5,
                            ),
                            _buildTextField(
                              scoreControllers[index + 5][1],
                              "Ball 2",
                              index + 5,
                            ),
                            if (index == 4) ...[
                              // Frame 10
                              _buildTextField(
                                scoreControllers[9][2],
                                "Ball 3",
                                9,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          "Score: ${scores[index + 5]}",
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    int frameIndex,
  ) {
    return Container(
      width: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _updateScore(frameIndex);
        },
      ),
    );
  }
}
