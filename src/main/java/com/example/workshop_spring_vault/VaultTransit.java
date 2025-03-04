package com.example.workshop_spring_vault;

import org.springframework.vault.core.VaultOperations;
import org.springframework.vault.core.VaultTemplate;

class VaultTransit {
    private final VaultOperations vault;
    private final String path;
    private final String key;

    VaultTransit(AppProperties properties, VaultTemplate vaultTemplate) {
        this.vault = vaultTemplate;
        this.path = properties.getTransit().getPath();
        this.key = properties.getTransit().getKey();
    }

    String decrypt(String payload) {
        return vault.opsForTransit(path).decrypt(key, payload);
    }

    String encrypt(String payload) {
        return vault.opsForTransit(path).encrypt(key, payload);
    }
}
