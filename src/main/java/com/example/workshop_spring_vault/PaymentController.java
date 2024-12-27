package com.example.workshop_spring_vault;

import org.springframework.http.MediaType;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Controller;
import org.springframework.vault.core.VaultTemplate;
import org.springframework.web.bind.annotation.*;

import javax.sql.DataSource;
import java.util.Collection;
import java.util.UUID;

@Controller
@ResponseBody
class PaymentController {
    private final JdbcClient db;
    private final VaultTransit vaultTransit;

    PaymentController(DataSource dataSource,
                      AppProperties appProperties,
                      VaultTemplate vaultTemplate) {
        this.db = JdbcClient.create(dataSource);
        this.vaultTransit = new VaultTransit(appProperties, vaultTemplate);
    }

    @GetMapping("/paymentcard/{id}")
    Collection<Payment> getPaymentByID(@PathVariable String id) {
        return this.db
                .sql(String.format("SELECT * FROM payment_card WHERE id = '%s'", id))
                .query((rs, rowNum) -> new Payment(
                        rs.getLong("id"),
                        rs.getLong("user_id"),
                        rs.getString("name"),
                        rs.getString("number").startsWith("vault") ?
                                vaultTransit.decrypt(rs.getString("number")) :
                                rs.getString("number"),
                        rs.getString("expiry"),
                        rs.getString("cv3")
                )).list();
    }

    @PostMapping(path = "/paymentcard",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    Collection<Payment> createPayment(@RequestBody Payment request) {
        var id = UUID.randomUUID().getMostSignificantBits() & Long.MAX_VALUE;
        var statement = String.format(
                "INSERT INTO payment_card(user_id, name, number, expiry, cv3) "
                        + "VALUES('%s', '%s', '%s', '%s', '%s')",
                request.userId(),
                request.name(),
                request.number(),
                request.expiry(),
                request.cv3());
        this.db.sql(statement).update();

        return this.db
                .sql(String.format("SELECT * FROM payment_card WHERE id = '%s'", request.id()))
                .query((rs, rowNum) -> new Payment(
                        rs.getLong("id"),
                        rs.getLong("user_id"),
                        rs.getString("name"),
                        rs.getString("number").startsWith("vault") ?
                                vaultTransit.decrypt(rs.getString("number")) :
                                rs.getString("number"),
                        rs.getString("expiry"),
                        rs.getString("cv3")
                )).list();
    }
}
