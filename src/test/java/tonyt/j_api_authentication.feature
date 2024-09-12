@ignore
Feature: j_api_authentication

Background:
    * url baseUrl = authUrl + authApiKey
    * header Content-Type = contentType
    * header ssl = true
Scenario: POST firebase api sign in
    Given def jsonBody =
  """
  {
  "email": "#(jUsername)",
  "password": "#(jPassword)",
  "returnSecureToken": true
  }
  """
    And request data = jsonBody

    When method post
    Then status 200
    * def accessToken = response.idToken
