package com.example.workshop_spring_vault;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "custom")
public class AppProperties {
    private Transit transit = new Transit();
    private StaticSecret staticSecret = new StaticSecret();

    public Transit getTransit() {
        return transit;
    }

    public void setTransit(Transit transit) {
        this.transit = transit;
    }

    static class Transit {

        private String path;
        private String key;

        public String getPath() {
            return path;
        }

        public void setPath(String path) {
            this.path = path;
        }

        public String getKey() {
            return key;
        }

        public void setKey(String key) {
            this.key = key;
        }
    }

    public StaticSecret getStaticSecret() { return staticSecret; }

    public void setStaticSecret(StaticSecret staticSecret) {
        this.staticSecret = staticSecret;
    }

    static class StaticSecret {
        private String username;
        private String password;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }
}
