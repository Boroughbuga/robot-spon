*** Settings ***
Documentation    Suite description
Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

*** Test Cases ***
Test1:EmptyChasisList  #check chasis list, pass if list is empty.
    [Tags]    Sprint6

    Provided precondition
    When action
    Then check expectations

*** Keywords ***
Provided precondition
    Setup system under test