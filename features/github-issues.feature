Feature: Fetch github issues

  When a Ruby biogem project has listed issues we should be able to 
  fetch them as a JSON object

  Scenario: Fetch all open issues from the biogems.info project
    Given I have the biogems.info project on github
    When I fetch JSON through the github issues API 
    Then I should have fetched at least one issue
    And the list should contain the open cucumber test issue
