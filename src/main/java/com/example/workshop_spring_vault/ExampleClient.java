package com.example.workshop_spring_vault;

class ExampleClient {
    private final AppProperties properties;

    ExampleClient(AppProperties properties) {
        this.properties = properties;
    }

    public AppProperties getProperties() {
        return properties;
    }
}
