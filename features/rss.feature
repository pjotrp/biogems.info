Feature: A RSS feed

  There should be a rss feed listing updates to biogemns and
  updates to blogs related to BioRuby and Biogems.

  Scenario: parsing a rss feed for a blog
    Given I have one rss blog feed configured
    When I parse the rss feed
    Then the resulting rss feed should have the same contents as the rss feed

  Scenario: parsing an atom feed for a blog
    Given I have one atom blog feed configured
    When I parse the atom feed
    Then the resulting rss feed should have the same contents as the atom feed

