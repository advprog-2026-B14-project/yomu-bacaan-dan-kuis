package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class QuizRequest {

    @NotNull(message = "Reading id must not be null")
    private Integer readingId;

    @NotBlank(message = "Question must not be blank")
    private String question;

    @NotBlank(message = "Option A must not be blank")
    private String optionA;

    @NotBlank(message = "Option B must not be blank")
    private String optionB;

    @NotBlank(message = "Option C must not be blank")
    private String optionC;

    @NotBlank(message = "Option D must not be blank")
    private String optionD;

    @NotBlank(message = "Correct answer must not be blank")
    private String correctAnswer;
}