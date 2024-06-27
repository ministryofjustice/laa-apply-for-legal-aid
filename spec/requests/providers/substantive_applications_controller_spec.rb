require "rails_helper"
RSpec.describe Providers::SubstantiveApplicationsController, vcr: { cassette_name: "gov_uk_bank_holiday_api" } do
  let(:state) { :with_passported_state_machine }
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :at_applicant_details_checked,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           :with_substantive_application_deadline_on,
           explicit_proceedings: [:da004],
           df_options: { DA004: [Time.zone.today, Time.zone.today] },
           applicant:)
  end

  let(:applicant) { create(:applicant, :not_employed) }
  let(:login_provider) { login_as legal_aid_application.provider }

  before do
    login_provider
  end

  describe "GET /providers/applications/:legal_aid_application_id/substantive_application" do
    before { get providers_legal_aid_application_substantive_application_path(legal_aid_application) }

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the date correctly" do
      target_date = SubstantiveApplicationDeadlineCalculator.call(legal_aid_application.earliest_delegated_functions_date)
      expect(response.body).to include("You must submit a substantive application by #{target_date.strftime('%e %B %Y')}")
    end

    context "when not authenticated" do
      let(:login_provider) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/substantive_application" do
    subject(:patch_request) do
      patch(
        providers_legal_aid_application_substantive_application_path(legal_aid_application),
        params: params.merge(button_clicked),
      )
    end

    let(:state) { :with_non_passported_state_machine }
    let(:substantive_application) { true }
    let(:params) do
      {
        legal_aid_application: {
          substantive_application: substantive_application.to_s,
        },
      }
    end
    let(:button_clicked) { {} }

    it "updates the application" do
      patch_request
      legal_aid_application.reload
      expect(legal_aid_application.substantive_application).to eq(substantive_application)
      expect(legal_aid_application.state).to eq("delegated_functions_used")
    end

    context "when yes is selected" do
      let(:substantive_application) { true }

      context "with positive benefit check" do
        let(:legal_aid_application) do
          create(
            :legal_aid_application,
            :with_positive_benefit_check_result,
            :with_passported_state_machine,
            :applicant_details_checked,
          )
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "with a negative benefit check" do
        let(:legal_aid_application) do
          create(
            :legal_aid_application,
            :with_negative_benefit_check_result,
            :with_non_passported_state_machine,
            :applicant_details_checked,
          )
        end

        context "and a dwp_override with evidence" do
          it "redirects to the next page" do
            create(:dwp_override, :with_evidence, legal_aid_application:)
            patch_request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "and a dwp_override without evidence" do
          it "redirects to the next page" do
            create(:dwp_override, :with_no_evidence, legal_aid_application:)
            patch_request
            expect(response).to have_http_status(:redirect)
          end
        end
      end
    end

    context "when no is selected" do
      before { patch_request }

      let(:substantive_application) { false }

      it "updates the application" do
        legal_aid_application.reload
        expect(legal_aid_application.substantive_application).to eq(substantive_application)
        expect(legal_aid_application.state).to eq("delegated_functions_used")
      end

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when not authenticated" do
      before { patch_request }

      let(:login_provider) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "with nothing selected" do
      before { patch_request }

      let(:substantive_application) { "" }

      it "renders show" do
        expect(response).to have_http_status(:ok)
      end

      it "displays error" do
        expect(response.body).to include("govuk-error-summary")
        expect(response.body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.substantive_application.blank"))
      end
    end
  end
end
