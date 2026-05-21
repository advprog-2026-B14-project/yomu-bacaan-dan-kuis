package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.Map;

@Getter
@AllArgsConstructor
public class LearnerSubmitQuizResponse {
    private Integer score;
    private Integer totalQuestions;
    private Map<Integer, String> correctAnswers;
}
