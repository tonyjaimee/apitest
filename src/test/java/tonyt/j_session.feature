    # auto-format shortcut: Shift+Option+F
Feature: j_session
  Background:
    * url baseUrl = baseUrl
    
    @test_session_1
  Scenario Outline: POST api/v1/session (Success only)
 
    Given path 'api/v1/session', '/'
    
    And request data = read(<input_file>)

    When method post
    Then status <response_status>
    # Implement match logic based on JSON schema structure and data type (not value)
    And match response contains karate.filterKeys(read(<output_file>), response)
    * def currentSession = {'session_id':'#(response.session_id)'}
    And print "#####New session##### "+currentSession
    Examples:
      | input_file  | response_status | output_file |
      # valid payload
      | 'classpath:tonyt/data/j_session_post_1_input.json' | 200 | 'classpath:tonyt/data/j_session_post_1_output.json'|  
  
    @test_session_2
  Scenario Outline: POST api/v1/session
 
    Given path 'api/v1/session', '/'
    
    And request data = read(<input_file>)

    When method post
    Then status <response_status>
    # Implement match logic based on JSON schema structure and data type (not value)
    And match response contains karate.filterKeys(read(<output_file>), response)
    Examples:
      | input_file  | response_status | output_file |
      # valid payload
      | 'classpath:tonyt/data/j_session_post_1_input.json' | 200 | 'classpath:tonyt/data/j_session_post_1_output.json'|  
      # payload without session_name  
      | 'classpath:tonyt/data/j_session_post_2_input.json' | 422 | 'classpath:tonyt/data/j_session_post_2_output.json'|  
      # payload with empty Json body  
      | 'classpath:tonyt/data/j_session_post_3_input.json' | 422 | 'classpath:tonyt/data/j_session_post_3_output.json'| 
