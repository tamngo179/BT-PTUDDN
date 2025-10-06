package com.example;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.view.RedirectView;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Controller
public class Auth0Controller {

    @Value("${AUTH0_ISSUER_URI:}")
    private String issuer;

    @Value("${AUTH0_CLIENT_ID:}")
    private String clientId;

    @GetMapping("/logout")
    public RedirectView logout(HttpServletRequest request) {
        // Build Auth0 logout URL per quickstart
        String returnTo = request.getScheme() + "://" + request.getServerName()
                + (request.getServerPort() == 80 || request.getServerPort() == 443 ? "" : ":" + request.getServerPort())
                + "/";
        String encodedReturnTo = URLEncoder.encode(returnTo, StandardCharsets.UTF_8);
        String logoutUrl = issuer;
        if (!logoutUrl.endsWith("/")) logoutUrl += "/";
        logoutUrl += "v2/logout?client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8)
                + "&returnTo=" + encodedReturnTo;

        return new RedirectView(logoutUrl);
    }
}
