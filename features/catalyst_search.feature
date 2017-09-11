Feature: Catalyst Search

  Scenario: Catalyst Search
    Given I go to Catalyst
    And I am not logged in
    When I enter "The Beyoncé effect" into the search box
    And I click "Search"
    Then I should see "The Beyonce" in a link
    Then I click on a link having partial text "The Beyonce"
    Then I should see "The Beyonce" header
