require "rails_helper"
require "sidekiq/testing"

RSpec.describe SamlSessionsController do
  let(:firm) { create(:firm, offices: [office]) }
  let(:office) { create(:office) }
  let(:provider) { create(:provider, firm:, selected_office: office, offices: [office], username:) }
  let(:username) { "bob the builder" }
  let(:firm_id) { "3959183" }
  let(:provider_details_api_url) { "#{Rails.configuration.x.pda.url}/provider-users/#{username.gsub(' ', '%20')}/provider-offices" }
  let(:provider_firms_api_url) { "#{Rails.configuration.x.pda.url}/provider-firms/#{firm_id}/provider-offices" }
  let(:provider_details_api_response) { api_response.to_json }
  let(:enable_mock_saml) { false }

  before do
    allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return(enable_mock_saml)
    Redis.new(url: Rails.configuration.x.redis.page_history_url).flushdb
  end

  describe "DELETE /providers/sign_out" do
    subject(:delete_request) { delete destroy_provider_session_path }

    before { sign_in provider }

    it "logs user out" do
      delete_request
      expect(controller.current_provider).to be_nil
    end

    it "records id of logged out provider in session" do
      delete_request
      expect(session["signed_out"]).to be true
    end

    it "records the signout page as the feedback return path" do
      delete_request
      expect(session["feedback_return_path"]).to eq destroy_provider_session_path
    end

    it "redirects to the feedback page" do
      delete_request
      expect(response).to redirect_to(new_feedback_path)
      follow_redirect!
      expect(page).to have_content(I18n.t("saml_sessions.destroy.notice"))
    end
  end

  describe "POST /providers/saml/auth" do
    subject(:post_request) { post provider_session_path }

    before do
      allow_any_instance_of(Warden::Proxy).to receive(:authenticate!).and_return(provider)
      stub_request(:get, provider_details_api_url).to_return(body: provider_details_api_response, status:)
      stub_request(:get, provider_firms_api_url).to_return(body: firm_response.to_json, status:)
    end

    context "when on staging or production" do
      before { allow(HostEnv).to receive(:staging_or_production?).and_return(true) }

      context "and it's the first time signing in" do
        context "and the provider has the CCMS_Apply role" do
          let(:api_response) { raw_details_response }
          let(:status) { 200 }
          let(:provider) { create(:provider, :created_by_devise, :with_ccms_apply_role, username:) }

          it "calls the Provider details api" do
            expect(PDA::ProviderDetailsCreator).to receive(:call).with(provider).and_call_original
            post_request
          end

          it "updates the record with firm and offices" do
            post_request
            firm = Firm.find_by(ccms_id: raw_details_response.dig(:firm, :ccmsFirmId))
            expect(provider.firm_id).to eq firm.id
            expect(firm.offices.size).to eq 1
            expect(firm.offices.first.ccms_id).to eq raw_details_response[:officeCodes].first[:ccmsFirmOfficeId].to_s
          end

          context "when mock_saml is activated" do
            let(:enable_mock_saml) { true }

            it "displays the select office page" do
              post_request
              expect(response).to redirect_to providers_confirm_office_path
            end
          end

          it "displays the root page" do
            post_request
            expect(response).to redirect_to root_path
          end
        end

        context "and the provider does not have the CCMS_Apply role" do
          let(:api_response) { raw_details_response }
          let(:status) { 200 }
          let(:provider) { create(:provider, :created_by_devise, :without_ccms_apply_role, username:) }

          before { allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return(false) }

          it "does not call the ProviderDetailsCreator" do
            expect(PDA::ProviderDetailsCreator).not_to receive(:call)
            post_request
          end

          it "updates the provider record with invalid login details" do
            post_request
            expect(provider.invalid_login_details).to eq "role"
          end

          it "redirects to the root path" do
            post_request
            expect(response).to redirect_to root_path
          end
        end

        context "and the provider does not exist on Provider details api" do
          let(:api_response) { blank_response }
          let(:status) { 204 }
          let(:provider) { create(:provider, :created_by_devise, :with_ccms_apply_role, username:) }

          it "calls the Provider details creator" do
            expect(PDA::ProviderDetailsCreator).to receive(:call).with(provider).and_call_original
            post_request
          end

          it "updates the invalid login details on the provider record" do
            post_request
            expect(provider.invalid_login_details).to eq "api_details_user_not_found"
          end

          it "redirects to the start page" do
            post_request
            expect(response).to redirect_to root_path
          end
        end

        context "and the Provider details api is down" do
          let(:status) { 502 }
          let(:api_response) { blank_response }
          let(:provider) { create(:provider, :created_by_devise, :with_ccms_apply_role, username:) }

          it "updates the invalid login details on the provider record" do
            post_request
            expect(provider.invalid_login_details).to eq "provider_details_api_error"
          end
        end
      end

      context "and it's not the first time signing in" do
        let(:api_response) { raw_details_response }
        let(:status) { 200 }
        let(:provider) { create(:provider, :with_ccms_apply_role, username:) }

        before { allow(HostEnv).to receive(:staging_or_production?).and_return(true) }

        it "uses a worker to update details" do
          ProviderDetailsCreatorWorker.clear
          expect(ProviderDetailsCreatorWorker).to receive(:perform_async).with(provider.id).and_call_original
          expect(PDA::ProviderDetailsCreator).to receive(:call).with(provider).and_call_original
          post_request
          ProviderDetailsCreatorWorker.drain
        end

        it "redirects to start page" do
          post_request
          expect(response).to redirect_to root_path
        end
      end

      context "when on test or development" do
        context "and it's the first time signing in" do
          let(:api_response) { raw_details_response }
          let(:status) { 200 }
          let(:provider) { create(:provider, :created_by_devise, :with_ccms_apply_role, username:) }

          it "calls the Provider details api" do
            expect(PDA::ProviderDetailsCreator).to receive(:call).with(provider).and_call_original
            post_request
          end

          it "updates the record with firm and offices" do
            post_request
            firm = Firm.find_by(ccms_id: raw_details_response.dig(:firm, :ccmsFirmId))
            expect(provider.firm_id).to eq firm.id
            expect(firm.offices.size).to eq 1
            expect(firm.offices.first.ccms_id).to eq raw_details_response[:officeCodes].first[:ccmsFirmOfficeId].to_s
          end

          it "displays the start page" do
            post_request
            expect(response).to redirect_to root_path
          end
        end

        context "and it's not the first time signing in" do
          let(:api_response) { raw_details_response }
          let(:status) { 200 }
          let(:provider) { create(:provider, :with_ccms_apply_role, username:) }

          before { allow(HostEnv).to receive(:staging_or_production?).and_return(false) }

          it "does not schedule a job to update the provider details" do
            expect(provider).to receive(:update_details).and_call_original
            expect(ProviderDetailsCreatorWorker).not_to receive(:perform_async).with(provider.id)
            expect(PDA::ProviderDetailsCreator).not_to receive(:call).with(provider)
            post_request
          end
        end
      end
    end
  end

  describe "Login failed at LAA Portal" do
    subject(:post_request) { post provider_session_path }

    before { allow_any_instance_of(Devise::SessionsController).to receive(:create).and_raise(StandardError) }

    it "redirects to access denied" do
      post_request
      expect(response).to redirect_to(error_path(:access_denied))
    end
  end

  def raw_details_response
    {
      firm: {
        firmId: 3_959_183,
        firmNumber: "50736",
        ccmsFirmId: 10_835_831,
        firmName: "DT SCRIPT PROVIDER 1",
      },
      user: {
        userId: 454_031,
        ccmsContactId: 0,
        userLogin: "DT_SCRIPT_USER1",
        name: "Dts User1",
        emailAddress: "deepak.tanna@digital.justice.gov.uk",
        portalStatus: "Active",
      },
      officeCodes: [
        {
          firmOfficeId: 145_434,
          ccmsFirmOfficeId: 34_406_595,
          firmOfficeCode: "2Q242F",
          officeName: "2Q242F,1 Skyscraper",
          officeCodeAlt: "DT Script Office 1",
        },
      ],
    }
  end

  def firm_response
    {
      firm: {
        firmId: 3_959_183,
        firmNumber: "50736",
        ccmsFirmId: 10_835_831,
        firmName: "DT SCRIPT PROVIDER 1",
      },
      offices: [
        {
          firmOfficeId: 145_434,
          ccmsFirmOfficeId: 34_406_595,
          firmOfficeCode: "2Q242F",
          officeName: "2Q242F,1 Skyscraper",
          officeCodeAlt: "DT Script Office 1",
          addressLine1: "1 Skyscraper",
          addressLine2: "1 Some Road",
          addressLine3: "",
          addressLine4: "",
          city: "Metropolis",
          county: "",
          postCode: "LE1 1AA",
          dxCentre: "",
          dxNumber: "",
          telephoneAreaCode: "01162",
          telephoneNumber: "555124",
          faxAreaCode: "",
          faxNumber: "",
          emailAddress: "me@email.uk",
          vatRegistrationNumber: "",
          type: "Legal Services Provider",
          headOffice: "N/A",
          creationDate: "2023-11-10",
          lscRegion: "Midlands",
          lscBidZone: "Leicester",
          lscAreaOffice: "Nottingham",
          cjsForceName: "Leicestershire",
          localAuthority: "City of Leicester",
          policeStationAreaName: "Leicester",
          dutySolicitorAreaName: "Leicester",
        },
      ],
    }
  end

  def blank_response
    ""
  end
end
