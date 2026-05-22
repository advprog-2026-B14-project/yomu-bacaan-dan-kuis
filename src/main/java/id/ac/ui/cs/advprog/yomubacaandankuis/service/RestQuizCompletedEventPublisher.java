package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizCompletedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Service
public class RestQuizCompletedEventPublisher implements QuizCompletedEventPublisher {

    private static final Logger LOGGER = LoggerFactory.getLogger(RestQuizCompletedEventPublisher.class);

    private final RestClient restClient;
    private final String eventUrl;
    private final String tokenHeader;
    private final String token;

    public RestQuizCompletedEventPublisher(
            RestClient.Builder restClientBuilder,
            @Value("${app.events.quiz-completed.url:}") String eventUrl,
            @Value("${app.events.quiz-completed.token-header:X-Internal-Service-Token}") String tokenHeader,
            @Value("${app.events.quiz-completed.token:}") String token
    ) {
        this.restClient = restClientBuilder.build();
        this.eventUrl = eventUrl;
        this.tokenHeader = tokenHeader;
        this.token = token;
    }

    @Override
    public void publish(QuizCompletedEvent event) {
        if (eventUrl == null || eventUrl.isBlank()) {
            LOGGER.debug("Quiz completed event URL is not configured; skipping event publish");
            return;
        }

        try {
            RestClient.RequestBodySpec request = restClient
                    .post()
                    .uri(eventUrl)
                    .header(HttpHeaders.CONTENT_TYPE, "application/json");

            if (token != null && !token.isBlank()) {
                request.header(tokenHeader, token);
            }

            request.body(event).retrieve().toBodilessEntity();
        } catch (RestClientException exception) {
            LOGGER.warn(
                    "Failed to publish quiz completed event for student {} and reading {}",
                    event.studentId(),
                    event.readingId(),
                    exception
            );
        }
    }
}
