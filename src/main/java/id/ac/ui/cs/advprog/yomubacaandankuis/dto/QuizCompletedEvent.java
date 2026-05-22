package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import java.time.LocalDateTime;

public record QuizCompletedEvent(
        String eventType,
        String studentId,
        Integer readingId,
        Integer score,
        Integer correctAnswers,
        Integer totalQuestions,
        LocalDateTime completedAt
) {
    public static QuizCompletedEvent of(
            String studentId,
            Integer readingId,
            Integer score,
            Integer correctAnswers,
            Integer totalQuestions,
            LocalDateTime completedAt
    ) {
        return new QuizCompletedEvent(
                "QUIZ_COMPLETED",
                studentId,
                readingId,
                score,
                correctAnswers,
                totalQuestions,
                completedAt
        );
    }
}
