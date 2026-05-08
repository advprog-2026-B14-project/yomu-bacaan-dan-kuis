package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.config.DevHeaderAuthenticationFilter;
import id.ac.ui.cs.advprog.yomubacaandankuis.config.InternalServiceTokenFilter;
import id.ac.ui.cs.advprog.yomubacaandankuis.config.SecurityConfig;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.LearningStatisticsResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.LearningStatisticsService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = InternalLearningStatisticsController.class)
@Import({
        SecurityConfig.class,
        InternalServiceTokenFilter.class,
        DevHeaderAuthenticationFilter.class
})
class InternalLearningStatisticsControllerWebMvcTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private LearningStatisticsService learningStatisticsService;

    @Test
    void internalEndpointRejectsMissingToken() throws Exception {
        mockMvc.perform(get("/api/internal/league/statistics/students/student-1"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void internalEndpointRejectsInvalidToken() throws Exception {
        mockMvc.perform(get("/api/internal/league/statistics/students/student-1")
                        .header("X-Internal-Service-Token", "wrong-token"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void getStudentStatisticsReturnsLeaguePayload() throws Exception {
        LearningStatisticsResponse response = new LearningStatisticsResponse(
                "student-1",
                2,
                5,
                7,
                0.7143,
                71.43
        );

        when(learningStatisticsService.getStudentStatistics("student-1")).thenReturn(response);

        mockMvc.perform(get("/api/internal/league/statistics/students/student-1")
                        .header("X-Internal-Service-Token", "test-internal-token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.studentId").value("student-1"))
                .andExpect(jsonPath("$.completedQuizCount").value(2))
                .andExpect(jsonPath("$.totalCorrectAnswers").value(5))
                .andExpect(jsonPath("$.totalAnsweredQuestions").value(7))
                .andExpect(jsonPath("$.accuracyRate").value(0.7143))
                .andExpect(jsonPath("$.accuracyPercentage").value(71.43));
    }
}
