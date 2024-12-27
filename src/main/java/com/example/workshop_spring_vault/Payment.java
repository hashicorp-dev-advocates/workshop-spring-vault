package com.example.workshop_spring_vault;

import com.fasterxml.jackson.annotation.JsonProperty;

record Payment(@JsonProperty(value="id") Long id,
               @JsonProperty(value = "user_id") Long userId,
               String name,
               @JsonProperty(value = "number") String number,
               @JsonProperty(value = "expiry") String expiry,
               @JsonProperty(value = "cv3") String cv3) {
}