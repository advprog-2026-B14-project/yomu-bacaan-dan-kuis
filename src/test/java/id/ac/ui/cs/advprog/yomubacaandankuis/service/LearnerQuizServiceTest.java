package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Category;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Quiz;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttempt;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttemptStatus;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Reading;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.QuizAttemptRepository;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.QuizRepository;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.ReadingRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LearnerQuizServiceTest {

    @Mock
    private QuizAttemptRepository quizAttemptRepository;

    @Mock
    private QuizRepository quizRepository;

    @Mock
    private ReadingRepository readingRepository;

    private LearnerQuizService learnerQuizService;

    @BeforeEach
    void setUp() {
        learnerQuizService = new LearnerQuizService(quizAttemptRepository, quizRepository, readingRepository);
    }

    @Test
    void startQuizRejectedWhenCompletedAttemptExists() {
        when(quizAttemptRepository.existsByStudentIdAndReadingIdAndStatus(
                "student-1",
                10,
                QuizAttemptStatus.COMPLETED
        )).thenReturn(true);

        assertThatThrownBy(() -> learnerQuizService.startQuiz("student-1", 10))
                .isInstanceOf(ResponseStatusException.class)
                .satisfies(exception -> {
                    ResponseStatusException responseStatusException = (ResponseStatusException) exception;
                    assertThat(responseStatusException.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
                    assertThat(responseStatusException.getReason()).isEqualTo("Quiz already completed for this reading");
                });

        verify(quizAttemptRepository, never()).save(any(QuizAttempt.class));
    }

    @Test
    void submitQuizChangesInProgressToCompleted() {
        QuizAttempt attempt = new QuizAttempt();
        attempt.setId(1);
        attempt.setStudentId("student-1");
        attempt.setReading(createReading(3));
        attempt.setStatus(QuizAttemptStatus.IN_PROGRESS);
        attempt.setStartedAt(LocalDateTime.of(2026, 4, 10, 8, 0));

        Quiz quiz1 = createQuiz(101, 3, "A");
        Quiz quiz2 = createQuiz(102, 3, "B");

        when(quizAttemptRepository.findByStudentIdAndReadingId("student-1", 3))
                .thenReturn(Optional.of(attempt));
        when(quizRepository.findByReadingId(3)).thenReturn(List.of(quiz1, quiz2));

        Integer score = learnerQuizService.submitQuiz("student-1", 3, Map.of(101, "a", 102, "C"));

        assertThat(score).isEqualTo(1);
        assertThat(attempt.getStatus()).isEqualTo(QuizAttemptStatus.COMPLETED);
        assertThat(attempt.getCompletedAt()).isNotNull();
        assertThat(attempt.getScore()).isEqualTo(1);
        verify(quizAttemptRepository).save(attempt);
    }

    @Test
    void getReadingForLearnerClearsContentWhenInProgress() {
        Reading reading = createReading(12);
        QuizAttempt attempt = new QuizAttempt();
        attempt.setStudentId("student-2");
        attempt.setReading(reading);
        attempt.setStatus(QuizAttemptStatus.IN_PROGRESS);
        attempt.setStartedAt(LocalDateTime.of(2026, 4, 11, 9, 0));

        when(readingRepository.findById(12)).thenReturn(Optional.of(reading));
        when(quizAttemptRepository.findByStudentIdAndReadingId("student-2", 12))
                .thenReturn(Optional.of(attempt));

        LearnerReadingResponse response = learnerQuizService.getReadingForLearner("student-2", 12);

        assertThat(response.getId()).isEqualTo(12);
        assertThat(response.getTitle()).isEqualTo("Gravity");
        assertThat(response.getContent()).isEmpty();
        assertThat(response.isLocked()).isTrue();
    }

    private Reading createReading(Integer id) {
        Category category = new Category();
        category.setId(9);
        category.setName("Science");

        Reading reading = new Reading();
        reading.setId(id);
        reading.setTitle("Gravity");
        reading.setContent("Detailed content");
        reading.setCategory(category);
        return reading;
    }

    private Quiz createQuiz(Integer id, Integer readingId, String correctAnswer) {
        Reading reading = createReading(readingId);

        Quiz quiz = new Quiz();
        quiz.setId(id);
        quiz.setReading(reading);
        quiz.setQuestion("Q" + id);
        quiz.setOptionA("A");
        quiz.setOptionB("B");
        quiz.setOptionC("C");
        quiz.setOptionD("D");
        quiz.setCorrectAnswer(correctAnswer);
        return quiz;
    }
}
