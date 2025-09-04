require "rails_helper"

RSpec.describe Providers::DWP::FallbackController do
  let(:application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_address) }
  let(:enable_hmrc_collection) { true }

  before { allow(Setting).to receive(:collect_hmrc_data?).and_return(enable_hmrc_collection) }

  describe "GET /providers/applications/:legal_aid_application_id/dwp/advise-of-passport-benefit" do
    subject(:get_request) { get providers_legal_aid_application_dwp_fallback_path(application) }

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
    end

    describe "HMRC inset text" do
      before { login_as application.provider }

      it "displays the HMRC inset text" do
        get_request
        expect(unescaped_response_body).to include(I18n.t(".providers.confirm_dwp_non_passported_applications.show.hmrc_text"))
      end
    end

    context "when the application has a partner" do
      let(:application) { create(:legal_aid_application, :with_applicant_and_partner, :with_proceedings, :at_checking_applicant_details) }

      before do
        login_as application.provider
      end

      it "displays the joint passporting benefit option" do
        get_request
        expect(unescaped_response_body).to include("Yes, they get a passporting benefit with a partner")
      end
    end

    context "when the application does not have a partner" do
      it "does not display the joint passporting benefit option" do
        get_request
        expect(unescaped_response_body).not_to include("Yes, they get a passporting benefit with a partner")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/dwp/advise-of-passport-benefit" do
    context "when submitting with the Continue button" do
      subject(:patch_request) { patch providers_legal_aid_application_dwp_fallback_path(application), params: }

      let(:params) do
        {
          continue_button: "Continue",
        }
      end

      before do
        login_as application.provider
        allow(HMRC::CreateResponsesService).to receive(:call).with(application).and_return(instance_double(HMRC::CreateResponsesService, call: %w[one two]))
      end

      context "and the results are correct" do
        let(:params) do
          {
            continue_button: "Continue",
            partner: {
              confirm_dwp_result: "no_benefit_received",
            },
          }
        end

        context "when the status is already applicant_details_checked" do
          before { application.applicant_details_checked! }

          it { expect { patch_request }.not_to change { application.reload.state } }
        end

        context "when the state is not already applicant_details_checked" do
          it "sets the application state to overriding applicant_details_checked result" do
            expect { patch_request }.to change { application.reload.state }.to("applicant_details_checked")
          end
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        it "uses the non-passported state machine" do
          patch_request
          expect(application.reload.state_machine_proxy.type).to eq "NonPassportedStateMachine"
        end

        context "and the hmrc toggle is true" do
          it "calls the HMRC::CreateResponsesService" do
            patch_request
            expect(HMRC::CreateResponsesService).to have_received(:call).once
          end
        end

        context "and the hmrc toggle is false" do
          let(:enable_hmrc_collection) { false }

          it "doesn't call the HMRC::CreateResponsesService" do
            patch_request
            expect(HMRC::CreateResponsesService).not_to have_received(:call)
          end
        end

        it "successfully deletes any existing dwp override" do
          create(:dwp_override, legal_aid_application: application)
          patch_request
          expect(application.reload.dwp_override).to be_nil
        end
      end

      context "and the solicitor wants to override the results with a non joint benefit" do
        let(:application) { create(:legal_aid_application, :with_applicant_and_partner, :with_proceedings, :at_checking_applicant_details) }
        let(:partner) { application.partner }

        let(:params) do
          {
            continue_button: "Continue",
            partner: {
              confirm_dwp_result: "benefit_received",
            },
          }
        end

        context "when the status is already overriding_dwp_result" do
          before { application.override_dwp_result! }

          it { expect { patch_request }.not_to change { application.reload.state } }
        end

        context "when the state is not already override_dwp_result" do
          it "sets the application state to overriding DWP result" do
            expect { patch_request }.to change { application.reload.state }.to("overriding_dwp_result")
          end
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        it "does not update the partner shared benefit field" do
          patch_request
          expect(partner.reload.shared_benefit_with_applicant).to be false
        end

        it "uses the passported state machine" do
          patch_request
          expect(application.reload.state_machine_proxy.type).to eq "PassportedStateMachine"
        end

        it "calls the HMRC::CreateResponsesService" do
          patch_request
          expect(HMRC::CreateResponsesService).to have_received(:call)
        end
      end

      context "and the solicitor wants to override the results with a partner" do
        let(:application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_partner) }
        let(:partner) { application.partner }

        let(:params) do
          {
            continue_button: "Continue",
            partner: {
              confirm_dwp_result: "joint_benefit_with_partner",
            },
          }
        end

        it "sets the application state to overriding DWP result" do
          patch_request
          expect(application.reload.state).to eq "overriding_dwp_result"
        end

        it "sets the partner shared benefit field to true" do
          patch_request
          expect(partner.reload.shared_benefit_with_applicant).to be true
        end

        it "sets the applicant shared benefit field to true" do
          patch_request
          expect(application.reload.applicant.shared_benefit_with_partner).to be true
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        it "uses the passported state machine" do
          patch_request
          expect(application.reload.state_machine_proxy.type).to eq "PassportedStateMachine"
        end

        it "calls the HMRC::CreateResponsesService" do
          patch_request
          expect(HMRC::CreateResponsesService).to have_received(:call)
        end
      end

      context "and the solicitor does not select a radio button" do
        it "displays an error" do
          patch_request
          expect(response.body).to include("Select yes if your client gets a passporting benefit")
        end
      end
    end

    context "when submitting with the Save As Draft button" do
      subject(:patch_request) { patch providers_legal_aid_application_dwp_fallback_path(application), params: }

      let(:params) do
        {
          draft_button: "Save as draft",
        }
      end

      before do
        login_as application.provider
        allow(HMRC::CreateResponsesService).to receive(:call).with(application).and_return(instance_double(HMRC::CreateResponsesService, call: %w[one two]))
      end

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        patch_request
        expect(application.reload).to be_draft
      end

      it "does not call the HMRC::CreateResponsesService" do
        patch_request
        expect(HMRC::CreateResponsesService).not_to have_received(:call)
      end
    end
  end
end
