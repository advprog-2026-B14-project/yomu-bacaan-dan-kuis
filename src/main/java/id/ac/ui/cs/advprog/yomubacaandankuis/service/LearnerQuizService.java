package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerQuizQuestionResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Quiz;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttempt;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttemptStatus;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Reading;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.QuizAttemptRepository;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.QuizRepository;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.ReadingRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@Transactional
public class LearnerQuizService {

    private final QuizAttemptRepository quizAttemptRepository;
    private final QuizRepository quizRepository;
    private final ReadingRepository readingRepository;

    public LearnerQuizService(
            QuizAttemptRepository quizAttemptRepository,
            QuizRepository quizRepository,
            ReadingRepository readingRepository
    ) {
        this.quizAttemptRepository = quizAttemptRepository;
        this.quizRepository = quizRepository;
        this.readingRepository = readingRepository;
    }

    public void startQuiz(String studentId, Integer readingId) {
        if (quizAttemptRepository.existsByStudentIdAndReadingIdAndStatus(
                studentId,
                readingId,
                QuizAttemptStatus.COMPLETED
        )) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Quiz already completed for this reading");
        }

        Optional<QuizAttempt> existingAttempt = quizAttemptRepository.findByStudentIdAndReadingId(studentId, readingId);
        if (existingAttempt.isPresent()) {
            return;
        }

        Reading reading = getReading(readingId);
        QuizAttempt quizAttempt = new QuizAttempt();
        quizAttempt.setStudentId(studentId);
        quizAttempt.setReading(reading);
        quizAttempt.setStatus(QuizAttemptStatus.IN_PROGRESS);
        quizAttempt.setStartedAt(LocalDateTime.now());
        quizAttemptRepository.save(quizAttempt);
    }

    public Integer submitQuiz(String studentId, Integer readingId, Map<Integer, String> answers) {
        QuizAttempt attempt = quizAttemptRepository.findByStudentIdAndReadingId(studentId, readingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.CONFLICT, "Quiz attempt has not been started"));

        if (attempt.getStatus() == QuizAttemptStatus.COMPLETED) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Quiz already completed for this reading");
        }

        List<Quiz> quizzes = quizRepository.findByReadingId(readingId);
        int score = calculateScore(quizzes, answers);

        attempt.setScore(score);
        attempt.setStatus(QuizAttemptStatus.COMPLETED);
        attempt.setCompletedAt(LocalDateTime.now());
        quizAttemptRepository.save(attempt);

        return score;
    }

    @Transactional(readOnly = true)
    public LearnerReadingResponse getReadingForLearner(String studentId, Integer readingId) {
        Reading reading = getReading(readingId);

        boolean isLocked = quizAttemptRepository.findByStudentIdAndReadingId(studentId, readingId)
                .map(attempt -> attempt.getStatus() == QuizAttemptStatus.IN_PROGRESS)
                .orElse(false);

        String content = isLocked ? "" : reading.getContent();

        return new LearnerReadingResponse(
                reading.getId(),
                reading.getTitle(),
                content,
                reading.getCategory().getId(),
                isLocked
        );
    }

    @Transactional(readOnly = true)
    public List<LearnerQuizQuestionResponse> getQuizQuestionsForLearner(String studentId, Integer readingId) {
        getReading(readingId);
        return quizRepository.findByReadingId(readingId).stream()
                .map(this::toLearnerQuizQuestionResponse)
                .toList();
    }

    private Reading getReading(Integer readingId) {
        return readingRepository.findById(readingId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Reading with id " + readingId + " not found"
                ));
    }

    private int calculateScore(List<Quiz> quizzes, Map<Integer, String> answers) {
        if (answers == null || answers.isEmpty()) {
            return 0;
        }

        int score = 0;
        for (Quiz quiz : quizzes) {
            String learnerAnswer = answers.get(quiz.getId());
            if (learnerAnswer != null && learnerAnswer.trim().equalsIgnoreCase(quiz.getCorrectAnswer())) {
                score++;
            }
        }
        return score;
    }

    private LearnerQuizQuestionResponse toLearnerQuizQuestionResponse(Quiz quiz) {
        return new LearnerQuizQuestionResponse(
                quiz.getQuestion(),
                quiz.getOptionA(),
                quiz.getOptionB(),
                quiz.getOptionC(),
                quiz.getOptionD()
        );
    }
}
