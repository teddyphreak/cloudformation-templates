Feature: vpc.template

  Scenario: Validate vpc template
    Given template "vpc.template"
    Then aws cloudformation validate-template should succeed

  Scenario: Deploy vpc template
    Given template "vpc.template"
    Then aws cloudformation create-stack should succeed
