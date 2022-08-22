require "rails_helper"
require Rails.root.join("spec/factory_helpers/cfe_employment_remarks_adder")

RSpec.describe Providers::MeansReportsController, type: :request do
  include ActionView::Helpers::NumberHelper
  include Capybara::RSpecMatchers

  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_everything,
           :with_cfe_v4_result,
           :assessment_submitted,
           explicit_proceedings: %i[da002 da006])
  end

  let(:login_provider) { login_as legal_aid_application.provider }
  let!(:submission) { create :submission, legal_aid_application: }
  let(:cfe_result) { legal_aid_application.cfe_result }
  let(:before_subject) { nil }

  describe "GET /providers/applications/:legal_aid_application_id/means_report" do
    subject do
      # dont' match on path - webpacker keeps changing the second part of the path
      VCR.use_cassette("stylesheets", match_requests_on: %i[method host headers]) do
        get providers_legal_aid_application_means_report_path(legal_aid_application, debug: true)
      end
    end

    before do
      login_provider
      before_subject
      subject
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "displays application reference" do
      expect(response.body).to have_content("Apply service case reference:")
        .and have_content(legal_aid_application.application_ref)
    end

    it "displays the CCMS case reference" do
      expect(unescaped_response_body).to include(submission.case_ccms_reference)
    end

    it "includes non passported truelayer applicable sections" do
      expect(response.body).to have_selector("h2", text: "Client details")
      .and have_selector("h2", text: "Proceeding eligibility")
        .and have_selector("h2", text: "Passported means")
        .and have_selector("h2", text: "Income result")
        .and have_selector("h2", text: "Income")
        .and have_selector("h2", text: "Outgoings")
        .and have_selector("h2", text: "Deductions")
        .and have_selector("h2", text: "Capital result")
        .and have_selector("h2", text: "Caseworker Review")
        .and have_selector("h2", text: "Property, savings and other assets")
        .and have_selector("h2", text: "Which bank accounts does your client have?")
        .and have_selector("h2", text: "Which savings or investments does your client have?")
        .and have_selector("h2", text: "Which assets does your client have?")
        .and have_selector("h2", text: "Restrictions on your client's assets")
        .and have_selector("h2", text: "Payments from scheme or charities")
    end

    it "excludes bank statement upload applicable sections" do
      expect(response.body).not_to have_selector("h2", text: "Declared income categories")
      expect(response.body).not_to have_selector("h2", text: "Student finance")
      expect(response.body).not_to have_selector("h2", text: "Declared cash income")
      expect(response.body).not_to have_selector("h2", text: "Dependants")
      expect(response.body).not_to have_selector("h2", text: "Declared outgoings categories")
      expect(response.body).not_to have_selector("h2", text: "Declared cash outgoings")
      expect(response.body).not_to have_selector("h3", text: "Bank statements")
    end

    it "displays all sources for Benefits" do
      expect(unescaped_response_body).to include("Benefits")
      expect(unescaped_response_body).to include("£75")
    end

    it "displays all sources for Housing Payments" do
      expect(unescaped_response_body).to include("Housing payments")
      expect(unescaped_response_body).to include("£125")
    end

    it "displays student loan" do
      expect(unescaped_response_body).to include("Student loan or grant")
      expect(unescaped_response_body).to include("£0")
    end

    it "displays the total capital assessed" do
      expect(unescaped_response_body).to include(gds_number_to_currency(cfe_result.total_capital))
    end

    it "displays the capital lower limit" do
      expect(unescaped_response_body).to include("£3,000")
    end

    it "displays the capital upper limit" do
      expect(unescaped_response_body).to include("£8,000")
    end

    it "displays the capital contribution" do
      expect(unescaped_response_body).to include(gds_number_to_currency(cfe_result.capital_contribution))
    end

    context "when employed feature flag is set to false" do
      let(:before_subject) { Setting.setting.update!(enable_employed_journey: false) }

      it "does not display employment details" do
        expect(response.body).not_to have_selector("h3", text: "Employment notes")
        expect(response.body).not_to have_selector("h3", text: "Employment income")
        expect(unescaped_response_body).to exclude("Gross employment income")
        expect(unescaped_response_body).to exclude("Income tax")
        expect(unescaped_response_body).to exclude("National insurance")
        expect(unescaped_response_body).to exclude("Fixed employment deduction")
        expect(unescaped_response_body).to exclude("Employment notes")
      end
    end

    context "when employed feature flag is set to true" do
      before(:all) { Setting.setting.update!(enable_employed_journey: true) }

      context "when the applicant is employed and HMRC returns employment data" do
        let(:before_subject) do
          legal_aid_application.applicant.update!(employed: true)
          legal_aid_application.update!(extra_employment_information: true,
                                        extra_employment_information_details: "Made redundant")
        end

        it "displays the employment details" do
          expect(response.body)
            .to have_selector("h3", text: "Employment income")
            .and have_content("Gross employment income")
            .and have_content("Income tax")
            .and have_content("National insurance")
            .and have_content("Fixed employment deduction")
        end
      end

      context "when the applicant is employed but HMRC does not return employment data" do
        let(:before_subject) do
          legal_aid_application.applicant.update!(employed: true)
          legal_aid_application.update!(full_employment_details: "Test employment details")
        end

        it "displays the manually entered employment details" do
          expect(response.body)
          .to have_selector("h3", text: "Employment income")
          .and have_content("Your client's employment details")
          .and have_content("Test employment details")
        end
      end

      context "when the applicant is not employed" do
        let(:before_subject) { legal_aid_application.applicant.update!(employed: false) }

        it "does not display the employment lines" do
          expect(response.body)
            .to exclude("Gross employment income")
            .and exclude("Income tax")
            .and exclude("National insurance")
            .and exclude("Fixed employment deduction")
            .and exclude("Employment notes")
        end
      end

      context "with employment remarks" do
        let(:before_subject) { FactoryHelpers::CFEEmploymentRemarksAdder.call(cfe_result) }

        it "displays all expected employment-related remarks" do
          expect(parsed_response_body.css("#caseworker_review_required_answer").text.strip).to eq "Yes"
          reasons = parsed_response_body.css("#caseworker_review_reasons").text.split("\n").map(&:strip)
          reasons.compact_blank!
          expect(reasons).to eq ["Monthly value unknown (variations)",
                                 "Multiple employments",
                                 "Tax or NI refunds",
                                 "Frequency unknown",
                                 "Restrictions on client's assets"]
          expect(parsed_response_body.css("#means-merits-report__caseworker-review-required-multiple_employments > dt").text.strip).to eq "Review categories - Multiple employments"

          amount_variation_categories = parsed_response_body.css("#review-reason-amount_variation").text.split("\n").map(&:strip)
          amount_variation_categories.compact_blank!
          expect(amount_variation_categories).to eq ["Employment gross income", "Employment National Insurance contributions", "Employment income tax"]

          unknown_frequency_categories = parsed_response_body.css("#review-reason-unknown_frequency").text.split("\n").map(&:strip)
          unknown_frequency_categories.compact_blank!
          expect(unknown_frequency_categories).to eq ["Employment gross income"]

          refunds_categories = parsed_response_body.css("#review-reason-refunds").text.split("\n").map(&:strip)
          refunds_categories.compact_blank!
          expect(refunds_categories).to eq ["Employment National Insurance contributions", "Employment income tax"]
        end
      end
    end

    context "when not authenticated" do
      let(:login_provider) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "with bank statement upload journey application" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_proceedings,
               :with_everything,
               :with_cfe_empty_result,
               :with_extra_employment_information,
               :with_full_employment_information,
               :assessment_submitted,
               provider:,
               provider_received_citizen_consent: false,
               attachments: [build(:attachment, :bank_statement)],
               explicit_proceedings: %i[da002 da006])
      end

      # TODO: move this to a factory and/or find a way to append pemissions nicely
      let(:provider) do
        create(:provider, :with_bank_statement_upload_permissions).tap do |provider|
          non_passported = Permission.find_by(role: "application.non_passported.*")
          non_passported = create(:permission, :non_passported) if non_passported.nil?
          provider.permissions << non_passported
        end
      end

      it "displays application_ref" do
        expect(response.body).to have_content("Apply service case reference:")
          .and have_content(legal_aid_application.application_ref)
      end

      it "includes non passported bank statement upload applicable sections" do
        expect(response.body)
          .to have_selector("h2", text: "Client details")
          .and have_selector("h2", text: "Passported means")
          .and have_selector("h2", text: "Declared income categories")
          .and have_selector("h2", text: "Student finance")
          .and have_selector("h2", text: "Declared cash income")
          .and have_selector("h2", text: "Dependants")
          .and have_selector("h2", text: "Declared outgoings categories")
          .and have_selector("h2", text: "Declared cash outgoings")
          .and have_selector("h2", text: "Employed income result")
          .and have_selector("h3", text: "Employment income")
          .and have_selector("h2", text: "Caseworker Review")
          .and have_selector("h2", text: "Property, savings and other assets")
          .and have_selector("h2", text: "Which savings or investments does your client have?")
          .and have_selector("h2", text: "Which assets does your client have?")
          .and have_selector("h2", text: "Restrictions on your client's assets")
          .and have_selector("h2", text: "Payments from scheme or charities")
          .and have_selector("h3", text: "Bank statements")
      end

      # TODO: some kind of compound expectation would be good here (but `.and` does not work with negated matchers)
      it "excludes passported and truelayer applicable sections" do
        expect(response.body).not_to have_selector("h2", text: "Proceeding eligibility")
        expect(response.body).not_to have_selector("h2", text: "Outgoings")
        expect(response.body).not_to have_selector("h2", text: "Deductions")
        expect(response.body).not_to have_selector("h2", text: "Capital result")
      end
    end
  end
end
