@ignore
Feature: Delete session
Background:
  * url baseUrl = baseUrl

Scenario: DELETE api/v1/session/remove_user_from_session
    Given path 'api/v1/session/remove_user_from_session'
    And request { session_id: '#(session_id)', user_id_to_remove: '#(user_id_to_remove)' }
    When method delete
    Then status 200
    And print "#####Remove user##### "+user_id_to_remove