require "rails_helper"
require Rails.root.join("spec/services/pda/provider_details_request_stubs")

RSpec.describe "provider selects office" do
  let(:provider) { create(:provider, :without_ccms_user_details, office_codes: "0X395U:2N078D:A123456", with_office_selected: false) }

  let(:body) do
    {
      firm: {
        firmId: 1639,
        ccmsFirmId: 12_345,
        firmName: "updated firm name",
      },
      office: {
        firmOfficeCode: "0X395U",
        ccmsFirmOfficeId: 56_789,
      },
      schedules:,
    }.to_json
  end

  let(:devolved_powers_status) { "Yes - Excluding JR Proceedings" }

  let(:schedules) do
    [
      {
        contractType: "Standard",
        contractStatus: "Open",
        contractAuthorizationStatus: "APPROVED",
        contractStartDate: "2024-09-01",
        contractEndDate: "2026-06-30",
        areaOfLaw: "LEGAL HELP",
        scheduleType: "Standard",
        scheduleAuthorizationStatus: "APPROVED",
        scheduleStatus: "Open",
        scheduleStartDate: "2024-09-01",
        scheduleEndDate: "2099-12-31",
        scheduleLines: [
          {
            areaOfLaw: "LEGAL HELP",
            categoryOfLaw: "MAT",
            description: "Legal Help (Civil).Family",
            devolvedPowersStatus: devolved_powers_status,
            dpTypeOfChange: nil,
            dpReasonForChange: nil,
            dpDateOfChange: nil,
            remainderWorkFlag: "N/A",
            minimumCasesAllowedCount: "0",
            maximumCasesAllowedCount: "0",
            minimumToleranceCount: "0",
            maximumToleranceCount: "0",
            minimumLicenseCount: "0",
            maximumLicenseCount: "1",
            workInProgressCount: "0",
            outreach: nil,
            cancelFlag: "N",
            cancelReason: nil,
            cancelDate: nil,
            closedDate: nil,
            closedReason: nil,
          },
        ],
        nmsAuths: [],
      },
    ]
  end

  around do |example|
    # We rely on webmock and stubs so we do not want to use VCR
    VCR.turned_off { example.run }
  end

  describe "GET providers/select_office" do
    subject(:get_request) { get providers_select_office_path }

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

      it "displays the offices of the provider from SILAS" do
        expect(unescaped_response_body).to include("0X395U")
        expect(unescaped_response_body).to include("2N078D")
        expect(unescaped_response_body).to include("A123456")
      end
    end
  end

  describe "PATCH providers/select_office" do
    subject(:patch_request) { patch providers_select_office_path, params: }

    let(:selected_office_code) { "0X395U" }

    let(:params) do
      {
        provider: { selected_office_code: },
      }
    end

    context "when the provider is not authenticated" do
      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when selected office is valid/viable" do
        before do
          stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{selected_office_code}/schedules")
            .to_return(body:, status: 200)

          stub_provider_user_for(provider.silas_id)

          allow(ProviderContractDetailsWorker)
            .to receive(:perform_async).and_return(true)

          patch_request
        end

        context "when the selected office has valid schedules" do
          it "updates the record" do
            expect(provider.reload.selected_office.code).to eq "0X395U"
          end

          it "redirects to the legal aid applications page" do
            expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
          end
        end

        context "when the selected office has no valid schedules" do
          let(:devolved_powers_status) { "No" }

          it "redirects to the invalid schedules page" do
            expect(response).to redirect_to providers_invalid_schedules_path
          end
        end
      end

      context "when selected office is NOT valid/viable" do
        before do
          stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{selected_office_code}/schedules")
            .to_return(body: nil, status: 204)

          allow(ProviderContractDetailsWorker)
            .to receive(:perform_async).and_return(true)

          patch_request
        end

        it "does not update the selected office" do
          expect(provider.reload.selected_office_id).to be_blank
        end

        it "redirects to the invalid schedules page" do
          expect(response).to redirect_to providers_invalid_schedules_path
        end
      end

      context "when office not selected" do
        let(:params) { {} }

        before { patch_request }

        it "returns http_success" do
          expect(response).to have_http_status(:ok)
        end

        it "the response includes the error message" do
          expect(response.body).to include("Select an account number")
        end
      end

      context "when CCMS User Management API returns user details" do
        before do
          stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{selected_office_code}/schedules")
            .to_return(body:, status: 200)

          stub_provider_user_for(provider.silas_id)

          allow(ProviderContractDetailsWorker)
            .to receive(:perform_async).and_return(true)
        end

        it "updates the ccms user details" do
          expect { patch_request }
            .to change { provider.reload.attributes.symbolize_keys }
              .from(
                hash_including(
                  {
                    ccms_contact_id: nil,
                    username: nil,
                  },
                ),
              ).to(
                hash_including(
                  {
                    ccms_contact_id: 66_731_970,
                    username: "DGRAY-BRUCE-DAVID-GRA-LLP1",
                  },
                ),
              )
        end

        it "redirects to the in_progress applications list page" do
          patch_request
          expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end

      context "when CCMS user details do not exist on the provider and CCMS User Management API raises NoUserFound" do
        before do
          stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{selected_office_code}/schedules")
            .to_return(body:, status: 200)

          stub_provider_user_failure_for(provider.silas_id, status: 404)

          allow(ProviderContractDetailsWorker)
            .to receive(:perform_async).and_return(true)
        end

        it "calls CCMS User Management API" do
          allow(CCMSUser::UserDetails).to receive(:call).and_call_original
          patch_request
          expect(CCMSUser::UserDetails).to have_received(:call)
        end

        it "redirects to user not found path" do
          patch_request
          expect(response).to redirect_to providers_user_not_founds_path
        end

        it "renders user not found interrupt page" do
          patch_request
          follow_redirect!

          expect(page).to have_css("h1", text: "Sorry, there was a problem getting your account information")
        end

        it "logs user not found error" do
          allow(Rails.logger).to receive(:error)
          patch_request
          expect(Rails.logger).to have_received(:error).with("Providers::SelectOfficesController - No CCMS username found for #{provider.email}")
        end

        it "sends user not found error to sentry" do
          allow(Sentry).to receive(:capture_message)
          patch_request
          expect(Sentry).to have_received(:capture_message).with("Providers::SelectOfficesController - No CCMS username found for #{provider.email}")
        end
      end

      context "when CCMS user details already exist on the provider" do
        before do
          provider.update!(ccms_contact_id: 111_111_111, username: "MY-CCMS-USERNAME")

          stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{selected_office_code}/schedules").to_return(body:, status: status)
          stub_provider_user_for(provider.silas_id)

          allow(ProviderContractDetailsWorker)
            .to receive(:perform_async).and_return(true)
        end

        it "still calls CCMS User Management API once to check for updates" do
          stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{selected_office_code}/schedules").to_return(body:, status: 200)
          allow(CCMSUser::UserDetails).to receive(:call).and_call_original
          patch_request
          expect(CCMSUser::UserDetails).to have_received(:call).once
        end

        context "with valid schedules" do
          before do
            stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{selected_office_code}/schedules")
              .to_return(body:, status: 200)
          end

          it "redirects to in_progress applications list page" do
            patch_request
            expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
          end

          it "renders in_progress applications list page" do
            patch_request
            expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
            follow_redirect!
            expect(response.body).to include("Your applications")
          end
        end

        context "with invalid schedules" do
          before do
            stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{selected_office_code}/schedules")
              .to_return(body: nil, status: 204)
          end

          it "redirects to invalid schedules" do
            patch_request
            expect(response).to redirect_to providers_invalid_schedules_path
          end

          it "renders invalid schedules" do
            patch_request
            follow_redirect!
            expect(page)
              .to have_css("h1", text: "You cannot use this service")
              .and have_content("The office you selected does not have")
          end
        end
      end
    end

    context "when mock auth enabled" do
      before do
        login_as provider
        allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth_enabled).and_return(true)
      end

      context "and host environment is production" do
        before do
          allow(HostEnv).to receive(:environment).and_return(:production)
        end

        it "calls the real PDA service" do
          a_double = instance_double(PDA::ProviderDetailsUpdater, call: nil, has_valid_schedules?: nil)

          allow(PDA::ProviderDetailsUpdater).to receive(:new).and_return(a_double)
          patch_request
          expect(PDA::ProviderDetailsUpdater).to have_received(:new)
        end
      end

      context "and host environment is NOT production" do
        before do
          allow(HostEnv).to receive(:environment).and_return(:staging)
        end

        it "calls the mock PDA service" do
          a_double = instance_double(PDA::MockProviderDetailsUpdater, call: nil, has_valid_schedules?: nil)
          allow(PDA::MockProviderDetailsUpdater).to receive(:new).and_return(a_double)
          patch_request
          expect(PDA::MockProviderDetailsUpdater).to have_received(:new)
        end
      end
    end
  end
end
