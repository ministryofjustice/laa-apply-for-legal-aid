Given("I previously created a passported application with multiple_proceedings and left on the {string} page") do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :without_own_home,
    :with_multiple_proceeding_types_inc_section8,
    :with_no_other_assets,
    :with_policy_disregards,
    :with_passported_state_machine,
    :checking_passported_answers,
    provider: create(:provider),
    provider_step: provider_step.downcase,
  )
  login_as @legal_aid_application.provider
end

Then(/I should be on the (.*?) page with (.*?) regex/) do |view_name, text|
  expect(page).to have_current_path(/#{view_name}/)
  expect(page).to have_content(/#{text}/)
end

Then(/^I should (see|not see) regex (.*?)$/) do |visible, text|
  if visible.eql?("see")
    expect(page).to have_content(/#{text}/)
  else
    expect(page).not_to have_content(/#{text}/)
  end
end

When("I search for non-existent organisation") do
  proxy
    .stub("https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk:443/organisation_searches", method: "post")
    .and_return(
      headers: {
        "Access-Control-Allow-Origin" => "*",
      },
      code: 200,
      body: { success: false, data: [] }.to_json,
    )

  fill_in("organisation-search-input", with: "cakes")

  expect(page).to have_css(".no-organisation-items", visible: :visible)
end

When("I search for organisation {string}") do |search_terms|
  response_body = case search_terms

                  when "bab"
                    {
                      success: true,
                      data: [
                        {
                          name: "Babergh District Council",
                          ccms_opponent_id: "280370",
                          ccms_type_code: "LA",
                          ccms_type_text: "Local Authority",
                          name_headline: "<mark>Babergh</mark> District Council",
                          type_headline: "Local Authority",
                        },
                      ],
                    }
                  when "ang", "ang loc"
                    {
                      success: true,
                      data: [
                        {
                          name: "Angus Council",
                          ccms_opponent_id: "280361",
                          ccms_type_code: "LA",
                          ccms_type_text: "Local Authority",
                          name_headline: "<mark>Angus</mark> Council",
                          type_headline: "<mark>Local</mark> Authority",
                        },
                        {
                          name: "Isle of Anglesey County Council",
                          ccms_opponent_id: "281357",
                          ccms_type_code: "LA",
                          ccms_type_text: "Local Authority",
                          name_headline: "Isle of <mark>Anglesey</mark> County Council",
                          type_headline: "<mark>Local</mark> Authority",
                        },
                      ],
                    }
                  when "prison r"
                    {
                      success: true,
                      data: [
                        {
                          name: "Ranby",
                          ccms_opponent_id: "379046",
                          ccms_type_code: "HMO",
                          ccms_type_text: "HM Prison or Young Offender Institute",
                          name_headline: "<mark>Ranby</mark>",
                          type_headline: "HM <mark>Prison</mark> or Young Offender Institute",
                        },
                        {
                          name: "Risley",
                          ccms_opponent_id: "380677",
                          ccms_type_code: "HMO",
                          ccms_type_text: "HM Prison or Young Offender Institute",
                          name_headline: "<mark>Risley</mark>",
                          type_headline: "HM <mark>Prison</mark> or Young Offender Institute",
                        },
                        {
                          name: "Rye Hill",
                          ccms_opponent_id: "380678",
                          ccms_type_code: "HMO",
                          ccms_type_text: "HM Prison or Young Offender Institute",
                          name_headline: "<mark>Rye</mark> Hill",
                          type_headline: "HM <mark>Prison</mark> or Young Offender Institute",
                        },
                      ],
                    }
                  else
                    {
                      success: false,
                      data: [],
                    }
                  end
  proxy
      .stub("https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk:443/organisation_searches", method: "post")
      .and_return(
        headers: {
          "Access-Control-Allow-Origin" => "*",
        },
        code: 200,
        body: response_body.to_json,
      )
  fill_in("organisation-search-input", with: search_terms)
end

Then("the organisation result list on page returns a {string} message") do |string|
  expect(page).to have_css(".no-organisation-items", text: string, visible: :visible)
end

# NOTE: this step does not work unless put after the step "the organisation suggestions include {string}" :(
Then(/^organisation suggestions has (\d+) result[s]?$/) do |count|
  expect(page).to have_css(".organisation-item", visible: :visible, count:)
end

Then("organisation search field is empty") do
  expect(page).to have_field("organisation-search-input", with: "")
end

Then("organisation search field is not visible") do
  expect(page).to have_field("organisation-search-input", visible: :hidden)
end

When("the organisation suggestions include {string}") do |string|
  within("#organisation-list") do
    expect(page).to have_content(/#{string}/m)
  end
end

Then(/^I can see the highlighted search term "(.*)" (\d+) time[s]?$/) do |string, count|
  expect(page).to have_css("mark", visible: :visible, text: string, count:)
end

Then("I select an organisation type {string} from the list") do |text|
  select(text, from: "application-merits-task-opponent-organisation-type-ccms-code-field")
end
