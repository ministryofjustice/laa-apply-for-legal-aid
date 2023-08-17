require "rails_helper"

RSpec.describe Providers::Means::VehiclesController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/means/vehicle" do
    subject { get providers_legal_aid_application_means_vehicle_path(legal_aid_application) }

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:ok)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { subject }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/vehicle" do
    subject do
      patch(
        providers_legal_aid_application_means_vehicle_path(legal_aid_application),
        params:,
      )
    end

    let(:own_vehicle) { nil }
    let(:params) do
      { legal_aid_application: { own_vehicle: } }
    end

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "displays error" do
      subject
      expect(response.body).to include("govuk-error-summary")
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context 'with option "true"' do
      let(:own_vehicle) { "true" }
      let(:target_url) do
        providers_legal_aid_application_means_vehicle_details_path(legal_aid_application)
      end

      it "creates a vehicle" do
        expect { subject }.to change(Vehicle, :count).by(1)
        expect(legal_aid_application.reload.vehicle).to be_present
      end

      it "sets own_vehicle to true" do
        expect { subject }.to change { legal_aid_application.reload.own_vehicle }.to(true)
      end

      it "redirects to vehicle details" do
        subject
        expect(response).to redirect_to(target_url)
      end

      context "and exiting vehicle" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_vehicle) }

        it "does not create a vehicle" do
          expect { subject }.not_to change(Vehicle, :count)
        end

        it "redirects to estimated value" do
          subject
          expect(response).to redirect_to(target_url)
        end
      end

      context "when checking answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_passported_state_machine, :checking_passported_answers) }

        it "redirects to next page" do
          subject
          expect(response).to redirect_to(target_url)
        end
      end
    end

    context 'when submitted with option "false"' do
      let(:own_vehicle) { "false" }
      let(:target_url) do
        providers_legal_aid_application_applicant_bank_account_path(legal_aid_application)
      end

      it "does not create a vehicle" do
        expect { subject }.not_to change(Vehicle, :count)
      end

      it "sets own_vehicle to false" do
        expect { subject }.to change { legal_aid_application.reload.own_vehicle }.to(false)
      end

      it "redirects to applicant bank account for non-passported journey" do
        subject
        expect(response).to redirect_to(target_url)
      end

      context "and existing vehicle" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_vehicle, :passported) }

        it "delete existing vehicle" do
          expect { subject }.to change(Vehicle, :count).by(-1)
        end

        it "redirects to offline account page on passported journey" do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_offline_account_path(legal_aid_application))
        end
      end

      context "when checking answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :checking_non_passported_means) }

        it "redirects to check capital answers page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_check_capital_answers_path(legal_aid_application))
        end
      end

      context "when checking passported answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_passported_state_machine, :checking_passported_answers) }

        it "redirects to passported check answers page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(legal_aid_application))
        end
      end
    end
  end
end
