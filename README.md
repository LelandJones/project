```mermaid
classDiagram
  class BowlingScoreModel {
    List<List<TextEditingController>> scoreControllers
    List<int> scores
    void calculateScores()
    void resetGame()
    int get totalScore()
    int _getRoll(int frame, int roll)
    int _strikeBonus(int frame)
    bool enableSecondBall(int frameIndex)
    bool tenthFrameThirdBall()
  }
