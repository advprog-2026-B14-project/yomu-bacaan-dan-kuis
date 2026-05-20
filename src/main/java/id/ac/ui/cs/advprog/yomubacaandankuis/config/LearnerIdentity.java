package id.ac.ui.cs.advprog.yomubacaandankuis.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

@Component
public class LearnerIdentity {

    private final String studentClaim;

    public LearnerIdentity(@Value("${app.security.jwt.student-claim:student_id}") String studentClaim) {
        this.studentClaim = studentClaim;
    }

    public String studentId(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof Jwt jwt)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "JWT authentication is required");
        }

        String claimValue = jwt.getClaimAsString(studentClaim);
        if (claimValue != null && !claimValue.isBlank()) {
            return claimValue;
        }

        String subject = jwt.getSubject();
        if (subject != null && !subject.isBlank()) {
            return subject;
        }

        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Student identity claim is missing");
    }
}
