package com.wompi.automation.runners.features;

import com.intuit.karate.junit5.Karate;

public class NequiTransactionsRunner {

    @Karate.Test
    Karate testNequiTransactions() {
        return Karate.run("classpath:features/nequi-transactions.feature");
    }

    @Karate.Test
    Karate smoke() {
        return Karate.run("classpath:features/nequi-transactions.feature").tags("@smoke");
    }

    @Karate.Test
    Karate positive() {
        return Karate.run("classpath:features/nequi-transactions.feature").tags("@positive");
    }

    @Karate.Test
    Karate negative() {
        return Karate.run("classpath:features/nequi-transactions.feature").tags("@negative");
    }
}
