package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class QuizResponse {

    private Integer id;
    private Integer readingId;
    private String question;
    private String optionA;
    private String optionB;
    private String optionC;
    private String optionD;
    private String correctAnswer;
    private LocalDateTime createdAt;
}