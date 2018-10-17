require 'rails_helper'

RSpec.describe "LegalAidApplications", type: :request do
  describe "GET /provider/laa" do
    it "works! (now write some real specs)" do
      get provider_legal_aid_applications_path
      expect(response).to have_http_status(200)
    end
  end
end
