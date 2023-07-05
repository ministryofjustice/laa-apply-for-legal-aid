require "rails_helper"

RSpec.describe Admin::RolesController do
  let(:admin_user) { create(:admin_user) }
  let!(:noodle_firm) { create(:firm, name: "Noodle, Legs & Co.") }
  let!(:mckenzie_firm) { create(:firm, name: "McKenzie, Brackman, Chaney and Kuzak") }
  let!(:mckenzie_gervais_firm) { create(:firm, name: "McKenzie, Crook, and Gervais") }
  let!(:nelson_firm) { create(:firm, name: "Nelson and Murdock") }

  before { sign_in admin_user }

  describe "GET index" do
    subject { get admin_roles_path }

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "displays correct heading" do
      subject
      expect(response.body).to include(I18n.t("admin.roles.index.heading_1"))
    end

    it "displays firms" do
      subject
      expect(unescaped_response_body).to include(noodle_firm.name)
      expect(response.body).to include(mckenzie_firm.name)
    end

    context "when the search field is used" do
      it "returns the relevant firm" do
        expect(Firm.search("Nelson")).to eq([nelson_firm])
      end

      it "returns all relevant firms" do
        expect(Firm.search("McKenzie")).to contain_exactly(mckenzie_firm, mckenzie_gervais_firm)
      end
    end
  end
end
