@biolinux
Feature: Fetching Debian Manifest from Biolinux

  (Cloud)Biolinux provides a manifest of packages that are installed
  in the base installation. We want to parse the YAML manifest, and
  convert the information in a nice Biogems web page. The package
  list includes Debian Bio Med, BioLinux and other Debian packages, 
  including generic and science packages.

  Scenario: Fetch Debian package info
    Given I have a Debian package description in a BioLinux Manifest
    When I fetch Debian package info for "blast2"
    Then I should get the name "blast2" and description "Basic Local Alignment Search Tool"
    And I should get the popularity count of 64
    When I check the Bio Med information 
    Then it should check it is a Bio Med package

  Scenario: Fetch Debian BioLinux specific package info
    When I fetch Debian package info for "bio-linux-blast"
    Then I should get the name "bio-linux-blast" and description "Rapid searching of nucleotide and protein databases."
    And I should get the popularity count of 0
    When I check the Bio Med information 
    Then it should check it is not a Bio Med package
    And it should check it is a BioLinux package

  Scenario: Fetch Bio-Linux deb style package info
    When I fetch Debian package info for "gnuplot"
    And I should get the popularity count of 213 
    When I check the Bio Med information 
    Then it should check it is not a Bio Med package
    And it should check it is a science package
