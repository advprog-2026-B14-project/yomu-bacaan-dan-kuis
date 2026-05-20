package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearningStatisticsResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.LearningStatisticsService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/internal/league/statistics")
public class InternalLearningStatisticsController {

    private final LearningStatisticsService learningStatisticsService;

    public InternalLearningStatisticsController(LearningStatisticsService learningStatisticsService) {
        this.learningStatisticsService = learningStatisticsService;
    }

    @GetMapping("/students/{studentId}")
    public LearningStatisticsResponse getStudentStatistics(@PathVariable String studentId) {
        return learningStatisticsService.getStudentStatistics(studentId);
    }
}
