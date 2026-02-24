@nequi @transactions
Feature: Wompi Nequi Payment Transactions

  Background:
    * def sharedPaymentSourceResult = callonce read('classpath:services/payment-source-service.feature@CreatePaymentSource')
    * def sharedPaymentSourceId = sharedPaymentSourceResult.paymentSourceId

  @smoke @positive
  Scenario: Successful transaction with Nequi payment method
    * def transactionResult = call read('classpath:services/transaction-service.feature@createTransaction') { paymentSourceId: '#(sharedPaymentSourceId)' }
    * match transactionResult.transactionId == '#string'

  @positive
  Scenario: Create transaction with different valid amounts
    * def transactionResult = call read('classpath:services/transaction-service.feature@createTransaction') { paymentSourceId: '#(sharedPaymentSourceId)', amount: 15000000 }
    * match transactionResult.transactionId == '#string'

  @positive
  Scenario: Create transaction with minimum valid amount
    * def transactionResult = call read('classpath:services/transaction-service.feature@createTransaction') { paymentSourceId: '#(sharedPaymentSourceId)', amount: 150000 }
    * match transactionResult.transactionId == '#string'

  @positive
  Scenario: Retrieve transaction details by ID
    * def getTransactionResult = call read('classpath:services/transaction-service.feature@getTransaction') { paymentSourceId: '#(sharedPaymentSourceId)' }
    * match getTransactionResult.transactionStatus == '#string'

  @negative
  Scenario: Attempt to create transaction with invalid amount
    * call read('classpath:services/transaction-service.feature@createTransactionInvalidAmount') { paymentSourceId: '#(sharedPaymentSourceId)', amount: 0 }

  @negative
  Scenario: Attempt to create transaction with invalid signature
    * call read('classpath:services/transaction-service.feature@createTransactionInvalidSignature') { paymentSourceId: '#(sharedPaymentSourceId)' }

  @negative
  Scenario: Attempt to create payment source with invalid phone number
    * call read('classpath:services/payment-source-service.feature@GetNequiTokenInvalidPhone')

  @negative
  Scenario: Attempt to create transaction with invalid authorization
    * call read('classpath:services/transaction-service.feature@createTransactionUnauthorized') { paymentSourceId: '#(sharedPaymentSourceId)', expectedStatus: 401 }

  @negative
  Scenario: Attempt to get non-existent transaction
    * call read('classpath:services/transaction-service.feature@getTransactionNotFound')
