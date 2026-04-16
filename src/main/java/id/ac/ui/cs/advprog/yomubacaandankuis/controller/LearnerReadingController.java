package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerQuizQuestionResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerSubmitQuizRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerSubmitQuizResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.LearnerQuizService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/learner/readings")
public class LearnerReadingController {

    private final LearnerQuizService learnerQuizService;

    public LearnerReadingController(LearnerQuizService learnerQuizService) {
        this.learnerQuizService = learnerQuizService;
    }

    @PostMapping("/{readingId}/quiz/start")
    public void startQuiz(
            @RequestHeader("X-Student-Id") String studentId,
            @PathVariable Integer readingId
    ) {
        learnerQuizService.startQuiz(studentId, readingId);
    }

    @GetMapping("/{readingId}")
    public LearnerReadingResponse getReadingForLearner(
            @RequestHeader("X-Student-Id") String studentId,
            @PathVariable Integer readingId
    ) {
        return learnerQuizService.getReadingForLearner(studentId, readingId);
    }

    @GetMapping("/{readingId}/quiz")
    public List<LearnerQuizQuestionResponse> getQuizQuestionsForLearner(
            @RequestHeader("X-Student-Id") String studentId,
            @PathVariable Integer readingId
    ) {
        return learnerQuizService.getQuizQuestionsForLearner(studentId, readingId);
    }

    @PostMapping("/{readingId}/quiz/submit")
    public LearnerSubmitQuizResponse submitQuiz(
            @RequestHeader("X-Student-Id") String studentId,
            @PathVariable Integer readingId,
            @RequestBody LearnerSubmitQuizRequest request
    ) {
        Integer score = learnerQuizService.submitQuiz(studentId, readingId, request.getAnswers());
        return new LearnerSubmitQuizResponse(score);
    }
}
