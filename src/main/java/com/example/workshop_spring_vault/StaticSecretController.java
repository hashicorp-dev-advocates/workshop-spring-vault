package com.example.workshop_spring_vault;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.sql.DataSource;

@Controller
@ResponseBody
class StaticSecretController {
    private final ExampleClient client;
    private final Log log = LogFactory.getLog(getClass());

    StaticSecretController(ExampleClient client) {
        this.client = client;
    }

    @GetMapping("/secret")
    public AppProperties.StaticSecret getStaticSecret() {
        return client.getProperties().getStaticSecret();
    }
}
