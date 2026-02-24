@ignore
Feature: Setup utilities for test execution

  Scenario: Initialize config
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() + '' }
    * def uuid = function(){ return java.util.UUID.randomUUID().toString() }
    * def generateReference = function(prefix){ return prefix + '_' + java.lang.System.currentTimeMillis() }
    * def approvedPhone = '3991111111'
    * def declinedPhone = '3992222222'
    * def randomEmail = function(){ return 'test_' + java.lang.System.currentTimeMillis() + '@wompi.com' }
