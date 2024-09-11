@ignore
  Feature: Profile APIs
Background:
  # By design, you need to set url variable for every single feature file: 
  # https://stackoverflow.com/questions/56932789/set-url-for-all-features
  * url baseUrl
  
    @test_profile_1
  Scenario: GET api/v1/profile
    Given path 'api/v1/profile','/' 
    When method get
    Then status 200
    # store user_id
  * def currentUser = {'user_id':'#(response.user_id)'}
  And print currentUser
