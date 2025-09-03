require "system_helper"

RSpec.describe "Client and case details section - DWP result flows", :vcr do
  before do
    login_as_a_provider
    visit providers_root_path
    create_an_application_and_complete_client_details(with_partner?)
    allow(BenefitCheckService).to receive(:call).with(@legal_aid_application).and_return(benefit_check_response)
    visit providers_legal_aid_application_check_provider_answers_path(@legal_aid_application)

    click_on "Save and continue"
  end

  let(:with_partner?) { false }

  context "when the applicant receives a passported benefit" do
    let(:benefit_check_response) do
      {
        benefit_checker_status: "Yes",
        confirmation_ref: SecureRandom.hex,
      }
    end

    scenario "the provider is routed through an interrupt page to the capital introductions" do
      expect(page).to have_css("h1", text: "DWP records show that your client receives a passporting benefit")

      click_on "Continue"
      expect(page.current_url).to eql providers_legal_aid_application_capital_introduction_url(@legal_aid_application)
      expect(page).to have_css("h1", text: "What you need to do")
    end
  end

  context "when the applicant is single and does not receive a passported benefit" do
    let(:benefit_check_response) do
      {
        benefit_checker_status: "No",
        confirmation_ref: SecureRandom.hex,
      }
    end

    scenario "when the provider agrees, they are routed through an interrupt page to the means path" do
      expect(page)
        .to have_title("DWP records show that your client does not get a passporting benefit. Is this correct?")
        .and have_css("h1", text: "DWP records show that your client does not get a passporting benefit. Is this correct?")
        .and have_button(text: "Yes, continue")
        .and have_link(text: "This is not correct", href: providers_legal_aid_application_check_client_details_path(@legal_aid_application))

      click_on "Yes, continue"
      # start of the income means flow
      expect(page.current_url).to eql providers_legal_aid_application_about_financial_means_url(@legal_aid_application)
      expect(page).to have_css("h1", text: "What you need to do")
    end

    scenario "when the provider disagrees, they are routed through an interrupt page to the capital introductions via the dwp override path" do
      expect(page).to have_css("h1", text: "DWP records show that your client does not get a passporting benefit. Is this correct?")

      click_on "This is not correct"
      expect(page).to have_css("h1", text: "Check your client's details")

      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Which passporting benefit does your client get?")

      govuk_choose("Universal Credit")
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Do you have evidence that your client receives Universal Credit?")

      govuk_choose("Yes")
      click_on "Save and continue"
      expect(page.current_url).to eql providers_legal_aid_application_capital_introduction_url(@legal_aid_application)
      expect(page).to have_css("h1", text: "What you need to do")
    end
  end

  context "when the applicant has a partner and does not receive a passported benefit" do
    let(:with_partner?) { true }
    let(:benefit_check_response) do
      {
        benefit_checker_status: "No",
        confirmation_ref: SecureRandom.hex,
      }
    end

    scenario "when the provider agrees, they are routed through an interrupt page to the means path" do
      expect(page).to have_css("h1", text: "DWP records show that your client does not get a passporting benefit. Is this correct?")

      click_on "Yes, continue"
      # start of the income means flow
      expect(page.current_url).to eql providers_legal_aid_application_about_financial_means_url(@legal_aid_application)
      expect(page).to have_css("h1", text: "What you need to do")
    end

    scenario "when the provider disagrees, and the client receives the benefit, they are routed through an interrupt page to the capital introductions via the dwp override path" do
      expect(page).to have_css("h1", text: "DWP records show that your client does not get a passporting benefit. Is this correct?")

      click_on "This is not correct"
      expect(page).to have_css("h1", text: "Does your client get the passporting benefit on their own or with a partner")

      govuk_choose("On their own")
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Check your client's details")

      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Which passporting benefit does your client get?")

      govuk_choose("Universal Credit")
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Do you have evidence that your client receives Universal Credit?")

      govuk_choose("Yes")
      click_on "Save and continue"
      expect(page.current_url).to eql providers_legal_aid_application_capital_introduction_url(@legal_aid_application)
      expect(page).to have_css("h1", text: "What you need to do")
    end

    scenario "when the provider disagrees, and the client receives a joint benefit, they are routed through an interrupt page to the capital introductions via the dwp override path" do
      expect(page).to have_css("h1", text: "DWP records show that your client does not get a passporting benefit. Is this correct?")

      click_on "This is not correct"
      expect(page).to have_css("h1", text: "Does your client get the passporting benefit on their own or with a partner")

      govuk_choose("With a partner")
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Check your client's and their partner's details")

      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Which joint passporting benefit does your client and their partner get?")

      govuk_choose("Universal Credit")
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Do you have evidence that your client is covered by their partner's Universal Credit?")

      govuk_choose("Yes")
      click_on "Save and continue"
      expect(page.current_url).to eql providers_legal_aid_application_capital_introduction_url(@legal_aid_application)
      expect(page).to have_css("h1", text: "What you need to do")
    end
  end
end
