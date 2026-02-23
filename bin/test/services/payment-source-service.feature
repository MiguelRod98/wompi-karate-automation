@ignore
Feature: Payment Source Service

  Background:
    * url api
    * def requestTemplates = read('classpath:data/requests/payment-source.json')

  @GetNequiToken
  Scenario: Get Nequi Token
    * def phoneNumber = approvedPhone
    
    Given path pathNequiToken
    And header Authorization = 'Bearer ' + publicKey
    And request { phone_number: '#(phoneNumber)' }
    When method POST
    Then status 200
    * print 'Nequi Token ID:', response.data.id
    * def nequiToken = response.data.id

  @CreatePaymentSource
  Scenario: Create Payment Source
    * def acceptanceResult = call read('classpath:services/acceptance-token-service.feature@GetAcceptanceToken')
    * def acceptanceToken = acceptanceResult.acceptanceToken
    * def personalDataAuthToken = acceptanceResult.personalDataAuthToken
    * def customerEmail = randomEmail()
    * def phoneNumber = approvedPhone
    * def paymentType = 'NEQUI'
    
    * def nequiTokenResult = call read('classpath:services/payment-source-service.feature@GetNequiToken')
    * def nequiToken = nequiTokenResult.nequiToken
    
    * def paymentSourceRequest = requestTemplates.createPaymentSource
    * set paymentSourceRequest.type = paymentType
    * set paymentSourceRequest.token = nequiToken
    * set paymentSourceRequest.customer_email = customerEmail
    * set paymentSourceRequest.acceptance_token = acceptanceToken
    * set paymentSourceRequest.accept_personal_auth = personalDataAuthToken
    
    Given path pathPaymentSource
    And header Authorization = 'Bearer ' + privateKey
    And request paymentSourceRequest
    When method POST
    Then status 201
    * print 'Payment Source ID:', response.data.id
    * def paymentSourceId = response.data.id
    
    * sleep(20)