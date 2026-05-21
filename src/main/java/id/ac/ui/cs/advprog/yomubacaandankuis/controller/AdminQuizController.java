package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.QuizService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/quizzes")
public class AdminQuizController {

    private static final Logger AUDIT_LOG = LoggerFactory.getLogger("AUDIT");

    private final QuizService quizService;

    public AdminQuizController(QuizService quizService) {
        this.quizService = quizService;
    }

    @GetMapping
    public List<QuizResponse> getAllQuizzes() {
        return quizService.findAll();
    }

    @GetMapping("/{id}")
    public QuizResponse getQuizById(@PathVariable Integer id) {
        return quizService.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public QuizResponse createQuiz(Authentication authentication, @Valid @RequestBody QuizRequest request) {
        QuizResponse response = quizService.create(request);
        AUDIT_LOG.info("action=ADMIN_CREATE entity=quiz entityId={} actor={}", response.getId(), authentication.getName());
        return response;
    }

    @PutMapping("/{id}")
    public QuizResponse updateQuiz(Authentication authentication, @PathVariable Integer id, @Valid @RequestBody QuizRequest request) {
        QuizResponse response = quizService.update(id, request);
        AUDIT_LOG.info("action=ADMIN_UPDATE entity=quiz entityId={} actor={}", response.getId(), authentication.getName());
        return response;
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteQuiz(Authentication authentication, @PathVariable Integer id) {
        quizService.delete(id);
        AUDIT_LOG.info("action=ADMIN_DELETE entity=quiz entityId={} actor={}", id, authentication.getName());
    }
}
