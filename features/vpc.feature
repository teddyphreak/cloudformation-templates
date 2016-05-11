Feature: vpc.template

  Scenario: Deploy vpc template
    Given template "vpc.template"
    When the template is deployed with stack name "test-vpc"
    Then aws cloudformation create-stack should succeed
