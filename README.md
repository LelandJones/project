```mermaid
classDiagram
    class BowlingScoreModel {
        +List~List~TextEditingController~~ scoreControllers
        +List~int~ scores
        +void calculateScores()
        +int totalScore
        -int _getRoll(int frame, int roll)
        -int _strikeBonus(int frame)
    }

