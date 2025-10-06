package com.example;

import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.OAuth2AuthorizeRequest;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.security.oauth2.core.oidc.OidcIdToken;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

@Controller
public class TokenController {

    private final OAuth2AuthorizedClientService authorizedClientService;
    private final OAuth2AuthorizedClientManager authorizedClientManager;

    public TokenController(OAuth2AuthorizedClientService authorizedClientService,
                           OAuth2AuthorizedClientManager authorizedClientManager) {
        this.authorizedClientService = authorizedClientService;
        this.authorizedClientManager = authorizedClientManager;
    }

    // Return the ID token, access token, and refresh token (if available)
    @GetMapping("/tokens")
    @ResponseBody
    public Map<String, Object> tokens(Authentication authentication) {
        Map<String, Object> resp = new HashMap<>();
        if (authentication == null) {
            resp.put("authenticated", false);
            return resp;
        }

        String principalName = authentication.getName();
        String registrationId = "auth0"; // matches registration in application.properties

        OAuth2AuthorizedClient client = authorizedClientService.loadAuthorizedClient(registrationId, principalName);
        if (client == null) {
            resp.put("authenticated", false);
            return resp;
        }

        resp.put("authenticated", true);

        OidcIdToken idToken = null;
        if (client.getPrincipal() != null && client.getPrincipal() instanceof org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken) {
            // Not strictly necessary here; ID token can also be retrieved from the principal if it's an OidcUser
        }

        if (client.getAccessToken() != null) {
            OAuth2AccessToken at = client.getAccessToken();
            resp.put("access_token", at.getTokenValue());
            resp.put("access_token_expires_at", at.getExpiresAt() != null ? at.getExpiresAt().toString() : null);
        }

        // Refresh token may be null if not issued
        if (client.getRefreshToken() != null) {
            resp.put("refresh_token", client.getRefreshToken().getTokenValue());
        }

        // Try to pick up ID token from the principal if available
        Object principal = authentication.getPrincipal();
        if (principal instanceof org.springframework.security.oauth2.core.oidc.user.OidcUser) {
            idToken = ((org.springframework.security.oauth2.core.oidc.user.OidcUser) principal).getIdToken();
            if (idToken != null) {
                resp.put("id_token", idToken.getTokenValue());
            }
        }

        return resp;
    }

    // Trigger a refresh of tokens using the authorized client manager. Returns refreshed token set.
    @PostMapping("/refresh")
    @ResponseBody
    public Map<String, Object> refresh(Authentication authentication) {
        Map<String, Object> resp = new HashMap<>();
        if (authentication == null) {
            resp.put("error", "not_authenticated");
            return resp;
        }

        String principalName = authentication.getName();
        String registrationId = "auth0";

        OAuth2AuthorizeRequest request = OAuth2AuthorizeRequest.withClientRegistrationId(registrationId)
                .principal(authentication)
                .attribute(OAuth2AuthorizeRequest.PRINCIPAL_NAME, principalName)
                .build();

        OAuth2AuthorizedClient authorizedClient = authorizedClientManager.authorize(request);
        if (authorizedClient == null) {
            resp.put("error", "refresh_failed_or_no_refresh_token");
            return resp;
        }

        if (authorizedClient.getAccessToken() != null) {
            resp.put("access_token", authorizedClient.getAccessToken().getTokenValue());
            resp.put("access_token_expires_at", authorizedClient.getAccessToken().getExpiresAt() != null ? authorizedClient.getAccessToken().getExpiresAt().toString() : null);
        }
        if (authorizedClient.getRefreshToken() != null) {
            resp.put("refresh_token", authorizedClient.getRefreshToken().getTokenValue());
        }

        // ID token: try to take from the principal again
        Object principal = authentication.getPrincipal();
        if (principal instanceof org.springframework.security.oauth2.core.oidc.user.OidcUser) {
            OidcIdToken idToken = ((org.springframework.security.oauth2.core.oidc.user.OidcUser) principal).getIdToken();
            if (idToken != null) resp.put("id_token", idToken.getTokenValue());
        }

        resp.put("refreshed", true);
        return resp;
    }
}
