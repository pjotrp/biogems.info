Feature: Fetch information from Rubygems.org

  Scenario: Fetch project information from rubygems.org
    Given I have the biogems.info project 
    When I fetch JSON through the rubygems API 
