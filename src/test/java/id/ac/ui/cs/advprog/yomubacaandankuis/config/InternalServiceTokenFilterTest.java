package id.ac.ui.cs.advprog.yomubacaandankuis.config;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.context.SecurityContextHolder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class InternalServiceTokenFilterTest {

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void shouldNotFilterNonInternalPath() {
        InternalServiceTokenFilter filter = new InternalServiceTokenFilter("secret", "X-Internal-Service-Token");
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/admin/categories");

        assertTrue(filter.shouldNotFilter(request));
    }

    @Test
    void doFilterRejectsMissingConfiguredToken() throws Exception {
        InternalServiceTokenFilter filter = new InternalServiceTokenFilter("", "X-Internal-Service-Token");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(internalRequest(null), response, new MockFilterChain());

        assertEquals(401, response.getStatus());
        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    @Test
    void doFilterRejectsInvalidToken() throws Exception {
        InternalServiceTokenFilter filter = new InternalServiceTokenFilter("secret", "X-Internal-Service-Token");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(internalRequest("wrong"), response, new MockFilterChain());

        assertEquals(401, response.getStatus());
        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    @Test
    void doFilterAcceptsValidTokenAndSetsInternalAuthority() throws Exception {
        InternalServiceTokenFilter filter = new InternalServiceTokenFilter("secret", "X-Internal-Service-Token");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(internalRequest("secret"), response, new MockFilterChain());

        assertEquals(200, response.getStatus());
        assertNotNull(SecurityContextHolder.getContext().getAuthentication());
        assertTrue(SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                .anyMatch(authority -> InternalServiceTokenFilter.INTERNAL_AUTHORITY.equals(authority.getAuthority())));
    }

    private MockHttpServletRequest internalRequest(String token) {
        MockHttpServletRequest request = new MockHttpServletRequest(
                "GET",
                "/api/internal/league/statistics/students/student-1"
        );
        if (token != null) {
            request.addHeader("X-Internal-Service-Token", token);
        }
        return request;
    }
}
