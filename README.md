```mermaid
classDiagram
    class BowlingScoreModel {
        +List~List~TextEditingController~~ scoreControllers
        +List~int~ scores
        +void calculateScores()
        +void handleStrikeInput(int frameIndex)
        +int totalScore
        -int _getRoll(int frame, int roll)
        -int _strikeBonus(int frame)
        +bool shouldEnableSecondBall(int frameIndex)
        +bool shouldEnableTenthFrameThirdBall()
    }
