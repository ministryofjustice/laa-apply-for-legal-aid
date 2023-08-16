require "rails_helper"

RSpec.describe "Audit console" do
  let(:admin_user) { create(:admin_user) }

  describe "GET index" do
    subject(:get_index) { get admin_audits1984_path }

    before do
      sign_in admin_user
    end

    it "renders successfully" do
      get_index
      expect(response).to have_http_status(:ok)
    end
  end
end
