require "rails_helper"

RSpec.describe Providers::SubmittedApplicationsController do
  include ActionView::Helpers::NumberHelper
  let(:firm) { create(:firm) }
  let!(:provider) { create(:provider, firm:) }
  let!(:legal_aid_application) do
    create(:legal_aid_application,
           :with_everything,
           :with_proceedings,
           :assessment_submitted,
           :with_cfe_v5_result,
           explicit_proceedings: %i[da001],
           set_lead_proceeding: :da001,
           provider:)
  end
  let(:proceeding) { legal_aid_application.proceedings.detect { |p| p.ccms_code == "DA001" } }
  let!(:chances_of_success) do
    create(:chances_of_success,
           proceeding:)
  end

  let(:login) { login_as legal_aid_application.provider }
  let(:html) { Nokogiri::HTML(response.body) }
  let(:print_buttons) { html.xpath('//button[contains(text(), "Print application")]') }
  let(:smtl) { create(:legal_framework_merits_task_list, :da001, legal_aid_application:) }

  before { allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl) }

  describe "GET /providers/applications/:legal_aid_application_id/submitted_application" do
    subject do
      get providers_legal_aid_application_submitted_application_path(legal_aid_application)
    end

    before do
      legal_aid_application.reload
      login
      subject
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "displays reference" do
      expect(response.body).to include(legal_aid_application.application_ref)
    end

    it "shows client declaration only when printing the page" do
      expect(html.at_css("#client-declaration").classes).to include("app-print-only")
    end

    it "hides print buttons when printing the page" do
      print_buttons.each do |print_button|
        expect(print_button.ancestors.at_css(".no-print")).not_to be_nil
      end
    end

    it "includes the name of the firm" do
      subject
      expect(unescaped_response_body).to include(firm.name)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "with another provider" do
      let(:login) { login_as create(:provider) }

      it "redirects to access denied error" do
        expect(response).to redirect_to(error_path(:access_denied))
      end
    end
  end

  describe "employment income table" do
    subject do
      login
      get providers_legal_aid_application_submitted_application_path(legal_aid_application)
    end

    let(:firm) { create(:firm) }
    let!(:provider) { create(:provider, firm:) }
    let!(:legal_aid_application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :assessment_submitted,
             set_lead_proceeding: :da001,
             provider:)
    end
    let(:login) { login_as legal_aid_application.provider }
    let!(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
    let!(:cfe_result) { create(:cfe_v5_result, :with_employments, submission: cfe_submission) }
    let(:translation_path) { "shared.employment_income_table" }

    shared_examples "employment data is not present" do
      before { subject }

      it "does not display the employment income table" do
        expect(unescaped_response_body).not_to include I18n.t("#{translation_path}.benefits_in_kind")
        expect(unescaped_response_body).not_to include I18n.t("#{translation_path}.monthly_income_before_tax")
        expect(unescaped_response_body).not_to include I18n.t("#{translation_path}.national_insurance")
        expect(unescaped_response_body).not_to include I18n.t("#{translation_path}.tax")
      end

      it "does not display the Other income header" do
        expect(unescaped_response_body).not_to include I18n.t("providers.submitted_applications.show.other_income")
      end
    end

    context "when employment data is present" do
      it "displays the employment income table" do
        subject
        expect(unescaped_response_body).to include I18n.t("#{translation_path}.heading")
        expect(unescaped_response_body).to include I18n.t("#{translation_path}.benefits_in_kind")
        expect(unescaped_response_body).to include I18n.t("#{translation_path}.monthly_income_before_tax")
        expect(unescaped_response_body).to include I18n.t("#{translation_path}.national_insurance")
        expect(unescaped_response_body).to include I18n.t("#{translation_path}.tax")
      end

      it "populates the employment income table with the correct data" do
        subject
        expect(unescaped_response_body).to include gds_number_to_currency(cfe_result.employment_income_benefits_in_kind)
        expect(unescaped_response_body).to include gds_number_to_currency(cfe_result.employment_income_gross_income)
        expect(unescaped_response_body).to include gds_number_to_currency(cfe_result.employment_income_national_insurance)
        expect(unescaped_response_body).to include gds_number_to_currency(cfe_result.employment_income_tax)
      end

      it "displays the Other income header" do
        subject
        expect(unescaped_response_body).to include I18n.t("shared.review_application.income_payments_and_assets.other_income")
      end

      it "does not display the extra employment information details" do
        subject
        expect(unescaped_response_body).not_to include I18n.t("#{translation_path}.employment_details")
      end

      context "when employment details have been entered by the solicitor" do
        before do
          legal_aid_application.update!(extra_employment_information: true, extra_employment_information_details: "test details")
          subject
        end

        it "displays the extra employment information details" do
          expect(unescaped_response_body).to include I18n.t("#{translation_path}.employment_details")
          expect(unescaped_response_body).to include "test details"
        end
      end
    end

    context "when employment data is not present" do
      let(:cfe_result) { create(:cfe_v4_result, :with_no_employments, submission: cfe_submission) }

      it_behaves_like "employment data is not present"
    end

    context "when application has an older CFE Result version object" do
      let(:cfe_result) { create(:cfe_v3_result, submission: cfe_submission) }

      it_behaves_like "employment data is not present"
    end
  end
end
