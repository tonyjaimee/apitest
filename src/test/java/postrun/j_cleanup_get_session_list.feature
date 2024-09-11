@ignore
Feature: Get Session for the purpose of invoking POST /api/v1/chat
Background:
  * url baseUrl = baseUrl

Scenario: GET api/v1/session/session_list

  # for this api, no need to append "/"
  Given path 'api/v1/session/session_list' 

  When method get
  Then status 200
  # store list of session_id
  * def sessionIdList = $[*].session_id

  # Convert list to JSON like {session_id: abc}, {session_id: def, ...}
  * def sessionList = karate.mapWithKey(sessionIdList, 'session_id')
  And print sessionList