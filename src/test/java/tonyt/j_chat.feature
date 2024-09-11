    # auto-format shortcut: Shift+Option+F
Feature: Chat APIs
Background:
  * url baseUrl = baseUrl
    
  # Must use call for the clean up job, NOT callonce
   * def response = callonce read('j_session.feature@test_session_1')
   * def newSession = response.currentSession
  
  @test_chat_1
Scenario: POST api/v1/chat (Success)

  Given path 'api/v1/chat' , '/' 
  * def chatPayload = 
  """
  {
    "message":"hello there",
    "link":"None",
    "session_id":'#(newSession.session_id)',
    "char_id":2,
    "senderId":"None",
    "messageType":"text",
    "messageId":"None",
    "type":"human",
    "j_role":"friend"
 }
 """
  # Explicitly enforce trailing / to resolve FastAPI server 307 redirection response
  # As per https://github.com/karatelabs/karate#path
  # Because Karate strips trailing slashes if part of a path parameter, if you want to append a forward-slash to the end of the URL in the final HTTP request - make sure that the last path is a single '/'. For example, if your path has to be documents/ (and not just documents), use:
  # Given path 'documents', '/'
  
  And request data = chatPayload
  When method post
  Then status 200
  
  @test_chat_2
Scenario Outline: POST api/v1/session (Failure)

  Given path 'api/v1/session', '/'
  
  And request data = read(<input_file>)

  When method post
  Then status <response_status>
  # Implement match logic based on JSON schema structure and data type (not value)
  And match response contains karate.filterKeys(read(<output_file>), response)
  Examples:
    | input_file  | response_status | output_file |
    # missing session_id
    | 'classpath:tonyt/data/j_chat_post_1_input.json' | 422 | 'classpath:tonyt/data/j_chat_post_1_output.json'|  
    # missing char_id 
    | 'classpath:tonyt/data/j_chat_post_2_input.json' | 422 | 'classpath:tonyt/data/j_chat_post_2_output.json'|  
    # invalid message_type (<> 'text')
    # | 'classpath:tonyt/j_chat_post_3_input.json' | 422 | 'classpath:tonyt/j_chat_post_3_output.json'| 
     # invalid type (<> 'human') 
    # | 'classpath:tonyt/j_chat_post_4_input.json' | 422 | 'classpath:tonyt/j_chat_post_4_output.json'| 