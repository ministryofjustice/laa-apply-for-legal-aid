require 'rails_helper'

RSpec.describe "Applicants", type: :request do
  describe "GET /provider/laa/:legal_aid_application_id/applicant/new" do

    let(:legal_aid_application) { create :application }

    it "works! (now write some real specs)" do
      get new_provider_legal_aid_application_applicant_path(legal_aid_application)
      expect(response).to have_http_status(200)
    end
  end
end
