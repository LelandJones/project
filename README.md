```mermaid
flowchart TD
    A[Start updateScore] --> B[Get ball1 text]
    B --> C[Convert ball1 to int or zero]
    C --> D[Get ball2 text]
    D --> E[Convert ball2 to int or zero]
    E --> F{Is frameIndex 9}
    F -- Yes --> G[Get ball3 text]
    G --> H[Convert ball3 to int or zero]
    H --> J[Add ball1 ball2 ball3]
    F -- No --> I[Set ball3 to zero]
    I --> J
    J --> K[Set score at frameIndex]
    K --> L[End updateScore]
