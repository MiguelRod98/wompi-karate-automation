Feature: Transaction Service

  Background:
    * url api
    * def requestTemplates = read('classpath:data/requests/transaction.json')

  @buildTransactionRequest
  Scenario: Build Transaction Request
    * def paymentSourceId = karate.get('paymentSourceId')
    * if (!paymentSourceId) paymentSourceId = karate.call('classpath:services/payment-source-service.feature@CreatePaymentSource').paymentSourceId

    * def acceptanceResult = call read('classpath:services/acceptance-token-service.feature@GetAcceptanceToken')
    * def amount = karate.get('amount', 5000000)
    * def currency = karate.get('currency', 'COP')
    * def reference = karate.get('reference', 'TEST_TRX_' + timestamp())
    * def paymentType = karate.get('paymentType', 'NEQUI')
    * def customerEmail = karate.get('customerEmail', randomEmail())
    * def phoneNumber = karate.get('phoneNumber', approvedPhone)

    * def signatureData = reference + amount + currency + integrityKey
    * def MessageDigest = Java.type('java.security.MessageDigest')
    * def StandardCharsets = Java.type('java.nio.charset.StandardCharsets')
    * def md = MessageDigest.getInstance('SHA-256')
    * def hashBytes = md.digest(signatureData.getBytes(StandardCharsets.UTF_8))
    * def HexFormat = Java.type('java.util.HexFormat')
    * def generatedSignature = HexFormat.of().formatHex(hashBytes)
    * def signature = karate.get('signature', generatedSignature)

    * def transactionRequest = requestTemplates.createTransaction
    * set transactionRequest.amount_in_cents = amount
    * set transactionRequest.currency = currency
    * set transactionRequest.customer_email = customerEmail
    * set transactionRequest.acceptance_token = acceptanceResult.acceptanceToken
    * set transactionRequest.accept_personal_auth = acceptanceResult.personalDataAuthToken
    * set transactionRequest.signature = signature
    * set transactionRequest.payment_method.type = paymentType
    * set transactionRequest.payment_method.phone_number = phoneNumber
    * set transactionRequest.payment_method.payment_source_id = paymentSourceId
    * set transactionRequest.reference = reference

  @createTransaction
  Scenario: Create Transaction with Payment Source
    * def buildResult = call read('classpath:services/transaction-service.feature@buildTransactionRequest')
    * def transactionRequest = buildResult.transactionRequest

    Given path pathTransaction
    And header Authorization = 'Bearer ' + publicKey
    And request transactionRequest
    * configure retry = { count: 10, interval: 2000 }
    And retry until responseStatus == 201
    When method POST
    Then status 201
    * print 'Transaction ID:', response.data.id
    * print 'Transaction Status:', response.data.status
    * def transactionId = response.data.id
    * def transactionStatus = response.data.status

  @createTransactionInvalidAmount
  Scenario: Attempt to Create Transaction with Invalid Amount
    * def buildArgs = {}
    * set buildArgs.amount = karate.get('amount', 0)
    * set buildArgs.reference = 'TEST_INVALID_' + timestamp()
    * def incomingPaymentSourceId = karate.get('paymentSourceId')
    * if (incomingPaymentSourceId) buildArgs.paymentSourceId = incomingPaymentSourceId
    * def buildResult = call read('classpath:services/transaction-service.feature@buildTransactionRequest') buildArgs
    * def invalidRequest = buildResult.transactionRequest

    Given path pathTransaction
    And header Authorization = 'Bearer ' + publicKey
    And request invalidRequest
    When method POST
    Then status 422
    * match response.error.type == 'INPUT_VALIDATION_ERROR'
    * match response.error.messages.valid_amount_in_cents == '#[]'
    * match each response.error.messages.valid_amount_in_cents == '#string'

  @createTransactionInvalidSignature
  Scenario: Attempt to Create Transaction with Invalid Signature
    * def buildArgs = {}
    * set buildArgs.reference = 'TEST_INVALID_SIGNATURE_' + timestamp()
    * set buildArgs.signature = 'invalid_signature'
    * def incomingPaymentSourceId = karate.get('paymentSourceId')
    * if (incomingPaymentSourceId) buildArgs.paymentSourceId = incomingPaymentSourceId
    * def buildResult = call read('classpath:services/transaction-service.feature@buildTransactionRequest') buildArgs
    * def invalidRequest = buildResult.transactionRequest

    Given path pathTransaction
    And header Authorization = 'Bearer ' + publicKey
    And request invalidRequest
    When method POST
    Then status 422
    * match response.error.type == '#string'
    * def hasReason = response.error.reason != null
    * def hasMessages = response.error.messages != null
    * assert hasReason || hasMessages

  @createTransactionUnauthorized
  Scenario: Attempt to Create Transaction with Invalid Authorization
    * def buildArgs = {}
    * set buildArgs.reference = 'TEST_UNAUTHORIZED_' + timestamp()
    * def incomingPaymentSourceId = karate.get('paymentSourceId')
    * if (incomingPaymentSourceId) buildArgs.paymentSourceId = incomingPaymentSourceId
    * def buildResult = call read('classpath:services/transaction-service.feature@buildTransactionRequest') buildArgs
    * def unauthorizedRequest = buildResult.transactionRequest
    * def expectedStatus = karate.get('expectedStatus', 401)
    * def invalidPublicKey = karate.get('invalidPublicKey', 'invalid_public_key')

    Given path pathTransaction
    And header Authorization = 'Bearer ' + invalidPublicKey
    And request unauthorizedRequest
    When method POST
    And match responseStatus == expectedStatus
    * match response.error.type == '#string'
    * def hasReason = response.error.reason != null
    * def hasMessage = response.error.message != null
    * assert hasReason || hasMessage

  @getTransaction
  Scenario: Get Transaction by ID
    * def createArgs = {}
    * def incomingPaymentSourceId = karate.get('paymentSourceId')
    * if (incomingPaymentSourceId) createArgs.paymentSourceId = incomingPaymentSourceId
    * def incomingAmount = karate.get('amount')
    * if (incomingAmount) createArgs.amount = incomingAmount
    * def createResult = call read('classpath:services/transaction-service.feature@createTransaction') createArgs
    * def transactionId = createResult.transactionId
    
    Given path pathTransaction, transactionId
    When method GET
    Then status 200
    * print 'Transaction Status:', response.data.status
    * def transactionStatus = response.data.status

  @getTransactionNotFound
  Scenario: Get non-existent Transaction by ID
    * def transactionId = 'INVALID_TRANSACTION_ID_12345'

    Given path pathTransaction, transactionId
    When method GET
    Then status 404
    * match response == { error: { type: 'NOT_FOUND_ERROR', reason: '#string' } }
