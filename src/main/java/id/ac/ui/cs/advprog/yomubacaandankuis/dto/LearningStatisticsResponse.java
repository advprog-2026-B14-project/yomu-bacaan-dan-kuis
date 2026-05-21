package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LearningStatisticsResponse {

    private String studentId;
    private int completedQuizCount;
    private int totalCorrectAnswers;
    private int totalAnsweredQuestions;
    private double accuracyRate;
    private double accuracyPercentage;
}
