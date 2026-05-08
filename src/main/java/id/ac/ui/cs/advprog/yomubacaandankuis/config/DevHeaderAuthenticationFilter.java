package id.ac.ui.cs.advprog.yomubacaandankuis.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;
import java.util.List;
import java.util.Map;

@Component
public class DevHeaderAuthenticationFilter extends OncePerRequestFilter {

    private final boolean enabled;
    private final String studentClaim;
    private final String rolesClaim;

    public DevHeaderAuthenticationFilter(
            @Value("${app.security.dev-auth-enabled:false}") boolean enabled,
            @Value("${app.security.jwt.student-claim:student_id}") String studentClaim,
            @Value("${app.security.jwt.roles-claim:roles}") String rolesClaim
    ) {
        this.enabled = enabled;
        this.studentClaim = studentClaim;
        this.rolesClaim = rolesClaim;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String uri = request.getRequestURI();
        return !enabled || uri.startsWith("/api/internal/") || SecurityContextHolder.getContext().getAuthentication() != null;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String uri = request.getRequestURI();
        String role = request.getHeader("X-Dev-Role");

        if ((role == null || role.isBlank()) && uri.startsWith("/api/learner/")) {
            role = "LEARNER";
        } else if ((role == null || role.isBlank()) && uri.startsWith("/api/admin/")) {
            role = "ADMIN";
        }

        if (role == null || role.isBlank()) {
            filterChain.doFilter(request, response);
            return;
        }

        String studentId = request.getHeader("X-Student-Id");
        String subject = studentId == null || studentId.isBlank() ? "dev-user" : studentId;
        Jwt jwt = new Jwt(
                "dev-token",
                Instant.now(),
                Instant.now().plusSeconds(3600),
                Map.of("alg", "none"),
                Map.of(
                        "sub", subject,
                        studentClaim, subject,
                        rolesClaim, List.of(role)
                )
        );

        SecurityContextHolder.getContext().setAuthentication(new JwtAuthenticationToken(
                jwt,
                List.of(new SimpleGrantedAuthority(toRoleAuthority(role)))
        ));
        filterChain.doFilter(request, response);
    }

    private String toRoleAuthority(String role) {
        String trimmedRole = role.trim();
        return trimmedRole.startsWith("ROLE_") ? trimmedRole : "ROLE_" + trimmedRole.toUpperCase();
    }
}
