Feature: FlexSourceInspector
  In order to list unused files in a flex project or library
  As a CLI
  I want to be as objective as possible

  Scenario: i can ping
    When I run "flex-source-inspector ping"
    Then the output should contain "pong"

  Scenario: link report one
    When I run "flex-source-inspector inspect ../../spec/data/LinkReportTestProject/flex-src ../../spec/data/ApplicationOne_link-report.xml"
    Then the output should contain "NotUsedOne.as"
