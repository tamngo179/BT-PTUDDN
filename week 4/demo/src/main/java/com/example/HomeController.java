package com.example;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;

import java.util.Map;

@RestController
public class HomeController {

    @GetMapping("/public")
    public String publicEndpoint() {
        return "This is a public endpoint";
    }

    @GetMapping("/me")
    public Map<String, Object> me(@AuthenticationPrincipal OidcUser user) {
        if (user == null) return Map.of("authenticated", false);
        return Map.of(
            "authenticated", true,
            "subject", user.getSubject(),
            "email", user.getEmail(),
            "claims", user.getClaims()
        );
    }
}
