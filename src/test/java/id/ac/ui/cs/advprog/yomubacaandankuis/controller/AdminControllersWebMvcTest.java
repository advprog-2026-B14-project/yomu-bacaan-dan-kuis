package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.CategoryRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.CategoryResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.CategoryService;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.ReadingService;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.QuizService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = {
        AdminCategoryController.class,
        AdminReadingController.class,
        AdminQuizController.class
})
@Import(RestExceptionHandler.class)
class AdminControllersWebMvcTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private CategoryService categoryService;

    @MockBean
    private ReadingService readingService;

    @MockBean
    private QuizService quizService;

    @Test
    void getAllCategoriesReturnsServiceResponse() throws Exception {
        when(categoryService.findAll()).thenReturn(List.of(categoryResponse(1, "Science")));

        mockMvc.perform(get("/api/admin/categories"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].name").value("Science"));
    }

    @Test
    void getCategoryByIdReturnsServiceResponse() throws Exception {
        when(categoryService.findById(2)).thenReturn(categoryResponse(2, "History"));

        mockMvc.perform(get("/api/admin/categories/2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(2))
                .andExpect(jsonPath("$.name").value("History"));
    }

    @Test
    void createCategoryReturnsCreatedResponse() throws Exception {
        CategoryRequest request = new CategoryRequest();
        request.setName("Literature");
        when(categoryService.create(any(CategoryRequest.class))).thenReturn(categoryResponse(3, "Literature"));

        mockMvc.perform(post("/api/admin/categories")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(3))
                .andExpect(jsonPath("$.name").value("Literature"));
    }

    @Test
    void updateCategoryReturnsUpdatedResponse() throws Exception {
        CategoryRequest request = new CategoryRequest();
        request.setName("Updated");
        when(categoryService.update(any(), any(CategoryRequest.class))).thenReturn(categoryResponse(4, "Updated"));

        mockMvc.perform(put("/api/admin/categories/4")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(4))
                .andExpect(jsonPath("$.name").value("Updated"));
    }

    @Test
    void deleteCategoryReturnsNoContent() throws Exception {
        doNothing().when(categoryService).delete(5);

        mockMvc.perform(delete("/api/admin/categories/5"))
                .andExpect(status().isNoContent());

        verify(categoryService).delete(5);
    }

    @Test
    void createCategoryReturnsValidationErrors() throws Exception {
        mockMvc.perform(post("/api/admin/categories")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"name":""}
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Validation failed"))
                .andExpect(jsonPath("$.errors.name").value("Name must not be blank"));
    }

    @Test
    void getAllReadingsReturnsServiceResponse() throws Exception {
        when(readingService.findAll()).thenReturn(List.of(readingResponse(1, 10, "Gravity")));

        mockMvc.perform(get("/api/admin/readings"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].categoryId").value(10));
    }

    @Test
    void getReadingByIdReturnsServiceResponse() throws Exception {
        when(readingService.findById(2)).thenReturn(readingResponse(2, 11, "Solar System"));

        mockMvc.perform(get("/api/admin/readings/2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(2))
                .andExpect(jsonPath("$.title").value("Solar System"));
    }

    @Test
    void createReadingReturnsCreatedResponse() throws Exception {
        ReadingRequest request = new ReadingRequest();
        request.setTitle("Gravity");
        request.setContent("About planets");
        request.setCategoryId(7);
        when(readingService.create(any(ReadingRequest.class))).thenReturn(readingResponse(3, 7, "Gravity"));

        mockMvc.perform(post("/api/admin/readings")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(3))
                .andExpect(jsonPath("$.categoryId").value(7));
    }

    @Test
    void updateReadingReturnsUpdatedResponse() throws Exception {
        ReadingRequest request = new ReadingRequest();
        request.setTitle("Updated Reading");
        request.setContent("Updated content");
        request.setCategoryId(8);
        when(readingService.update(any(), any(ReadingRequest.class))).thenReturn(readingResponse(4, 8, "Updated Reading"));

        mockMvc.perform(put("/api/admin/readings/4")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Updated Reading"));
    }

    @Test
    void deleteReadingReturnsNoContent() throws Exception {
        doNothing().when(readingService).delete(5);

        mockMvc.perform(delete("/api/admin/readings/5"))
                .andExpect(status().isNoContent());

        verify(readingService).delete(5);
    }

    @Test
    void getAllQuizzesReturnsServiceResponse() throws Exception {
        when(quizService.findAll()).thenReturn(List.of(quizResponse(1, 9, "What is gravity?")));

        mockMvc.perform(get("/api/admin/quizzes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].readingId").value(9));
    }

    @Test
    void getQuizByIdReturnsServiceResponse() throws Exception {
        when(quizService.findById(2)).thenReturn(quizResponse(2, 9, "Question"));

        mockMvc.perform(get("/api/admin/quizzes/2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(2))
                .andExpect(jsonPath("$.question").value("Question"));
    }

    @Test
    void createQuizReturnsCreatedResponse() throws Exception {
        QuizRequest request = quizRequest(6);
        when(quizService.create(any(QuizRequest.class))).thenReturn(quizResponse(3, 6, "What is gravity?"));

        mockMvc.perform(post("/api/admin/quizzes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(3))
                .andExpect(jsonPath("$.readingId").value(6));
    }

    @Test
    void updateQuizReturnsUpdatedResponse() throws Exception {
        QuizRequest request = quizRequest(12);
        request.setQuestion("Updated question");
        when(quizService.update(any(), any(QuizRequest.class))).thenReturn(quizResponse(4, 12, "Updated question"));

        mockMvc.perform(put("/api/admin/quizzes/4")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.question").value("Updated question"));
    }

    @Test
    void deleteQuizReturnsNoContent() throws Exception {
        doNothing().when(quizService).delete(6);

        mockMvc.perform(delete("/api/admin/quizzes/6"))
                .andExpect(status().isNoContent());

        verify(quizService).delete(6);
    }

    private CategoryResponse categoryResponse(Integer id, String name) {
        return new CategoryResponse(id, name, LocalDateTime.of(2026, 3, 6, 22, 30));
    }

    private ReadingResponse readingResponse(Integer id, Integer categoryId, String title) {
        return new ReadingResponse(id, title, "About planets", categoryId, LocalDateTime.of(2026, 3, 6, 22, 31));
    }

    private QuizResponse quizResponse(Integer id, Integer readingId, String question) {
        return new QuizResponse(
                id,
                readingId,
                question,
                "Force",
                "Planet",
                "Star",
                "Ocean",
                "A",
                LocalDateTime.of(2026, 3, 6, 22, 32)
        );
    }

    private QuizRequest quizRequest(Integer readingId) {
        QuizRequest request = new QuizRequest();
        request.setReadingId(readingId);
        request.setQuestion("What is gravity?");
        request.setOptionA("Force");
        request.setOptionB("Planet");
        request.setOptionC("Star");
        request.setOptionD("Ocean");
        request.setCorrectAnswer("A");
        return request;
    }
}