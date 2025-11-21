require "rails_helper"

RSpec.describe Providers::DWP::ResultsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_address, dwp_override:, dwp_result_confirmed:) }
  let(:dwp_result_confirmed) { nil }
  let(:dwp_override) { nil }
  let(:enable_hmrc_collection) { true }

  before { allow(Setting).to receive(:collect_hmrc_data?).and_return(enable_hmrc_collection) }

  describe "GET /providers/applications/:legal_aid_application_id/dwp/dwp-result" do
    subject(:get_request) { get providers_legal_aid_application_dwp_result_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as legal_aid_application.provider
        allow(HMRC::CreateResponsesService).to receive(:call).with(legal_aid_application).and_return(instance_double(HMRC::CreateResponsesService, call: %w[one two]))
      end

      it "returns success" do
        get_request
        expect(response).to be_successful
      end

      it "marks the applicant_details_checked!" do
        expect { get_request }.to change { legal_aid_application.reload.state }.from("checking_applicant_details").to("applicant_details_checked")
      end

      context "when the hmrc toggle is true" do
        it "calls the HMRC::CreateResponsesService" do
          get_request
          expect(HMRC::CreateResponsesService).to have_received(:call).once
        end
      end

      context "when the hmrc toggle is false" do
        let(:enable_hmrc_collection) { false }

        it "doesn't call the HMRC::CreateResponsesService" do
          get_request
          expect(HMRC::CreateResponsesService).not_to have_received(:call)
        end
      end

      context "when dwp_result_confirmed is not nil" do
        let(:dwp_result_confirmed) { false }

        it "resets dwp_result_confirmed to nil" do
          expect { get_request }
            .to change { legal_aid_application.reload.dwp_result_confirmed }
            .from(false)
            .to nil
        end
      end

      context "when there is an existing dwp_overide" do
        let(:dwp_override) { create(:dwp_override, :with_evidence) }

        it "removes any existing dwp_override" do
          get_request
          expect(legal_aid_application.reload.dwp_override).to be_nil
        end
      end

      context "when applicant has a partner" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_partner) }

        it "assigns target path to partner override path" do
          get_request
          expect(assigns(:override_path)).to eql providers_legal_aid_application_dwp_partner_override_path
        end
      end

      context "when applicant does not have a partner" do
        it "assigns target path to check client details path" do
          get_request
          expect(assigns(:override_path)).to eql providers_legal_aid_application_check_client_details_path
        end
      end

      context "when no benefit check has been added" do
        before do
          legal_aid_application.benefit_check_result.destroy! if legal_aid_application.benefit_check_result
          allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
        end

        let(:benefit_check_response) do
          {
            benefit_checker_status: "Yes",
            confirmation_ref: SecureRandom.hex,
          }
        end

        it "adds the expected benefit check result" do
          expect { get_request }
            .to change { legal_aid_application.reload.benefit_check_result&.attributes&.symbolize_keys }
              .from(nil)
              .to(hash_including(result: "Yes", dwp_ref: benefit_check_response[:confirmation_ref]))
        end
      end

      context "when benefit check has already been added" do
        before do
          create(:benefit_check_result, legal_aid_application:, dwp_ref: "old_ref", result: "No")
          legal_aid_application.applicant.touch
          allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
        end

        let(:benefit_check_response) do
          {
            benefit_checker_status: "Yes",
            confirmation_ref: "new_ref",
          }
        end

        it "updates the existing benefit check result" do
          expect { get_request }
            .to change { legal_aid_application.reload.benefit_check_result&.attributes&.symbolize_keys }
              .from(hash_including(result: "No", dwp_ref: "old_ref"))
              .to(hash_including(result: "Yes", dwp_ref: "new_ref"))
        end
      end

      context "when applicants details have changed since last benefit check" do
        before do
          create(:benefit_check_result, legal_aid_application:, dwp_ref: "old_ref", result: "No")
          legal_aid_application.applicant.touch
          allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
        end

        let(:benefit_check_response) do
          {
            benefit_checker_status: "Yes",
            confirmation_ref: "new_ref",
          }
        end

        it "queries the benefit check" do
          get_request
          expect(BenefitCheckService).to have_received(:call)
        end

        it "updates the existing benefit check result" do
          expect { get_request }
            .to change { legal_aid_application.reload.benefit_check_result&.attributes&.symbolize_keys }
              .from(hash_including(result: "No", dwp_ref: "old_ref"))
              .to(hash_including(result: "Yes", dwp_ref: "new_ref"))
        end
      end

      context "when applicants details have NOT changed since last benefit check" do
        before do
          create(:benefit_check_result, legal_aid_application:, dwp_ref: "old_ref", result: "No")
          allow(BenefitCheckService).to receive(:call)
        end

        it "does not query the benefit check" do
          get_request
          expect(BenefitCheckService).not_to have_received(:call)
        end

        it "does not update existing benefit check result" do
          expect { get_request }
            .not_to change { legal_aid_application.reload.benefit_check_result&.attributes&.symbolize_keys }
              .from(hash_including(result: "No", dwp_ref: "old_ref"))
        end
      end

      context "when applicants last name is very short" do
        before do
          legal_aid_application.benefit_check_result.destroy! if legal_aid_application.benefit_check_result
          legal_aid_application.applicant.update!(last_name: "Q")
          allow(BenefitCheckService).to receive(:call).with(legal_aid_application)
        end

        it "adds the benefit check as skipped" do
          expect { get_request }
            .to change { legal_aid_application.reload.benefit_check_result&.attributes&.symbolize_keys }
              .from(nil)
              .to(hash_including(result: "skipped:short_name", dwp_ref: nil))
        end
      end

      context "when applicants last name is very short but had previously not been" do
        before do
          create(:benefit_check_result, legal_aid_application:, dwp_ref: "old_ref", result: "Yes")
          legal_aid_application.applicant.update!(last_name: "Q")
          allow(BenefitCheckService).to receive(:call).with(legal_aid_application)
        end

        it "updates the existing benefit check to skipped" do
          expect { get_request }
            .to change { legal_aid_application.reload.benefit_check_result&.attributes&.symbolize_keys }
              .from(hash_including(result: "Yes", dwp_ref: "old_ref"))
              .to(hash_including(result: "skipped:short_name", dwp_ref: nil))
        end
      end

      context "when benefit checker data collection is off" do
        before do
          allow(Setting).to receive(:collect_dwp_data?).and_return(false)
        end

        it "does not add a benefit check result" do
          expect { get_request }
            .not_to change { legal_aid_application.reload.benefit_check_result }
              .from(nil)
        end
      end

      context "when benefit checker is down" do
        before do
          allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(false)
        end

        it "displays DWP down content" do
          get_request
          expect(page)
            .to have_content("There was a problem connecting to DWP")
        end
      end

      context "when benefit checker returns positive result" do
        before do
          allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
        end

        let(:benefit_check_response) do
          {
            benefit_checker_status: "Yes",
            confirmation_ref: "new_ref",
          }
        end

        it "displays DWP positive result content" do
          get_request
          expect(page)
            .to have_content("DWP records show that your client receives a passporting benefit")
            .and have_button("Save and continue")
        end
      end

      context "when benefit checker returns negative result" do
        before do
          allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
        end

        let(:benefit_check_response) do
          {
            benefit_checker_status: "Undetermined",
            confirmation_ref: "new_ref",
          }
        end

        # Question: what if they have previously provided DWP evidence but have back paged.
        # see `applicant_receives_benefit?` - edge case issue!?
        it "displays DWP negative result content" do
          get_request
          expect(page)
            .to have_content("DWP records show that your client does not get a passporting benefit. Is this correct?")
            .and have_button("Yes, continue")
            .and have_link("This is not correct")
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/dwp/dwp-result" do
    subject(:patch_request) { patch providers_legal_aid_application_dwp_result_path(legal_aid_application), params: }

    let(:params) do
      {
        continue_button: "Continue",
      }
    end

    before do
      login_as legal_aid_application.provider
    end

    it "redirects to the next page" do
      patch_request
      expect(response).to have_http_status(:redirect)
    end

    it "updates confirm_dwp_result to true" do
      expect { patch_request }
        .to change { legal_aid_application.reload.dwp_result_confirmed }
        .from(nil)
        .to true
    end
  end
end
