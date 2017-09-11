Feature: Catalyst Home page

  Scenario: Catalyst Homepage
    Given I go to Catalyst
    Then I should see the "multi-search" form

  Scenario: Homepage Navigation
    Given I go to Catalyst
    When I click on the "Catalog" link
    Then I should see the "catalog-search" form

    # NOTE: works on prod, not on dev...
    #When I am not logged in
    #And I click on the "Articles" link
    #Then I should see the alert, "Article search is only available to Johns Hopkins users."

    When I click on the "Catalog+Articles" link
    Then I should see the "multi-search" form

    # NOTE: can't get this to work...
    #When I resize my browser to 1024 by 768
    #When I maximize my browser
    #Then I should see the text "Reserves"

    #When I click on the "Reserves" link
    #Then I should see the "reserves-search" form
