package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearningStatisticsResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttempt;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttemptStatus;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.QuizAttemptRepository;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.QuizRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class LearningStatisticsService {

    private final QuizAttemptRepository quizAttemptRepository;
    private final QuizRepository quizRepository;

    public LearningStatisticsService(
            QuizAttemptRepository quizAttemptRepository,
            QuizRepository quizRepository
    ) {
        this.quizAttemptRepository = quizAttemptRepository;
        this.quizRepository = quizRepository;
    }

    public LearningStatisticsResponse getStudentStatistics(String studentId) {
        List<QuizAttempt> completedAttempts = quizAttemptRepository.findByStudentIdAndStatus(
                studentId,
                QuizAttemptStatus.COMPLETED
        );

        int completedQuizCount = completedAttempts.size();
        int totalCorrectAnswers = completedAttempts.stream()
                .map(QuizAttempt::getScore)
                .mapToInt(score -> score == null ? 0 : score)
                .sum();
        int totalAnsweredQuestions = completedAttempts.stream()
                .mapToInt(this::countQuestionsForAttempt)
                .sum();

        double accuracyRate = totalAnsweredQuestions == 0
                ? 0.0
                : (double) totalCorrectAnswers / totalAnsweredQuestions;
        double accuracyPercentage = roundToTwoDecimals(accuracyRate * 100);

        return new LearningStatisticsResponse(
                studentId,
                completedQuizCount,
                totalCorrectAnswers,
                totalAnsweredQuestions,
                roundToFourDecimals(accuracyRate),
                accuracyPercentage
        );
    }

    private int countQuestionsForAttempt(QuizAttempt attempt) {
        return Math.toIntExact(quizRepository.countByReadingId(attempt.getReading().getId()));
    }

    private double roundToFourDecimals(double value) {
        return Math.round(value * 10000.0) / 10000.0;
    }

    private double roundToTwoDecimals(double value) {
        return Math.round(value * 100.0) / 100.0;
    }
}
