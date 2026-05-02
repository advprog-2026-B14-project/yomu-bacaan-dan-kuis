package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerQuizQuestionResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.LearnerQuizService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpStatus;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = LearnerReadingController.class)
@Import(RestExceptionHandler.class)
class LearnerReadingControllerWebMvcTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private LearnerQuizService learnerQuizService;

    @Test
    void startFirstAttemptSucceeds() throws Exception {
        doNothing().when(learnerQuizService).startQuiz("student-1", 10);

        mockMvc.perform(post("/api/learner/readings/10/quiz/start")
                        .header("X-Student-Id", "student-1"))
                .andExpect(status().isOk());
    }

    @Test
    void restartAfterCompletedFailsWithConflict() throws Exception {
        doThrow(new ResponseStatusException(HttpStatus.CONFLICT, "Quiz already completed for this reading"))
                .when(learnerQuizService)
                .startQuiz("student-1", 10);

        mockMvc.perform(post("/api/learner/readings/10/quiz/start")
                        .header("X-Student-Id", "student-1"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message").value("Quiz already completed for this reading"))
                .andExpect(jsonPath("$.status").value(409));
    }

    @Test
    void getReadingWhenInProgressDoesNotShowContent() throws Exception {
        LearnerReadingResponse response = new LearnerReadingResponse(10, "Gravity", "", 7, true);

        when(learnerQuizService.getReadingForLearner("student-1", 10))
                .thenReturn(response);

        mockMvc.perform(get("/api/learner/readings/10")
                        .header("X-Student-Id", "student-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.content").value(""))
                .andExpect(jsonPath("$.isLocked").value(true));
    }

    @Test
    void getQuizQuestionsReturnsOptionsWithoutCorrectAnswer() throws Exception {
        when(learnerQuizService.getQuizQuestionsForLearner("student-1", 10))
                .thenReturn(List.of(new LearnerQuizQuestionResponse("Question?", "A", "B", "C", "D")));

        mockMvc.perform(get("/api/learner/readings/10/quiz")
                        .header("X-Student-Id", "student-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].question").value("Question?"))
                .andExpect(jsonPath("$[0].optionA").value("A"))
                .andExpect(jsonPath("$[0].correctAnswer").doesNotExist());
    }

    @Test
    void submitQuizReturnsScore() throws Exception {
        when(learnerQuizService.submitQuiz("student-1", 10, Map.of(101, "A")))
                .thenReturn(1);

        mockMvc.perform(post("/api/learner/readings/10/quiz/submit")
                        .header("X-Student-Id", "student-1")
                        .contentType("application/json")
                        .content("{\"answers\":{\"101\":\"A\"}}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.score").value(1));
    }
}
