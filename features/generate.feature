Feature:
  In order to generate promocode
  As a client software developer
  I need to be able to generate random alphanumeric and numeric promocodes

  Scenario: Generate a alphanumeric promocode
    When I add "Content-Type" header equal to "application/json"
    And I add "Accept" header equal to "application/json"
    And I send a "POST" request to "/promocodes/generate" with body:
    """
    {
      "format": "alpha",
      "discount": "10.00",
      "maxUsageCount": "1000"
    }
    """
    Then the response status code should be 201
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "message" should contain "OK"
    And the JSON node "result.code" should match "/[a-zA-Z0-9]+/"

  Scenario: Generate a numeric promocode
    When I add "Content-Type" header equal to "application/json"
    And I add "Accept" header equal to "application/json"
    And I send a "POST" request to "/promocodes/generate" with body:
    """
    {
      "format": "num",
      "discount": "10.00",
      "maxUsageCount": "1000"
    }
    """
    Then the response status code should be 201
    And the response should be in JSON
    And the header "Content-Type" should be equal to "application/json"
    And the JSON node "message" should contain "OK"
    And the JSON node "result.code"  should match "/\d+/"
