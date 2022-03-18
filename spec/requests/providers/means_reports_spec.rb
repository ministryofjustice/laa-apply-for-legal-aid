require "rails_helper"
require Rails.root.join("spec/factory_helpers/cfe_employment_remarks_adder")

RSpec.describe Providers::MeansReportsController, type: :request do
  include ActionView::Helpers::NumberHelper

  let(:legal_aid_application) do
    create :legal_aid_application, :with_proceedings, :with_everything, :with_cfe_v4_result, :assessment_submitted, explicit_proceedings: %i[da002 da006]
  end
  let(:login_provider) { login_as legal_aid_application.provider }
  let!(:submission) { create :submission, legal_aid_application: legal_aid_application }
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

    it "displays the application ref number" do
      expect(unescaped_response_body).to include(legal_aid_application.application_ref)
    end

    it "displays the CCMS case reference" do
      expect(unescaped_response_body).to include(submission.case_ccms_reference)
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

      it "does not display employment lines" do
        expect(unescaped_response_body).not_to include("Gross employment income")
        expect(unescaped_response_body).not_to include("Income tax")
        expect(unescaped_response_body).not_to include("National insurance")
        expect(unescaped_response_body).not_to include("Fixed employment deduction")
        expect(unescaped_response_body).not_to include("Employment notes")
      end
    end

    context "when employed feature flag is set to true" do
      before(:all) { Setting.setting.update!(enable_employed_journey: true) }

      context "when the applicant is employed and HMRC returns employment data" do
        let(:before_subject) do
          legal_aid_application.applicant.update!(employed: true)
          legal_aid_application.update!(extra_employment_information: true, extra_employment_information_details: "Made redundant")
        end

        it "displays the employment lines" do
          expect(unescaped_response_body).to include("Gross employment income")
          expect(unescaped_response_body).to include("Income tax")
          expect(unescaped_response_body).to include("National insurance")
          expect(unescaped_response_body).to include("Fixed employment deduction")
          expect(unescaped_response_body).to include("Employment notes")
        end
      end

      context "when the applicant is employed but HMRC does not return employment data" do
        let(:before_subject) do
          legal_aid_application.applicant.update!(employed: true)
          legal_aid_application.update!(full_employment_details: "Test employment details")
        end

        it "displays the manually entered employment details" do
          expect(unescaped_response_body).to include("Your client's employment details")
          expect(unescaped_response_body).to include("Test employment details")
        end
      end

      context "when the applicant is not employed" do
        let(:before_subject) { legal_aid_application.applicant.update!(employed: false) }

        it "does not display the employment lines" do
          expect(unescaped_response_body).to_not include("Gross employment income")
          expect(unescaped_response_body).to_not include("Income tax")
          expect(unescaped_response_body).to_not include("National insurance")
          expect(unescaped_response_body).to_not include("Fixed employment deduction")
          expect(unescaped_response_body).to_not include("Employment notes")
        end
      end

      context "with employment remarks" do
        let(:before_subject) { FactoryHelpers::CFEEmploymentRemarksAdder.call(cfe_result) }

        it "displays all expected employment-related remarks" do
          expect(parsed_response_body.css("#caseworker_review_required_answer").text.strip).to eq "Yes"
          reasons = parsed_response_body.css("#caseworker_review_reasons").text.split("\n").map(&:strip)
          reasons.delete_if(&:blank?)
          expect(reasons).to eq ["Monthly value unknown (variations)",
                                 "Multiple employments",
                                 "Tax or NI refunds",
                                 "Frequency unknown"]
          expect(parsed_response_body.css("#means-merits-report__caseworker-review-required-multiple_employments > dt").text.strip).to eq "Review categories - Multiple employments"

          amount_variation_categories = parsed_response_body.css("#review-reason-amount_variation").text.split("\n").map(&:strip)
          amount_variation_categories.delete_if(&:blank?)
          expect(amount_variation_categories).to eq ["Employment gross income", "Employment National Insurance contributions", "Employment income tax"]

          unknown_frequency_categories = parsed_response_body.css("#review-reason-unknown_frequency").text.split("\n").map(&:strip)
          unknown_frequency_categories.delete_if(&:blank?)
          expect(unknown_frequency_categories).to eq ["Employment gross income"]

          refunds_categories = parsed_response_body.css("#review-reason-refunds").text.split("\n").map(&:strip)
          refunds_categories.delete_if(&:blank?)
          expect(refunds_categories).to eq ["Employment National Insurance contributions", "Employment income tax"]
        end
      end
    end

    context "when not authenticated" do
      let(:login_provider) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end
end
