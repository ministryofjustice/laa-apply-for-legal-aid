require "system_helper"

RSpec.describe "Client and case details section - benefit checker fallback", :vcr do
  before do
    login_as_a_provider
    allow(Setting).to receive_messages(collect_dwp_data?: collect_dwp_data)
    allow(Setting).to receive_messages(collect_hmrc_data?: collect_hmrc_data)
    create_an_application_and_complete_client_details(with_partner)
    visit providers_legal_aid_application_check_provider_answers_path(@legal_aid_application)
  end

  let(:with_partner) { false }
  let(:collect_hmrc_data) { true }

  context "when the collect_dwp_data setting is off" do
    let(:collect_dwp_data) { false }

    scenario "I am routed from Check your Answers to the benefit confirmation page via an interrupt page" do
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "There was a problem connecting to DWP")

      click_on "Save and continue"
      expect(page)
        .to have_css("h1", text: "Does your client get a passporting benefit?")
        .and have_content("If your client does not receive a passporting benefit, we'll check their details with HM Revenue and Customs (HMRC). You can review these details later.")

      govuk_choose("Yes")
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Which passporting benefit does your client get?")
    end

    scenario "when the client does not receive a passported benefit I am routed from Check your Answers to the start of the means flow via an interrupt page" do
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "There was a problem connecting to DWP")

      click_on "Save and continue"
      expect(page)
        .to have_css("h1", text: "Does your client get a passporting benefit?")
        .and have_content("If your client does not receive a passporting benefit, we'll check their details with HM Revenue and Customs (HMRC). You can review these details later.")

      click_on "Save and continue"
      expect_govuk_error_summary(text: "Select yes if your client gets a passporting benefit")

      govuk_choose("No")
      click_on "Save and continue"
      expect(page.current_url).to include providers_legal_aid_application_about_financial_means_path(@legal_aid_application)
      expect(page).to have_css("h1", text: "What you need to do")
    end

    context "when the client has a partner" do
      let(:with_partner) { true }

      scenario "when the client receives a joint passporting benefit with their partner" do
        click_on "Save and continue"
        expect(page).to have_css("h1", text: "There was a problem connecting to DWP")

        click_on "Save and continue"
        expect(page)
            .to have_css("h1", text: "Does your client get a passporting benefit?")
            .and have_css(".govuk-label", text: "Yes")
            .and have_css(".govuk-label", text: "Yes, they get a passporting benefit with a partner")
            .and have_css(".govuk-label", text: "No")

        click_on "Save and continue"
        expect_govuk_error_summary(text: "Select if your client gets a passporting benefit")

        govuk_choose("Yes, they get a passporting benefit with a partner")
        click_on "Save and continue"
        expect(page).to have_css("h1", text: "Which joint passporting benefit does your client and their partner get?")
      end
    end
  end

  context "when the collect_dwp_data setting is on" do
    let(:collect_dwp_data) { true }

    context "and the call to benefit checker does not return a 200" do
      before { allow(BenefitCheckService).to receive(:call).and_return(false) }

      context "without a partner" do
        scenario "I am routed from Check your answers to an interrupt page and then to the benefit confirmation page" do
          click_on "Save and continue"
          expect(page).to have_css("h1", text: "There was a problem connecting to DWP")
          expect(page).to have_css("p.govuk-body", text: "Your client's benefit status cannot be checked at this time. You will need to tell us about any passporting benefits.")

          click_on "Save and continue"
          expect(page)
            .to have_css("h1", text: "Does your client get a passporting benefit?")
            .and have_css(".govuk-label", text: "Yes")
            .and have_css(".govuk-label", text: "No")

          click_on "Save and continue"
          expect_govuk_error_summary(text: "Select yes if your client gets a passporting benefit")

          govuk_choose("Yes")
          click_on "Save and continue"
          expect(page).to have_css("h1", text: "Which passporting benefit does your client get?")
        end
      end

      context "with a partner" do
        let(:with_partner) { true  }

        scenario "I am routed from Check your answers to an interrupt page and then to the benefit confirmation page" do
          click_on "Save and continue"
          expect(page)
            .to have_css("h1", text: "There was a problem connecting to DWP")
            .and have_css("p.govuk-body", text: "Your client's benefit status cannot be checked at this time. You will need to tell us about any passporting benefits.")

          click_on "Save and continue"
          expect(page)
            .to have_css("h1", text: "Does your client get a passporting benefit?")
            .and have_css(".govuk-label", text: "Yes")
            .and have_css(".govuk-label", text: "Yes, they get a passporting benefit with a partner")
            .and have_css(".govuk-label", text: "No")

          click_on "Save and continue"
          expect_govuk_error_summary(text: "Select if your client gets a passporting benefit")

          govuk_choose("Yes, they get a passporting benefit with a partner")
          click_on "Save and continue"
          expect(page).to have_css("h1", text: "Which joint passporting benefit does your client and their partner get?")
        end
      end
    end

    context "and the call to benefit checker returns 200" do
      before { allow(BenefitCheckService).to receive(:call).with(@legal_aid_application).and_return(benefit_check_response) }

      let(:benefit_check_response) do
        {
          benefit_checker_status: "Yes",
          confirmation_ref: SecureRandom.hex,
        }
      end

      scenario "I am routed from Check your answers to the DWP results page" do
        click_on "Save and continue"
        expect(page).to have_css("h1", text: "DWP records show that your client receives a passporting benefit")

        click_on "Save and continue"
        expect(page).to have_css("h1", text: "What you need to do") # on capital_introductions page
      end
    end
  end

  context "when the collect_hmrc_data is off" do
    let(:collect_dwp_data) { true }
    let(:collect_hmrc_data) { false }

    before { allow(BenefitCheckService).to receive(:call).and_return(false) }

    scenario "the page does NOT display the HMRC warning" do
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "There was a problem connecting to DWP")

      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Does your client get a passporting benefit?")

      expect(page).to have_no_content("HMRC")
    end
  end
end
