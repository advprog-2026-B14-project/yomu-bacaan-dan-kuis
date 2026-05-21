package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearningStatisticsResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttempt;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttemptStatus;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Reading;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.QuizAttemptRepository;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.QuizRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LearningStatisticsServiceTest {

    @Mock
    private QuizAttemptRepository quizAttemptRepository;

    @Mock
    private QuizRepository quizRepository;

    private LearningStatisticsService learningStatisticsService;

    @BeforeEach
    void setUp() {
        learningStatisticsService = new LearningStatisticsService(quizAttemptRepository, quizRepository);
    }

    @Test
    void getStudentStatisticsCalculatesAccuracyAndFrequencyFromCompletedAttempts() {
        QuizAttempt firstAttempt = createCompletedAttempt(10, 3);
        QuizAttempt secondAttempt = createCompletedAttempt(11, 2);

        when(quizAttemptRepository.findByStudentIdAndStatus("student-1", QuizAttemptStatus.COMPLETED))
                .thenReturn(List.of(firstAttempt, secondAttempt));
        when(quizRepository.countByReadingId(10)).thenReturn(4L);
        when(quizRepository.countByReadingId(11)).thenReturn(3L);

        LearningStatisticsResponse response = learningStatisticsService.getStudentStatistics("student-1");

        assertThat(response.getStudentId()).isEqualTo("student-1");
        assertThat(response.getCompletedQuizCount()).isEqualTo(2);
        assertThat(response.getTotalCorrectAnswers()).isEqualTo(5);
        assertThat(response.getTotalAnsweredQuestions()).isEqualTo(7);
        assertThat(response.getAccuracyRate()).isEqualTo(0.7143);
        assertThat(response.getAccuracyPercentage()).isEqualTo(71.43);
    }

    @Test
    void getStudentStatisticsReturnsZeroValuesWhenStudentHasNoCompletedAttempts() {
        when(quizAttemptRepository.findByStudentIdAndStatus("student-2", QuizAttemptStatus.COMPLETED))
                .thenReturn(List.of());

        LearningStatisticsResponse response = learningStatisticsService.getStudentStatistics("student-2");

        assertThat(response.getStudentId()).isEqualTo("student-2");
        assertThat(response.getCompletedQuizCount()).isZero();
        assertThat(response.getTotalCorrectAnswers()).isZero();
        assertThat(response.getTotalAnsweredQuestions()).isZero();
        assertThat(response.getAccuracyRate()).isZero();
        assertThat(response.getAccuracyPercentage()).isZero();
    }

    @Test
    void getStudentStatisticsTreatsMissingScoreAsZeroCorrectAnswers() {
        QuizAttempt attempt = createCompletedAttempt(12, null);

        when(quizAttemptRepository.findByStudentIdAndStatus("student-3", QuizAttemptStatus.COMPLETED))
                .thenReturn(List.of(attempt));
        when(quizRepository.countByReadingId(12)).thenReturn(5L);

        LearningStatisticsResponse response = learningStatisticsService.getStudentStatistics("student-3");

        assertThat(response.getCompletedQuizCount()).isEqualTo(1);
        assertThat(response.getTotalCorrectAnswers()).isZero();
        assertThat(response.getTotalAnsweredQuestions()).isEqualTo(5);
        assertThat(response.getAccuracyRate()).isZero();
    }

    private QuizAttempt createCompletedAttempt(Integer readingId, Integer score) {
        Reading reading = new Reading();
        reading.setId(readingId);

        QuizAttempt attempt = new QuizAttempt();
        attempt.setReading(reading);
        attempt.setStatus(QuizAttemptStatus.COMPLETED);
        attempt.setScore(score);
        return attempt;
    }
}
