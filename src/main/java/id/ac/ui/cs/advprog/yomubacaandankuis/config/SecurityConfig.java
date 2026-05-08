package id.ac.ui.cs.advprog.yomubacaandankuis.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.JwtDecoders;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter;
import org.springframework.security.web.SecurityFilterChain;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Locale;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            InternalServiceTokenFilter internalServiceTokenFilter,
            DevHeaderAuthenticationFilter devHeaderAuthenticationFilter,
            JwtAuthenticationConverter jwtAuthenticationConverter
    ) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .addFilterBefore(internalServiceTokenFilter, BearerTokenAuthenticationFilter.class)
                .addFilterBefore(devHeaderAuthenticationFilter, BearerTokenAuthenticationFilter.class)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")
                        .requestMatchers("/api/learner/**").hasRole("LEARNER")
                        .requestMatchers("/api/internal/**").hasAuthority(InternalServiceTokenFilter.INTERNAL_AUTHORITY)
                        .anyRequest().denyAll()
                )
                .oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter)))
                .build();
    }

    @Bean
    public JwtDecoder jwtDecoder(
            @Value("${app.security.jwt.issuer-uri:}") String issuerUri,
            @Value("${app.security.jwt.jwk-set-uri:}") String jwkSetUri
    ) {
        if (jwkSetUri != null && !jwkSetUri.isBlank()) {
            return NimbusJwtDecoder.withJwkSetUri(jwkSetUri).build();
        }

        if (issuerUri != null && !issuerUri.isBlank()) {
            return JwtDecoders.fromIssuerLocation(issuerUri);
        }

        return token -> {
            throw new JwtException("JWT decoder is not configured. Set JWT_ISSUER_URI or JWT_JWK_SET_URI.");
        };
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter(
            @Value("${app.security.jwt.roles-claim:roles}") String rolesClaim
    ) {
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(new RolesClaimGrantedAuthoritiesConverter(rolesClaim));
        return converter;
    }

    static class RolesClaimGrantedAuthoritiesConverter implements Converter<Jwt, Collection<GrantedAuthority>> {

        private final String rolesClaim;

        RolesClaimGrantedAuthoritiesConverter(String rolesClaim) {
            this.rolesClaim = rolesClaim;
        }

        @Override
        public Collection<GrantedAuthority> convert(Jwt jwt) {
            List<GrantedAuthority> authorities = new ArrayList<>();
            Object roles = jwt.getClaims().get(rolesClaim);

            if (roles instanceof Collection<?> collection) {
                collection.stream()
                        .map(String::valueOf)
                        .map(this::toRoleAuthority)
                        .map(SimpleGrantedAuthority::new)
                        .forEach(authorities::add);
            } else if (roles instanceof String roleString) {
                for (String role : roleString.split("[,\\s]+")) {
                    if (!role.isBlank()) {
                        authorities.add(new SimpleGrantedAuthority(toRoleAuthority(role)));
                    }
                }
            }

            return authorities;
        }

        private String toRoleAuthority(String value) {
            String role = value.trim();
            if (role.startsWith("ROLE_")) {
                return role;
            }
            return "ROLE_" + role.toUpperCase(Locale.ROOT);
        }
    }
}
