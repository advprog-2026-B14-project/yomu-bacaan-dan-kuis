package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.QuizService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
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
    public QuizResponse createQuiz(@Valid @RequestBody QuizRequest request) {
        return quizService.create(request);
    }

    @PutMapping("/{id}")
    public QuizResponse updateQuiz(@PathVariable Integer id, @Valid @RequestBody QuizRequest request) {
        return quizService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteQuiz(@PathVariable Integer id) {
        quizService.delete(id);
    }
}