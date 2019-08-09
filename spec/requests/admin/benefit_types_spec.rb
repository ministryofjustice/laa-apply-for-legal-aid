require 'rails_helper'

RSpec.describe "Admin::BenefitTypes", type: :request do
  describe "GET /admin/benefit_types" do
    it "works! (now write some real specs)" do
      get admin_benefit_types_index_path
      expect(response).to have_http_status(200)
    end
  end
end
