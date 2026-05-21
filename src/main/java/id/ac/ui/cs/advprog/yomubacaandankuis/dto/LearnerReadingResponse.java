package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LearnerReadingResponse {

    private Integer id;
    private String title;
    private String content;
    private Integer categoryId;

    @JsonProperty("isLocked")
    private boolean isLocked;
}
