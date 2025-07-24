require "rails_helper"

RSpec.describe Providers::ConfirmDWPNonPassportedApplicationsController do
  let(:application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_address) }
  let(:application_id) { application.id }
  let(:enable_hmrc_collection) { true }

  before { allow(Setting).to receive(:collect_hmrc_data?).and_return(enable_hmrc_collection) }

  describe "GET /providers/applications/:legal_aid_application_id/confirm_dwp_non_passported_applications" do
    subject(:get_request) { get "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications" }

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

      context "when confirm_dwp_result is not nil" do
        before do
          application.confirm_dwp_result = "dwp_correct"
        end

        it "resets confirm_dwp_result to nil" do
          get_request
          expect(application.reload.confirm_dwp_result).to be_nil
        end
      end
    end

    describe "back link" do
      let(:page1) { providers_legal_aid_application_check_provider_answers_path(application) }
      let(:page2) { providers_legal_aid_application_check_benefit_path(application) }

      before do
        login_as application.provider
        get page1
        get page2
        get_request
      end

      it "points to check your answers page" do
        expect(response.body).to have_back_link("#{page1}&back=true")
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
        expect(unescaped_response_body).to include(I18n.t(".providers.confirm_dwp_non_passported_applications.show.option_partner"))
      end
    end

    context "when the application does not have a partner" do
      it "does not display the joint passporting benefit option" do
        get_request
        expect(unescaped_response_body).not_to include(I18n.t(".providers.confirm_dwp_non_passported_applications.show.option_partner"))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/confirm_dwp_non_passported_applications" do
    context "when submitting with the Continue button" do
      subject(:patch_request) { patch "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications", params: }

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
              confirm_dwp_result: "dwp_correct",
            },
          }
        end

        it "transitions the application state to applicant details checked" do
          patch_request
          expect(application.reload.state).to eq "applicant_details_checked"
        end

        it "sets the legal_aid_application confirm_dwp_result field to be dwp_correct" do
          patch_request
          expect(application.reload.confirm_dwp_result).to eq "dwp_correct"
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
              confirm_dwp_result: "joint_with_partner_false",
            },
          }
        end

        it "sets the application state to overriding DWP result" do
          patch_request
          expect(application.reload.state).to eq "overriding_dwp_result"
        end

        it "sets the legal_aid_application confirm_dwp_result field to be joint_with_partner_false" do
          patch_request
          expect(application.reload.confirm_dwp_result).to eq "joint_with_partner_false"
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
              confirm_dwp_result: "joint_with_partner_true",
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

        it "sets the legal_aid_application confirm_dwp_result field to be joint_with_partner_true" do
          patch_request
          expect(application.reload.confirm_dwp_result).to eq "joint_with_partner_true"
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
          expect(response.body).to include(I18n.t("providers.confirm_dwp_non_passported_applications.show.error"))
        end
      end
    end

    context "when submitting with the Save As Draft button" do
      subject(:patch_request) { patch "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications", params: }

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
