Feature: Acceptance Token Service

  Background:
    * url api

  @GetAcceptanceToken
  Scenario: Get Acceptance Token
    Given path pathAcceptanceToken + publicKey
    When method GET
    Then status 200
    * def acceptanceToken = response.data.presigned_acceptance.acceptance_token
    * def personalDataAuthToken = response.data.presigned_personal_data_auth.acceptance_token
    And match acceptanceToken == '#string'
    And match personalDataAuthToken == '#string'
    * def merchantEmail = response.data.email
    * def merchantPhone = response.data.phone_number
