package id.ac.ui.cs.advprog.yomubacaandankuis.config;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class DevHeaderAuthenticationFilterTest {

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void disabledFilterDoesNotAuthenticateRequest() throws Exception {
        DevHeaderAuthenticationFilter filter = new DevHeaderAuthenticationFilter(false, "student_id", "roles");

        filter.doFilter(new MockHttpServletRequest("GET", "/api/learner/readings/1"), new MockHttpServletResponse(), new MockFilterChain());

        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    @Test
    void enabledFilterAuthenticatesLearnerPathWithStudentHeader() throws Exception {
        DevHeaderAuthenticationFilter filter = new DevHeaderAuthenticationFilter(true, "student_id", "roles");
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/learner/readings/1");
        request.addHeader("X-Student-Id", "student-1");

        filter.doFilter(request, new MockHttpServletResponse(), new MockFilterChain());

        assertNotNull(SecurityContextHolder.getContext().getAuthentication());
        assertTrue(SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                .anyMatch(authority -> "ROLE_LEARNER".equals(authority.getAuthority())));
        Jwt jwt = (Jwt) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        assertEquals("student-1", jwt.getClaimAsString("student_id"));
    }

    @Test
    void enabledFilterAuthenticatesAdminPathWithAdminRole() throws Exception {
        DevHeaderAuthenticationFilter filter = new DevHeaderAuthenticationFilter(true, "student_id", "roles");

        filter.doFilter(new MockHttpServletRequest("GET", "/api/admin/categories"), new MockHttpServletResponse(), new MockFilterChain());

        assertTrue(SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                .anyMatch(authority -> "ROLE_ADMIN".equals(authority.getAuthority())));
    }

    @Test
    void enabledFilterUsesExplicitDevRoleWhenProvided() throws Exception {
        DevHeaderAuthenticationFilter filter = new DevHeaderAuthenticationFilter(true, "student_id", "roles");
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/admin/categories");
        request.addHeader("X-Dev-Role", "LEARNER");

        filter.doFilter(request, new MockHttpServletResponse(), new MockFilterChain());

        assertTrue(SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                .anyMatch(authority -> "ROLE_LEARNER".equals(authority.getAuthority())));
    }
}
