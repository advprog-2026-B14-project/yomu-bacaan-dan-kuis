package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import java.time.LocalDateTime;

public record QuizCompletedEvent(
        String eventType,
        String studentId,
        String userId,
        Integer readingId,
        Integer score,
        Double points,
        Double pointsGained,
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
        double points = score == null ? 0.0 : score.doubleValue();
        return new QuizCompletedEvent(
                "QUIZ_COMPLETED",
                studentId,
                studentId,
                readingId,
                score,
                points,
                points,
                correctAnswers,
                totalQuestions,
                completedAt
        );
    }
}
