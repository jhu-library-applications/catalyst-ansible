Feature: Catalyst Search

  Scenario Outline: Catalyst Search
    Given I go to Catalyst
    And I am not logged in
    When I enter "<search_term>" into the search box
    And I click "Search"
    Then I should be taken to a search results page
    And I should see "<call_number>" on the page
    And I should see "<partial_title>" in a link
    When I click on a link for item "<bib_number>" which reads "<partial_title>"
    Then I should be taken to a detail page for the item with bib number "<bib_number>"
    And I should see "<partial_title>" in the header

    Examples:
    | search_term        | partial_title            | call_number           | bib_number  |
    | Beyoncé            | The Beyonce              | ML420.K675 B39 2016   | 6270400     |
    | Ta-Nehisi          | Between the world and me | E185.615 .C6335 2015  | 5654606     |
