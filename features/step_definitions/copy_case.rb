Given("I have previously created an application with reference {string}") do |application_ref|
  create(:legal_aid_application,
         :with_passported_state_machine,
         :at_assessment_submitted,
         application_ref:,
         provider: @registered_provider)
end
