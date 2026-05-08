package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.config.LearnerIdentity;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerQuizQuestionResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerSubmitQuizRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerSubmitQuizResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.LearnerQuizService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/learner/readings")
public class LearnerReadingController {

    private static final Logger AUDIT_LOG = LoggerFactory.getLogger("AUDIT");

    private final LearnerQuizService learnerQuizService;
    private final LearnerIdentity learnerIdentity;

    public LearnerReadingController(LearnerQuizService learnerQuizService, LearnerIdentity learnerIdentity) {
        this.learnerQuizService = learnerQuizService;
        this.learnerIdentity = learnerIdentity;
    }

    @PostMapping("/{readingId}/quiz/start")
    public void startQuiz(
            Authentication authentication,
            @PathVariable Integer readingId
    ) {
        String studentId = learnerIdentity.studentId(authentication);
        learnerQuizService.startQuiz(studentId, readingId);
    }

    @GetMapping("/{readingId}")
    public LearnerReadingResponse getReadingForLearner(
            Authentication authentication,
            @PathVariable Integer readingId
    ) {
        String studentId = learnerIdentity.studentId(authentication);
        return learnerQuizService.getReadingForLearner(studentId, readingId);
    }

    @GetMapping("/{readingId}/quiz")
    public List<LearnerQuizQuestionResponse> getQuizQuestionsForLearner(
            Authentication authentication,
            @PathVariable Integer readingId
    ) {
        String studentId = learnerIdentity.studentId(authentication);
        return learnerQuizService.getQuizQuestionsForLearner(studentId, readingId);
    }

    @PostMapping("/{readingId}/quiz/submit")
    public LearnerSubmitQuizResponse submitQuiz(
            Authentication authentication,
            @PathVariable Integer readingId,
            @RequestBody LearnerSubmitQuizRequest request
    ) {
        String studentId = learnerIdentity.studentId(authentication);
        Integer score = learnerQuizService.submitQuiz(studentId, readingId, request.getAnswers());
        AUDIT_LOG.info(
                "action=QUIZ_SUBMIT entity=quiz_attempt actor={} readingId={} score={}",
                studentId,
                readingId,
                score
        );
        return new LearnerSubmitQuizResponse(score);
    }
}
