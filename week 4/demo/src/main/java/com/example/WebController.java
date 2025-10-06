package com.example;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;

@Controller
public class WebController {

    @GetMapping("/")
    public String index(Model model, @AuthenticationPrincipal OidcUser user) {
        model.addAttribute("user", user);
        return "index";
    }

    @GetMapping("/home")
    public String home(Model model, @AuthenticationPrincipal OidcUser user) {
        model.addAttribute("user", user);
        return "home";
    }
}
