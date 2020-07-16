Feature:
  In order to apply promocode
  As a client software developer
  I need to be able to apply promocode by specified code

  Scenario: Apply an alphanumeric code
    Given the following promocodes exists:
      | id | code        | discount | maxUsageCount | useCount |
      | 1  | AzL8n0Y58m7 | 10.00    | 1000          | 0        |
      | 2  | 123456      | 15.00    | 500           | 0        |
    When I add "Content-Type" header equal to "application/json"
    And I add "Accept" header equal to "application/json"
    And I send a "POST" request to "/promocodes/apply" with body:
    """
    {
      "code": "AzL8n0Y58m7",
    }
    """
    Then the response status code should be 200
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "message" should contain "OK"

  Scenario: Apply an alphanumeric code
    Given the following promocodes exists:
      | id | code        | discount | maxUsageCount | useCount |
      | 1  | AzL8n0Y58m7 | 10.00    | 1000          | 0        |
      | 2  | 123456      | 15.00    | 500           | 0        |
    When I add "Content-Type" header equal to "application/json"
    And I add "Accept" header equal to "application/json"
    And I send a "POST" request to "/promocodes/generate" with body:
    """
    {
      "code": "123456",
    }
    """
    Then the response status code should be 201
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "message" should contain "OK"
    And the JSON node "result.code" should match "/\d+/"

  Scenario: Cannot apply non-existent code
    Given the following promocodes exists:
      | id | code        | discount | maxUsageCount | useCount |
      | 1  | AzL8n0Y58m7 | 10.00    | 1000          | 0        |
      | 2  | 123456      | 15.00    | 500           | 0        |
    When I add "Content-Type" header equal to "application/json"
    And I add "Accept" header equal to "application/json"
    And I send a "POST" request to "/promocodes/generate" with body:
    """
    {
      "format": "zz",
    }
    """
    Then the response status code should be 404
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "message" should not contain "OK"

  Scenario: Cannot apply runned out-of-stock code
    Given the following promocodes exists:
      | id | code        | discount | maxUsageCount | useCount |
      | 1  | AzL8n0Y58m7 | 10.00    | 1000          | 1000     |
      | 2  | 123456      | 15.00    | 500           | 0        |
    When I add "Content-Type" header equal to "application/json"
    And I add "Accept" header equal to "application/json"
    And I send a "POST" request to "/promocodes/generate" with body:
    """
    {
      "format": "AzL8n0Y58m7",
    }
    """
    Then the response status code should be 500
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "message" should not contain "OK"


