package id.ac.ui.cs.advprog.yomubacaandankuis.config;

import org.junit.jupiter.api.Test;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.Collection;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SecurityConfigRolesConverterTest {

    private final SecurityConfig.RolesClaimGrantedAuthoritiesConverter converter =
            new SecurityConfig.RolesClaimGrantedAuthoritiesConverter("roles");

    @Test
    void convertReadsRolesFromCollectionClaim() {
        Collection<GrantedAuthority> authorities = converter.convert(jwt(Map.of("roles", Set.of("ADMIN", "LEARNER"))));

        assertEquals(Set.of("ROLE_ADMIN", "ROLE_LEARNER"), authorityNames(authorities));
    }

    @Test
    void convertReadsRolesFromSeparatedStringClaim() {
        Collection<GrantedAuthority> authorities = converter.convert(jwt(Map.of("roles", "admin learner")));

        assertEquals(Set.of("ROLE_ADMIN", "ROLE_LEARNER"), authorityNames(authorities));
    }

    @Test
    void convertKeepsExistingRolePrefix() {
        Collection<GrantedAuthority> authorities = converter.convert(jwt(Map.of("roles", "ROLE_ADMIN")));

        assertEquals(Set.of("ROLE_ADMIN"), authorityNames(authorities));
    }

    @Test
    void convertReturnsEmptyAuthoritiesWhenClaimMissing() {
        Collection<GrantedAuthority> authorities = converter.convert(jwt(Map.of("scope", "read")));

        assertTrue(authorities.isEmpty());
    }

    private Set<String> authorityNames(Collection<GrantedAuthority> authorities) {
        return authorities.stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toSet());
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
