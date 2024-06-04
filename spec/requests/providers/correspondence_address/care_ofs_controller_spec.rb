require "rails_helper"

RSpec.describe Providers::CorrespondenceAddress::CareOfsController do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, :with_address) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/care_of" do
    subject(:get_request) { get providers_legal_aid_application_correspondence_address_care_of_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "shows the care ofs page" do
        expect(response).to be_successful
        expect(unescaped_response_body).to include("Do you want to add a 'care of' recipient for your client's mail?")
      end
    end
  end
end
