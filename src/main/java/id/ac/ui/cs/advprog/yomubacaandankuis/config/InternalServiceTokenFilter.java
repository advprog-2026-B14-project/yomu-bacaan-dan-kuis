package id.ac.ui.cs.advprog.yomubacaandankuis.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class InternalServiceTokenFilter extends OncePerRequestFilter {

    public static final String INTERNAL_AUTHORITY = "INTERNAL_SERVICE";

    private final String internalToken;
    private final String internalTokenHeader;

    public InternalServiceTokenFilter(
            @Value("${app.security.internal-token:}") String internalToken,
            @Value("${app.security.internal-token-header:X-Internal-Service-Token}") String internalTokenHeader
    ) {
        this.internalToken = internalToken;
        this.internalTokenHeader = internalTokenHeader;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith("/api/internal/");
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        if (internalToken == null || internalToken.isBlank()) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Internal service token is not configured");
            return;
        }

        String providedToken = request.getHeader(internalTokenHeader);
        if (!internalToken.equals(providedToken)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid internal service token");
            return;
        }

        PreAuthenticatedAuthenticationToken authentication = new PreAuthenticatedAuthenticationToken(
                "internal-service",
                "N/A",
                List.of(new SimpleGrantedAuthority(INTERNAL_AUTHORITY))
        );
        SecurityContextHolder.getContext().setAuthentication(authentication);

        filterChain.doFilter(request, response);
    }
}
