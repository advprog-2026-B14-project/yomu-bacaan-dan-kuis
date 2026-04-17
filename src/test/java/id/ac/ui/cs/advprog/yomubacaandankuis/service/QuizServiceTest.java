package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Quiz;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Reading;
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
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class QuizServiceTest {

    @Mock
    private QuizRepository quizRepository;

    @Mock
    private ReadingRepository readingRepository;

    private QuizService quizService;

    @BeforeEach
    void setUp() {
        quizService = new QuizService(quizRepository, readingRepository);
    }

    @Test
    void findAllReturnsMappedResponses() {
        Quiz quiz = createQuiz(12, createReading(7));
        when(quizRepository.findAll()).thenReturn(List.of(quiz));

        List<QuizResponse> responses = quizService.findAll();

        assertThat(responses)
                .singleElement()
                .extracting(QuizResponse::getId, QuizResponse::getReadingId, QuizResponse::getQuestion)
                .containsExactly(12, 7, "What is gravity?");
    }

    @Test
    void findByIdReturnsMappedResponse() {
        Quiz quiz = createQuiz(1, createReading(4));
        when(quizRepository.findById(1)).thenReturn(Optional.of(quiz));

        QuizResponse response = quizService.findById(1);

        assertThat(response.getId()).isEqualTo(1);
        assertThat(response.getReadingId()).isEqualTo(4);
        assertThat(response.getCorrectAnswer()).isEqualTo("A");
    }

    @Test
    void findByIdThrowsWhenQuizMissing() {
        when(quizRepository.findById(501)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> quizService.findById(501))
                .isInstanceOf(ResponseStatusException.class)
                .satisfies(exception -> {
                    ResponseStatusException responseStatusException = (ResponseStatusException) exception;
                    assertThat(responseStatusException.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
                    assertThat(responseStatusException.getReason()).isEqualTo("Quiz with id 501 not found");
                });
    }

    @Test
    void createSavesQuizWithResolvedReading() {
        Reading reading = createReading(9);
        QuizRequest request = createQuizRequest(9);
        when(readingRepository.findById(9)).thenReturn(Optional.of(reading));
        when(quizRepository.save(any(Quiz.class))).thenAnswer(invocation -> {
            Quiz saved = invocation.getArgument(0);
            saved.setId(30);
            saved.setCreatedAt(LocalDateTime.of(2026, 3, 6, 21, 45));
            return saved;
        });

        QuizResponse response = quizService.create(request);

        assertThat(response.getId()).isEqualTo(30);
        assertThat(response.getReadingId()).isEqualTo(9);
        assertThat(response.getQuestion()).isEqualTo("What is gravity?");
    }

    @Test
    void updateModifiesExistingQuiz() {
        Reading reading = createReading(10);
        Quiz quiz = createQuiz(18, createReading(1));
        QuizRequest request = createQuizRequest(10);
        request.setQuestion("Updated question");
        request.setCorrectAnswer("B");
        when(quizRepository.findById(18)).thenReturn(Optional.of(quiz));
        when(readingRepository.findById(10)).thenReturn(Optional.of(reading));
        when(quizRepository.save(quiz)).thenReturn(quiz);

        QuizResponse response = quizService.update(18, request);

        assertThat(quiz.getReading()).isEqualTo(reading);
        assertThat(quiz.getQuestion()).isEqualTo("Updated question");
        assertThat(quiz.getCorrectAnswer()).isEqualTo("B");
        assertThat(response.getCorrectAnswer()).isEqualTo("B");
    }

    @Test
    void deleteRemovesExistingQuiz() {
        Quiz quiz = createQuiz(21, createReading(5));
        when(quizRepository.findById(21)).thenReturn(Optional.of(quiz));

        quizService.delete(21);

        verify(quizRepository).delete(quiz);
    }

    @Test
    void createThrowsWhenReadingMissing() {
        QuizRequest request = createQuizRequest(404);
        when(readingRepository.findById(404)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> quizService.create(request))
                .isInstanceOf(ResponseStatusException.class)
                .satisfies(exception -> {
                    ResponseStatusException responseStatusException = (ResponseStatusException) exception;
                    assertThat(responseStatusException.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
                    assertThat(responseStatusException.getReason()).isEqualTo("Reading with id 404 not found");
                });
    }

    private QuizRequest createQuizRequest(Integer readingId) {
        QuizRequest request = new QuizRequest();
        request.setReadingId(readingId);
        request.setQuestion("What is gravity?");
        request.setOptionA("Force");
        request.setOptionB("Planet");
        request.setOptionC("Star");
        request.setOptionD("Ocean");
        request.setCorrectAnswer("A");
        return request;
    }

    private Reading createReading(Integer id) {
        Reading reading = new Reading();
        reading.setId(id);
        reading.setTitle("Gravity");
        return reading;
    }

    private Quiz createQuiz(Integer id, Reading reading) {
        Quiz quiz = new Quiz();
        quiz.setId(id);
        quiz.setReading(reading);
        quiz.setQuestion("What is gravity?");
        quiz.setOptionA("Force");
        quiz.setOptionB("Planet");
        quiz.setOptionC("Star");
        quiz.setOptionD("Ocean");
        quiz.setCorrectAnswer("A");
        quiz.setCreatedAt(LocalDateTime.of(2026, 3, 6, 22, 0));
        return quiz;
    }
}