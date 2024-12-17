Then("I have completed an application where client and partner are both employed and {string} have/has additional information") do |extra_info|
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant_and_employed_partner,
    :with_non_passported_state_machine,
    :provider_entering_merits,
    :with_domestic_abuse_summary,
    :with_merits_statement_of_case,
  )

  case extra_info
  when "both"
    @legal_aid_application.applicant.update!(extra_employment_information_details: "This is a reason!")
    @legal_aid_application.partner.update!(extra_employment_information_details: "This is also a reason!")
  when "client"
    @legal_aid_application.applicant.update!(extra_employment_information_details: "This is a reason!")
  when "partner"
    @legal_aid_application.partner.update!(extra_employment_information_details: "This is a reason!")
  end

  create(:legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application)
  login_as @legal_aid_application.provider
end

Given("I visit {string}") do |step|
  page = step.tr(" ", "_")
  url = "providers_legal_aid_application_#{page}_path"
  path = Rails.application.routes.url_helpers.send(url, @legal_aid_application)
  visit(path)
end
