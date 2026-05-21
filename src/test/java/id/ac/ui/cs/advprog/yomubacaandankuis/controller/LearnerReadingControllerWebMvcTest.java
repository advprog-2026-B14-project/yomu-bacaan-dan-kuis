package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.config.DevHeaderAuthenticationFilter;
import id.ac.ui.cs.advprog.yomubacaandankuis.config.InternalServiceTokenFilter;
import id.ac.ui.cs.advprog.yomubacaandankuis.config.LearnerIdentity;
import id.ac.ui.cs.advprog.yomubacaandankuis.config.SecurityConfig;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerQuizQuestionResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearnerSubmitQuizResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.LearnerQuizService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = LearnerReadingController.class)
@Import({
        RestExceptionHandler.class,
        SecurityConfig.class,
        InternalServiceTokenFilter.class,
        DevHeaderAuthenticationFilter.class,
        LearnerIdentity.class
})
class LearnerReadingControllerWebMvcTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private LearnerQuizService learnerQuizService;

    @Test
    void learnerEndpointRejectsMissingToken() throws Exception {
        mockMvc.perform(get("/api/learner/readings/10"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void learnerEndpointRejectsNonLearnerRole() throws Exception {
        mockMvc.perform(get("/api/learner/readings/10").with(adminJwt()))
                .andExpect(status().isForbidden());
    }

    @Test
    void startFirstAttemptSucceeds() throws Exception {
        doNothing().when(learnerQuizService).startQuiz("student-1", 10);

        mockMvc.perform(post("/api/learner/readings/10/quiz/start")
                        .with(learnerJwt("student-1")))
                .andExpect(status().isOk());
    }

    @Test
    void restartAfterCompletedFailsWithConflict() throws Exception {
        doThrow(new ResponseStatusException(HttpStatus.CONFLICT, "Quiz already completed for this reading"))
                .when(learnerQuizService)
                .startQuiz("student-1", 10);

        mockMvc.perform(post("/api/learner/readings/10/quiz/start")
                        .with(learnerJwt("student-1")))
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
                        .with(learnerJwt("student-1")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.content").value(""))
                .andExpect(jsonPath("$.isLocked").value(true));
    }

    @Test
    void getQuizQuestionsReturnsOptionsWithoutCorrectAnswer() throws Exception {
        when(learnerQuizService.getQuizQuestionsForLearner("student-1", 10))
                .thenReturn(List.of(new LearnerQuizQuestionResponse(101, "Question?", "A", "B", "C", "D")));

        mockMvc.perform(get("/api/learner/readings/10/quiz")
                        .with(learnerJwt("student-1")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(101))
                .andExpect(jsonPath("$[0].question").value("Question?"))
                .andExpect(jsonPath("$[0].optionA").value("A"))
                .andExpect(jsonPath("$[0].correctAnswer").doesNotExist());
    }

    @Test
    void submitQuizReturnsScore() throws Exception {
        when(learnerQuizService.submitQuizWithReview("student-1", 10, Map.of(101, "A")))
                .thenReturn(new LearnerSubmitQuizResponse(1, 1, Map.of(101, "A")));

        mockMvc.perform(post("/api/learner/readings/10/quiz/submit")
                        .with(learnerJwt("student-1"))
                        .contentType("application/json")
                        .content("{\"answers\":{\"101\":\"A\"}}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.score").value(1))
                .andExpect(jsonPath("$.totalQuestions").value(1))
                .andExpect(jsonPath("$.correctAnswers.101").value("A"));
    }

    @Test
    void learnerStudentIdFallsBackToSubjectWhenStudentClaimMissing() throws Exception {
        when(learnerQuizService.getReadingForLearner("subject-student", 10))
                .thenReturn(new LearnerReadingResponse(10, "Gravity", "Content", 7, false));

        mockMvc.perform(get("/api/learner/readings/10")
                        .with(jwt()
                                .jwt(jwt -> jwt.subject("subject-student"))
                                .authorities(new SimpleGrantedAuthority("ROLE_LEARNER"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(10));
    }

    private RequestPostProcessor learnerJwt(String studentId) {
        return jwt()
                .jwt(jwt -> jwt.claim("student_id", studentId).subject("jwt-subject"))
                .authorities(new SimpleGrantedAuthority("ROLE_LEARNER"));
    }

    private RequestPostProcessor adminJwt() {
        return jwt().authorities(new SimpleGrantedAuthority("ROLE_ADMIN"));
    }
}
