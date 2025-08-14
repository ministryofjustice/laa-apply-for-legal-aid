require "rails_helper"

RSpec.describe "provider selects office" do
  let(:provider) { create(:provider, office_codes: "0X395U:2N078D:A123456") }

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
        scheduleEndDate: "2025-08-31",
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

  let(:user) do
    {
      user: {
        userId: 98_765,
        ccmsContactId: 87_654,
        userLogin: provider.username,
      },
    }.to_json
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

      it "does not display offices belonging to the firm but not the provider", skip: "is this a requirement?" do
        expect(unescaped_response_body).not_to include(third_office.code)
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

          stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-users/#{provider.username}")
            .to_return(body: user, status: 200)

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

        it "does not update the select office" do
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

      context "when the user cannot be found" do
        before do
          stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{selected_office_code}/schedules")
            .to_return(body:, status: 200)

          stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-users/#{provider.username}")
            .to_return(body: nil, status: 204)

          allow(ProviderContractDetailsWorker)
            .to receive(:perform_async).and_return(true)

          patch_request
        end

        it "renders the page with flash message" do
          expect(response).to render_template :show
          expect(flash[:error]).to eq "No CCMS username found for #{provider.email}"
        end
      end
    end
  end
end
