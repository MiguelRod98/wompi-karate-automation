@ignore
Feature: Transaction Service

  Background:
    * url api
    * def requestTemplates = read('classpath:data/requests/transaction.json')

  @createTransaction
  Scenario: Create Transaction with Payment Source
    * def paymentSourceResult = call read('classpath:services/payment-source-service.feature@CreatePaymentSource')
    * def paymentSourceId = paymentSourceResult.paymentSourceId
    
    * def acceptanceResult = call read('classpath:services/acceptance-token-service.feature@GetAcceptanceToken')
    * def acceptanceToken = acceptanceResult.acceptanceToken
    * def personalDataAuthToken = acceptanceResult.personalDataAuthToken
    * def customerEmail = randomEmail()
    * def phoneNumber = approvedPhone
    
    * def amount = 5000000
    * def currency = 'COP'
    * def reference = 'TEST_TRX_' + timestamp()
    * def paymentType = 'NEQUI'
    
    * def signatureData = reference + amount + currency + integrityKey
    * def MessageDigest = Java.type('java.security.MessageDigest')
    * def StandardCharsets = Java.type('java.nio.charset.StandardCharsets')
    * def md = MessageDigest.getInstance('SHA-256')
    * def hashBytes = md.digest(signatureData.getBytes(StandardCharsets.UTF_8))
    * def HexFormat = Java.type('java.util.HexFormat')
    * def signature = HexFormat.of().formatHex(hashBytes)
    
    * def transactionRequest = requestTemplates.createTransaction
    * set transactionRequest.amount_in_cents = amount
    * set transactionRequest.currency = currency
    * set transactionRequest.customer_email = customerEmail
    * set transactionRequest.acceptance_token = acceptanceToken
    * set transactionRequest.accept_personal_auth = personalDataAuthToken
    * set transactionRequest.signature = signature
    * set transactionRequest.payment_method.type = paymentType
    * set transactionRequest.payment_method.phone_number = phoneNumber
    * set transactionRequest.payment_method.payment_source_id = paymentSourceId
    * set transactionRequest.reference = reference

    Given path pathTransaction
    And header Authorization = 'Bearer ' + publicKey
    And request transactionRequest
    When method POST
    Then status 201
    * print 'Transaction ID:', response.data.id
    * print 'Transaction Status:', response.data.status
    * def transactionId = response.data.id
    * def transactionStatus = response.data.status

  @getTransaction
  Scenario: Get Transaction by ID
    * def createResult = call read('classpath:services/transaction-service.feature@createTransaction')
    * def transactionId = createResult.transactionId
    
    Given path pathTransaction, transactionId
    When method GET
    Then status 200
    * print 'Transaction Status:', response.data.status
    * def transactionStatus = response.data.status
