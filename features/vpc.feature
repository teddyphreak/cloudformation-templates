Feature: vpc.template

  Scenario: Validate vpc template
    Given template "vpc.json"
    Then aws cloudformation validate-template should succeed

  Scenario: Deploy vpc template
    Given template "vpc.json"
    Then aws cloudformation create-stack should succeed
