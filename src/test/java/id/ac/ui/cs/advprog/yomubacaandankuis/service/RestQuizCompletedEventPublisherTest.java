package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizCompletedEvent;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.springframework.test.web.client.ExpectedCount.once;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class RestQuizCompletedEventPublisherTest {

    @Test
    void publishSendsQuizCompletedEventToConfiguredUrl() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        RestQuizCompletedEventPublisher publisher = new RestQuizCompletedEventPublisher(
                builder,
                "https://achievement.example.test/internal/events",
                "X-Internal-Service-Token",
                "token"
        );

        server.expect(once(), requestTo("https://achievement.example.test/internal/events"))
                .andExpect(method(HttpMethod.POST))
                .andExpect(header("X-Internal-Service-Token", "token"))
                .andRespond(withSuccess("{}", MediaType.APPLICATION_JSON));

        publisher.publish(event());

        server.verify();
    }

    @Test
    void publishSkipsWhenUrlIsNotConfigured() {
        RestQuizCompletedEventPublisher publisher = new RestQuizCompletedEventPublisher(
                RestClient.builder(),
                "",
                "X-Internal-Service-Token",
                "token"
        );

        assertThatCode(() -> publisher.publish(event())).doesNotThrowAnyException();
    }

    @Test
    void publishSkipsWhenUrlIsNull() {
        RestQuizCompletedEventPublisher publisher = new RestQuizCompletedEventPublisher(
                RestClient.builder(),
                null,
                "X-Internal-Service-Token",
                "token"
        );

        assertThatCode(() -> publisher.publish(event())).doesNotThrowAnyException();
    }

    @Test
    void publishSendsEventWithoutTokenWhenTokenIsBlank() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        RestQuizCompletedEventPublisher publisher = new RestQuizCompletedEventPublisher(
                builder,
                "https://achievement.example.test/internal/events",
                "X-Internal-Service-Token",
                ""
        );

        server.expect(once(), requestTo("https://achievement.example.test/internal/events"))
                .andExpect(method(HttpMethod.POST))
                .andRespond(withSuccess("{}", MediaType.APPLICATION_JSON));

        publisher.publish(event());

        server.verify();
    }

    @Test
    void publishSendsEventWithoutTokenWhenTokenIsNull() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        RestQuizCompletedEventPublisher publisher = new RestQuizCompletedEventPublisher(
                builder,
                "https://achievement.example.test/internal/events",
                "X-Internal-Service-Token",
                null
        );

        server.expect(once(), requestTo("https://achievement.example.test/internal/events"))
                .andExpect(method(HttpMethod.POST))
                .andRespond(withSuccess("{}", MediaType.APPLICATION_JSON));

        publisher.publish(event());

        server.verify();
    }

    @Test
    void publishDoesNotFailQuizFlowWhenTargetServiceFails() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        RestQuizCompletedEventPublisher publisher = new RestQuizCompletedEventPublisher(
                builder,
                "https://achievement.example.test/internal/events",
                "X-Internal-Service-Token",
                "token"
        );

        server.expect(once(), requestTo("https://achievement.example.test/internal/events"))
                .andRespond(withServerError());

        assertThatCode(() -> publisher.publish(event())).doesNotThrowAnyException();
        server.verify();
    }

    private QuizCompletedEvent event() {
        return QuizCompletedEvent.of(
                "student-1",
                16,
                4,
                4,
                5,
                LocalDateTime.of(2026, 5, 22, 10, 0)
        );
    }
}
