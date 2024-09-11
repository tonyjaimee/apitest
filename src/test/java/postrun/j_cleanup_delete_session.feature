@ignore
Feature: Delete session
Background:
  * url baseUrl = baseUrl

Scenario: DELETE api/v1/session/delete_session
    Given path 'api/v1/session/delete_session'
    And param session_id = session_id
    When method delete
    Then status 200
    And print "#####Deleted session##### "+session_id