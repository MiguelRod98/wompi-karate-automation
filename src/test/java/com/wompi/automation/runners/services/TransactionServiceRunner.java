package com.wompi.automation.runners.services;

import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.Disabled;

@Disabled("Service utility feature; executed via business features.")
public class TransactionServiceRunner {

    @Karate.Test
    Karate testTransactionService() {
        return Karate.run("classpath:services/transaction-service.feature");
    }
}
