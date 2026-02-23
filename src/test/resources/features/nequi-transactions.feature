@nequi @transactions
Feature: Wompi Nequi Payment Transactions

  Background:
    * def sharedPaymentSourceResult = callonce read('classpath:services/payment-source-service.feature@CreatePaymentSource')
    * def sharedPaymentSourceId = sharedPaymentSourceResult.paymentSourceId

  @smoke @positive
  Scenario: Successful transaction with Nequi payment method
    * def transactionResult = call read('classpath:services/transaction-service.feature@createTransaction') { paymentSourceId: '#(sharedPaymentSourceId)' }
    * assert transactionResult.transactionId != null

  @positive
  Scenario: Create transaction with different valid amounts
    * def transactionResult = call read('classpath:services/transaction-service.feature@createTransaction') { paymentSourceId: '#(sharedPaymentSourceId)', amount: 15000000 }
    * assert transactionResult.transactionId != null

  @positive
  Scenario: Retrieve transaction details by ID
    * def getTransactionResult = call read('classpath:services/transaction-service.feature@getTransaction') { paymentSourceId: '#(sharedPaymentSourceId)' }
    * match getTransactionResult.transactionStatus == '#string'

  @negative
  Scenario: Attempt to create transaction with invalid amount
    * def acceptanceResult = call read('classpath:services/acceptance-token-service.feature@GetAcceptanceToken')
    * def requestTemplates = read('classpath:data/requests/transaction.json')
    
    * def invalidRequest = requestTemplates.createTransaction
    * set invalidRequest.amount_in_cents = 0
    * set invalidRequest.currency = 'COP'
    * set invalidRequest.customer_email = acceptanceResult.merchantEmail
    * set invalidRequest.acceptance_token = acceptanceResult.acceptanceToken
    * set invalidRequest.signature = 'invalid_signature'
    * set invalidRequest.payment_method.type = 'NEQUI'
    * set invalidRequest.payment_method.phone_number = approvedPhone
    * set invalidRequest.payment_method.payment_source_id = sharedPaymentSourceId
    * set invalidRequest.reference = 'TEST_INVALID'
    
    Given url api
    And path pathTransaction
    And header Authorization = 'Bearer ' + publicKey
    And request invalidRequest
    When method POST
    Then status 422

  @negative
  Scenario: Attempt to create payment source with invalid phone number
    * call read('classpath:services/payment-source-service.feature@GetNequiTokenInvalidPhone')

  @negative
  Scenario: Attempt to get non-existent transaction
    * call read('classpath:services/transaction-service.feature@getTransactionNotFound')
