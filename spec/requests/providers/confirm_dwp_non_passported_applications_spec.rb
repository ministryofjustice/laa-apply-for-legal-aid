require "rails_helper"

RSpec.describe Providers::ConfirmDWPNonPassportedApplicationsController do
  let(:application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe "GET /providers/applications/:legal_aid_application_id/confirm_dwp_non_passported_applications" do
    subject { get "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications" }

    context "when the provider is not authenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as application.provider
        subject
      end

      it "returns success" do
        expect(response).to be_successful
      end
    end

    describe "back link" do
      let(:page1) { providers_legal_aid_application_check_provider_answers_path(application) }
      let(:page2) { providers_legal_aid_application_check_benefits_path(application) }

      before do
        login_as application.provider
        get page1
        get page2
        subject
      end

      it "points to check your answers page" do
        expect(response.body).to have_back_link("#{page1}&back=true")
      end
    end

    describe "HMRC inset text" do
      before { login_as application.provider }

      it "displays the HMRC inset text" do
        subject
        expect(unescaped_response_body).to include(I18n.t(".providers.confirm_dwp_non_passported_applications.show.hmrc_text"))
      end
    end

    context "when the application has a partner and the flag is turned on" do
      let(:application) { create(:legal_aid_application, :with_applicant_and_partner, :with_proceedings, :at_checking_applicant_details) }

      before do
        login_as application.provider
        allow(Setting).to receive(:partner_means_assessment?).and_return(true)
      end

      it "displays the joint passporting benefit option" do
        subject
        expect(unescaped_response_body).to include(I18n.t(".providers.confirm_dwp_non_passported_applications.show.option_partner"))
      end
    end

    context "when the application does not have a partner" do
      before { allow(Setting).to receive(:partner_means_assessment?).and_return(false) }

      it "does not display the joint passporting benefit option" do
        subject
        expect(unescaped_response_body).not_to include(I18n.t(".providers.confirm_dwp_non_passported_applications.show.option_partner"))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/confirm_dwp_non_passported_applications" do
    context "submitting with Continue button" do
      subject { patch "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications", params: }

      let(:params) do
        {
          continue_button: "Continue",
        }
      end

      before do
        login_as application.provider
        allow(HMRC::CreateResponsesService).to receive(:call).with(application).and_return(double(HMRC::CreateResponsesService, call: %w[one two]))
      end

      context "the results are correct" do
        let(:params) do
          {
            continue_button: "Continue",
            partner: {
              confirm_dwp_result: "dwp_correct",
            },
          }
        end

        it "transitions the application state to applicant details checked" do
          subject
          expect(application.reload.state).to eq "applicant_details_checked"
        end

        it "syncs the application" do
          expect(CleanupCapitalAttributes).to receive(:call).with(application)
          subject
        end

        it "displays the about financial means page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_about_financial_means_path(application))
        end

        it "uses the non-passported state machine" do
          subject
          expect(application.reload.state_machine_proxy.type).to eq "NonPassportedStateMachine"
        end

        it "calls the HMRC::CreateResponsesService" do
          subject
          expect(HMRC::CreateResponsesService).to have_received(:call).once
        end
      end

      context "the solicitor wants to override the results with a non joint benefit" do
        before { allow(Setting).to receive(:partner_means_assessment?).and_return(true) }

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
          subject
          expect(application.reload.state).to eq "overriding_dwp_result"
        end

        it "displays the check_client_details page" do
          subject
          expect(response).to redirect_to providers_legal_aid_application_check_client_details_path(application)
        end

        it "does not update the partner shared benefit field" do
          subject
          expect(partner.reload.shared_benefit_with_applicant).to be false
        end

        it "uses the passported state machine" do
          subject
          expect(application.reload.state_machine_proxy.type).to eq "PassportedStateMachine"
        end

        it "calls the HMRC::CreateResponsesService" do
          subject
          expect(HMRC::CreateResponsesService).to have_received(:call)
        end
      end

      context "the solicitor wants to override the results with a partner" do
        before { allow(Setting).to receive(:partner_means_assessment?).and_return(true) }

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
          subject
          expect(application.reload.state).to eq "overriding_dwp_result"
        end

        it "sets the partner shared benefit field to true" do
          subject
          expect(partner.reload.shared_benefit_with_applicant).to be true
        end

        it "displays the check_client_details page" do
          subject
          expect(response).to redirect_to providers_legal_aid_application_check_client_details_path(application)
        end

        it "uses the passported state machine" do
          subject
          expect(application.reload.state_machine_proxy.type).to eq "PassportedStateMachine"
        end

        it "calls the HMRC::CreateResponsesService" do
          subject
          expect(HMRC::CreateResponsesService).to have_received(:call)
        end
      end

      context "the solicitor does not select a radio button" do
        it "displays an error" do
          subject
          expect(response.body).to include(I18n.t("providers.confirm_dwp_non_passported_applications.show.error"))
        end
      end
    end

    context "submitting with Save As Draft button" do
      subject { patch "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications", params: }

      let(:params) do
        {
          draft_button: "Save as draft",
        }
      end

      before do
        login_as application.provider
        allow(HMRC::CreateResponsesService).to receive(:call).with(application).and_return(double(HMRC::CreateResponsesService, call: %w[one two]))
      end

      it "redirects provider to provider's applications page" do
        subject
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        subject
        expect(application.reload).to be_draft
      end

      it "does not call the HMRC::CreateResponsesService" do
        subject
        expect(HMRC::CreateResponsesService).not_to have_received(:call)
      end
    end
  end
end
