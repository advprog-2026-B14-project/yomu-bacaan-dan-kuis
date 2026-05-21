package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Quiz;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Reading;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.QuizRepository;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.ReadingRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@Transactional
public class QuizService {

    private final QuizRepository quizRepository;
    private final ReadingRepository readingRepository;

    public QuizService(QuizRepository quizRepository, ReadingRepository readingRepository) {
        this.quizRepository = quizRepository;
        this.readingRepository = readingRepository;
    }

    @Transactional(readOnly = true)
    public List<QuizResponse> findAll() {
        return quizRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public QuizResponse findById(Integer id) {
        return toResponse(getQuiz(id));
    }

    public QuizResponse create(QuizRequest request) {
        Quiz quiz = new Quiz();
        applyRequest(quiz, request);
        return toResponse(quizRepository.save(quiz));
    }

    public QuizResponse update(Integer id, QuizRequest request) {
        Quiz quiz = getQuiz(id);
        applyRequest(quiz, request);
        return toResponse(quizRepository.save(quiz));
    }

    public void delete(Integer id) {
        Quiz quiz = getQuiz(id);
        quizRepository.delete(quiz);
    }

    private void applyRequest(Quiz quiz, QuizRequest request) {
        Reading reading = readingRepository.findById(request.getReadingId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Reading with id " + request.getReadingId() + " not found"
                ));

        quiz.setReading(reading);
        quiz.setQuestion(request.getQuestion());
        quiz.setOptionA(request.getOptionA());
        quiz.setOptionB(request.getOptionB());
        quiz.setOptionC(request.getOptionC());
        quiz.setOptionD(request.getOptionD());
        quiz.setCorrectAnswer(request.getCorrectAnswer());
    }

    private Quiz getQuiz(Integer id) {
        return quizRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Quiz with id " + id + " not found"
                ));
    }

    private QuizResponse toResponse(Quiz quiz) {
        return new QuizResponse(
                quiz.getId(),
                quiz.getReading().getId(),
                quiz.getQuestion(),
                quiz.getOptionA(),
                quiz.getOptionB(),
                quiz.getOptionC(),
                quiz.getOptionD(),
                quiz.getCorrectAnswer(),
                quiz.getCreatedAt()
        );
    }
}