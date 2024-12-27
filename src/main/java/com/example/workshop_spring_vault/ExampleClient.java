package com.example.workshop_spring_vault;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

class ExampleClient {
    private final AppProperties properties;

    ExampleClient(AppProperties properties) {
        this.properties = properties;
    }

    public AppProperties getProperties() {
        return properties;
    }
}
