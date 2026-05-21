package id.ac.ui.cs.advprog.yomubacaandankuis.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class CategoryResponse {

    private Integer id;
    private String name;
    private LocalDateTime createdAt;
}