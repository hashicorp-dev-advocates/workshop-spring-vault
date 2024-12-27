package com.example.workshop_spring_vault;

import com.fasterxml.jackson.annotation.JsonProperty;

record User(@JsonProperty(value="id") Long id,
            String name,
            String password) {
}
