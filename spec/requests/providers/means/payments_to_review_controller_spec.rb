require "rails_helper"

RSpec.describe Providers::Means::PaymentsToReviewController do
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:provider) { application.provider }

  describe "GET providers/applications/:id/means/payments_to_review" do
    subject(:get_request) { get providers_legal_aid_application_means_payments_to_review_path(application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the show page" do
        expect(response.body).to include("Payments to be reviewed")
      end
    end
  end

  describe "PATCH providers/applications/:id/means/payments_to_review" do
    let(:params) do
      {
        discretionary_disregards: {
          backdated_benefits: true,
          compensation_for_personal_harm: "",
          criminal_injuries_compensation: "",
          grenfell_tower_fire_victims: "",
          london_emergencies_trust: "",
          national_emergencies_trust: "",
          loss_or_harm_relating_to_this_application: "",
          victims_of_overseas_terrorism_compensation: "",
          we_love_manchester_emergency_fund: "",
          none_selected: "",
        },
      }
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when submitted with Continue button" do
        let(:submit_button) do
          { continue_button: "Continue" }
        end

        before do
          patch providers_legal_aid_application_means_payments_to_review_path(application), params: params.merge(submit_button)
        end

        context "with valid params" do
          it "updates the record" do
            discretionary_disregards = application.discretionary_disregards
            expect(discretionary_disregards.backdated_benefits).to be true
            expect(discretionary_disregards.compensation_for_personal_harm).to be_nil
            expect(discretionary_disregards.criminal_injuries_compensation).to be_nil
            expect(discretionary_disregards.grenfell_tower_fire_victims).to be_nil
            expect(discretionary_disregards.london_emergencies_trust).to be_nil
            expect(discretionary_disregards.national_emergencies_trust).to be_nil
            expect(discretionary_disregards.loss_or_harm_relating_to_this_application).to be_nil
            expect(discretionary_disregards.victims_of_overseas_terrorism_compensation).to be_nil
            expect(discretionary_disregards.we_love_manchester_emergency_fund).to be_nil
          end
        end

        context "with provider checking their answers" do
          let(:application) { create(:legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_passported_answers) }

          it "redirects to the next page" do
            expect(response).to have_http_status(:redirect)
          end
        end

        context "with provider checking answers" do
          let(:application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means) }

          it "redirects to the next page" do
            expect(response).to have_http_status(:redirect)
          end
        end
      end

      context "with nothing" do
        let(:none_selected) { "true" }
        let(:empty_params) do
          {
            discretionary_disregards: {
              backdated_benefits: "",
              compensation_for_personal_harm: "",
              criminal_injuries_compensation: "",
              grenfell_tower_fire_victims: "",
              london_emergencies_trust: "",
              national_emergencies_trust: "",
              loss_or_harm_relating_to_this_application: "",
              victims_of_overseas_terrorism_compensation: "",
              we_love_manchester_emergency_fund: "",
              none_selected:,
            },
          }
        end
        let(:submit_button) { { continue_button: "Continue" } }

        before do
          patch providers_legal_aid_application_means_payments_to_review_path(application), params: empty_params.merge(submit_button)
        end

        context "with 'none of these' checkbox selected" do
          it "redirects to the next page" do
            expect(response).to have_http_status(:redirect)
          end

          it "updates the record" do
            discretionary_disregards = application.discretionary_disregards
            expect(discretionary_disregards.backdated_benefits).to be_nil
            expect(discretionary_disregards.compensation_for_personal_harm).to be_nil
            expect(discretionary_disregards.criminal_injuries_compensation).to be_nil
            expect(discretionary_disregards.grenfell_tower_fire_victims).to be_nil
            expect(discretionary_disregards.london_emergencies_trust).to be_nil
            expect(discretionary_disregards.national_emergencies_trust).to be_nil
            expect(discretionary_disregards.loss_or_harm_relating_to_this_application).to be_nil
            expect(discretionary_disregards.victims_of_overseas_terrorism_compensation).to be_nil
            expect(discretionary_disregards.we_love_manchester_emergency_fund).to be_nil
          end
        end

        context "with 'none of these' checkbox not selected" do
          let(:none_selected) { "" }

          it "the response includes the error message" do
            expect(response.body).to include(I18n.t("activemodel.errors.models.discretionary_disregards.attributes.base.none_selected"))
          end
        end
      end

      context "with 'none of these' checkbox and another checkbox selected" do
        let(:params) do
          {
            discretionary_disregards: {
              london_emergencies_trust: "true",
              none_selected: "true",
            },
          }
        end

        before do
          patch providers_legal_aid_application_means_payments_to_review_path(application), params:
        end

        it "the response includes the error message" do
          expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.discretionary_disregards.attributes.base.none_and_another_option_selected"))
        end
      end
    end
  end
end
