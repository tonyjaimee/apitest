    # auto-format shortcut: Shift+Option+F
Feature: Clean up all existing sessions
Background:
  * url baseUrl = baseUrl
  
  * def responseUser = callonce read('j_cleanup_get_profile.feature')
  * def currentUser = responseUser.currentUser

  * def responseSessionList = callonce read('j_cleanup_get_session_list.feature')
  * def sessionList = responseSessionList.sessionList
  
  # Generate JSON payload used for DELETE /api/v1/session/remove_user_from_session
  # E.g., the output will be {"session_id": "123", "user_id_to_remove": "user1"}
  # How it works? "map" function will iterate through each element inside the sessionList, then create "user_id_to_remove" element then set value to the current user id
  * def data = sessionList.map(x => { x.user_id_to_remove = currentUser.user_id; return x })
  And print data

  # Remove user from 1..N sessions
  * def removeUserFromSession = call read('j_cleanup_remove_user_from_session.feature') data

  # Remove 1..N sessions
  * def deleteSession = call read('j_cleanup_delete_session.feature') sessionList

Scenario: Clean up is completed
   * print 'Clean up is completed'