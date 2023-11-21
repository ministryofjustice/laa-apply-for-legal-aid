require "rails_helper"

RSpec.describe Providers::ReceivedBenefitConfirmationsController do
  let(:application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe "GET /providers/applications/:legal_aid_application_id/received_benefit_confirmation" do
    subject(:get_request) { get "/providers/applications/#{application_id}/received_benefit_confirmation" }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as application.provider
        get_request
      end

      it "returns success" do
        expect(response).to be_successful
      end

      it "displays the correct page" do
        expect(unescaped_response_body).to include(I18n.t("providers.received_benefit_confirmations.show.h1_no_partner"))
      end
    end

    context "when the provider has previously selected that the client gets a joint benefit with their partner" do
      let(:application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_partner_and_joint_benefit) }
      let(:application_id) { application.id }

      before do
        login_as application.provider
        allow(Setting).to receive(:partner_means_assessment?).and_return true
        get_request
      end

      it "displays the correct page" do
        expect(unescaped_response_body).to include(I18n.t("providers.received_benefit_confirmations.show.h1_partner"))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/received_benefit_confirmation" do
    subject(:patch_request) { patch "/providers/applications/#{application_id}/received_benefit_confirmation", params: }

    let(:params) { { dwp_override: { passporting_benefit: nil } } }

    before do
      login_as application.provider
    end

    context "when there is a validation error" do
      it "displays error if nothing selected" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Select if your client has received any of these benefits")
      end
    end

    context "when benefit selected" do
      let(:params) { { dwp_override: { passporting_benefit: :universal_credit } } }

      context "and provider adds a new record" do
        it "adds a dwp override record" do
          expect { patch_request }.to change(DWPOverride, :count).by(1)
        end

        it "updates the same dwp override record" do
          patch_request
          expect { patch_request }.not_to change(DWPOverride, :count)
        end
      end

      context "when changed to none selected" do
        before do
          params = { dwp_override: { passporting_benefit: :universal_credit } }
          patch "/providers/applications/#{application_id}/received_benefit_confirmation", params:
        end

        let(:params) { { dwp_override: { passporting_benefit: :none_selected } } }

        it "removes the record" do
          expect { patch_request }.to change(DWPOverride, :count).by(-1)
        end
      end
    end

    context "when none of these selected" do
      let(:params) { { dwp_override: { passporting_benefit: :none_selected } } }

      it "does not add a dwp override record" do
        expect { patch_request }.not_to change(DWPOverride, :count)
      end

      it "transitions the application state to applicant details checked" do
        patch_request
        expect(application.reload.state).to eq "applicant_details_checked"
      end
    end
  end
end
