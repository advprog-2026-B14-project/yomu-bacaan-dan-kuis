package id.ac.ui.cs.advprog.yomubacaandankuis.config;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class LearnerIdentityTest {

    private final LearnerIdentity learnerIdentity = new LearnerIdentity("student_id");

    @Test
    void studentIdUsesConfiguredClaimWhenPresent() {
        Jwt jwt = jwt(Map.of("student_id", "student-claim", "sub", "subject-value"));

        String studentId = learnerIdentity.studentId(new JwtAuthenticationToken(jwt));

        assertEquals("student-claim", studentId);
    }

    @Test
    void studentIdFallsBackToSubjectWhenConfiguredClaimMissing() {
        Jwt jwt = jwt(Map.of("sub", "subject-student"));

        String studentId = learnerIdentity.studentId(new JwtAuthenticationToken(jwt));

        assertEquals("subject-student", studentId);
    }

    @Test
    void studentIdRejectsMissingJwtAuthentication() {
        ResponseStatusException exception = assertThrows(
                ResponseStatusException.class,
                () -> learnerIdentity.studentId(null)
        );

        assertEquals(HttpStatus.UNAUTHORIZED, exception.getStatusCode());
        assertEquals("JWT authentication is required", exception.getReason());
    }

    @Test
    void studentIdRejectsJwtWithoutStudentIdentity() {
        Jwt jwt = jwt(Map.of("scope", "read"));
        JwtAuthenticationToken authentication = new JwtAuthenticationToken(jwt);

        ResponseStatusException exception = assertThrows(
                ResponseStatusException.class,
                () -> learnerIdentity.studentId(authentication)
        );

        assertEquals(HttpStatus.UNAUTHORIZED, exception.getStatusCode());
        assertEquals("Student identity claim is missing", exception.getReason());
    }

    private Jwt jwt(Map<String, Object> claims) {
        return new Jwt(
                "token",
                Instant.now(),
                Instant.now().plusSeconds(300),
                Map.of("alg", "none"),
                claims
        );
    }
}
