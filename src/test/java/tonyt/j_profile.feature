    # auto-format shortcut: Shift+Option+F
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
    
    @test_profile_2
  Scenario Outline: PATCH api/v1/profile
 
    Given path 'api/v1/profile' , '/' 
    
    # Explicitly enforce trailing / to resolve FastAPI server 307 redirection response
    # As per https://github.com/karatelabs/karate#path
    # Because Karate strips trailing slashes if part of a path parameter, if you want to append a forward-slash to the end of the URL in the final HTTP request - make sure that the last path is a single '/'. For example, if your path has to be documents/ (and not just documents), use:
    # Given path 'documents', '/'
    
    And request data = read(<input_file>)

    When method patch
    Then status <response_status>
    And match response contains karate.filterKeys(read(<output_file>), response)
    Examples:
      | input_file  | response_status | output_file |
      # valid payload
      | 'classpath:tonyt/data/j_profile_patch_1.json' | 200 | 'classpath:tonyt/data/j_profile_patch_1.json'|  
      # payload with wrong user_id
      | 'classpath:tonyt/data/j_profile_patch_2_input.json' | 403 | 'classpath:tonyt/data/j_profile_patch_2_output.json'|
      # payload without user_id  
      | 'classpath:tonyt/data/j_profile_patch_3_input.json' | 422 | 'classpath:tonyt/data/j_profile_patch_3_output.json'|  
      # payload empty Json body  
      | 'classpath:tonyt/data/j_profile_patch_4_input.json' | 422 | 'classpath:tonyt/data/j_profile_patch_4_output.json'|  
