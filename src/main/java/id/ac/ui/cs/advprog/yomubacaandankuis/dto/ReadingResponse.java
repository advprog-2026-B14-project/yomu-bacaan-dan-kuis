package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ReadingResponse {

    private Integer id;
    private String title;
    private String content;
    private Integer categoryId;
    private LocalDateTime createdAt;
}