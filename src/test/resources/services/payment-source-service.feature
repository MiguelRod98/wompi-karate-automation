Feature: Payment Source Service

  Background:
    * url api
    * def requestTemplates = read('classpath:data/requests/payment-source.json')

  @GetNequiToken
  Scenario: Get Nequi Token
    * def phoneNumber = karate.get('phoneNumber', approvedPhone)
    * def expectedStatus = karate.get('expectedStatus', 200)
    
    Given path pathNequiToken
    And header Authorization = 'Bearer ' + publicKey
    And request { phone_number: '#(phoneNumber)' }
    When method POST
    And match responseStatus == expectedStatus
    * if (expectedStatus == 200) karate.log('Nequi Token ID:', response.data.id)
    * if (expectedStatus == 200) karate.set('nequiToken', response.data.id)

  @WaitNequiTokenApproved
  Scenario: Wait for Nequi Token Approval
    * def tokenId = karate.get('tokenId')
    * if (!tokenId) tokenId = karate.call('classpath:services/payment-source-service.feature@GetNequiToken').nequiToken
    * match tokenId == '#string'

    Given path pathNequiToken, tokenId
    * configure retry = { count: 60, interval: 1000 }
    And retry until responseStatus == 200 && response.data.status == 'APPROVED'
    When method GET
    Then status 200
    And match response.data.status == 'APPROVED'

  @GetNequiTokenInvalidPhone
  Scenario: Get Nequi Token with Invalid Phone
    * def phoneNumber = '123'
    * def expectedStatus = 422
    * def invalidPhoneResult = call read('classpath:services/payment-source-service.feature@GetNequiToken')
    * match invalidPhoneResult.response == { error: { type: 'UNPROCESSABLE', reason: '#string' } }

  @CreatePaymentSource
  Scenario: Create Payment Source
    * def acceptanceResult = call read('classpath:services/acceptance-token-service.feature@GetAcceptanceToken')
    * def acceptanceToken = acceptanceResult.acceptanceToken
    * def personalDataAuthToken = acceptanceResult.personalDataAuthToken
    * def customerEmail = randomEmail()
    * def phoneNumber = approvedPhone
    * def paymentType = 'NEQUI'
    
    * def nequiTokenResult = call read('classpath:services/payment-source-service.feature@GetNequiToken') { phoneNumber: '#(phoneNumber)', expectedStatus: 200 }
    * def nequiToken = nequiTokenResult.nequiToken
    * call read('classpath:services/payment-source-service.feature@WaitNequiTokenApproved') { tokenId: '#(nequiToken)' }
    
    * def paymentSourceRequest = requestTemplates.createPaymentSource
    * set paymentSourceRequest.type = paymentType
    * set paymentSourceRequest.token = nequiToken
    * set paymentSourceRequest.customer_email = customerEmail
    * set paymentSourceRequest.acceptance_token = acceptanceToken
    * set paymentSourceRequest.accept_personal_auth = personalDataAuthToken

    Given path pathPaymentSource
    And header Authorization = 'Bearer ' + privateKey
    And request paymentSourceRequest
    * configure retry = { count: 20, interval: 2000 }
    And retry until responseStatus == 201
    When method POST
    Then status 201
    * print 'Payment Source ID:', response.data.id
    * def paymentSourceId = response.data.id
