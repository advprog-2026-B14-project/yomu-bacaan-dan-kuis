package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Map;

@Getter
@Setter
public class LearnerSubmitQuizRequest {
    private Map<Integer, String> answers;
}
