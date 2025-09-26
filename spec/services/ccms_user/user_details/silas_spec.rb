require "rails_helper"
require Rails.root.join("spec/services/pda/provider_details_request_stubs")

RSpec.describe CCMSUser::UserDetails::Silas do
  let(:provider) { create(:provider) }
  let(:uri) { "#{Rails.configuration.x.ccms_user_api.url}/user-details/silas/#{provider.silas_id}" }

  describe ".call" do
    subject(:call) { described_class.call(provider.silas_id) }

    context "with successful response" do
      before do
        stub_provider_user_for(provider.silas_id)
      end

      it "makes one external call" do
        call
        expect(a_request(:get, uri)).to have_been_made.times(1)
      end

      it "returns hash with expected keys" do
        result = call
        expect(result.keys).to include("ccmsUserDetails")
        expect(result["ccmsUserDetails"].keys).to include("userPartyId", "userName")
      end
    end

    context "with not found response" do
      before do
        stub_provider_user_failure_for(provider.silas_id, status: 404)
      end

      it "raises error" do
        expect { call }.to raise_error(described_class::UserNotFound, "No CCMS username found for #{provider.email}")
      end
    end

    context "with forbidden response" do
      before do
        stub_provider_user_failure_for(provider.silas_id, status: 403, body: "<body>403 Forbidden</body>")
      end

      it "raises error" do
        # ApiError, "API Call Failed: (#{response.status}) #{response.body}"
        expect { call }.to raise_error(described_class::ApiError, "API Call Failed: status 403, body <body>403 Forbidden</body>")
      end
    end

    context "with internal server error response" do
      before do
        stub_provider_user_failure_for(provider.silas_id, status: 500)
      end

      it "raises error" do
        # ApiError, "API Call Failed: (#{response.status}) #{response.body}"
        expect { call }.to raise_error(described_class::ApiError, "API Call Failed: status 500, body nil")
      end
    end
  end
end
