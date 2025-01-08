package com.example.workshop_spring_vault;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@ResponseBody
class StaticSecretController {
    private final ExampleClient client;

    StaticSecretController(ExampleClient client) {
        this.client = client;
    }

    @GetMapping("/secret")
    public AppProperties.StaticSecret getStaticSecret() {
        return client.getProperties().getStaticSecret();
    }
}
