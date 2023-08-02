require "rails_helper"

module Admin
  RSpec.describe ProvidersController do
    let(:admin_user) { create(:admin_user) }

    before { sign_in admin_user }

    describe "GET index" do
      let(:my_firm) { Firm.create(name: "Me, Myself and I Ltd.") }
      let(:your_firm) { Firm.create(name: "You and Yours Partners") }

      before do
        create(:provider, username: "Johnny Me", firm: my_firm)
        create(:provider, username: "Amy Me", firm: my_firm)
        create(:provider, username: "Edward Yu", firm: your_firm)

        get admin_firm_providers_path(firm_id)
      end

      context "with all firms" do
        let(:firm_id) { "0" }

        it "displays an appropriate heading" do
          expect(response.body).to include("All provider users")
        end

        it "displays all providers" do
          expect(response.body).to include("Johnny Me")
          expect(response.body).to include("Amy Me")
          expect(response.body).to include("Edward Yu")
        end
      end

      context "with firm specified" do
        let(:firm_id) { my_firm.id }

        it "displays a heading mentioning the firm name" do
          expect(response.body).to include("Provider users for firm Me, Myself and I Ltd.")
        end

        it "displays just the provider for that firm" do
          expect(response.body).to include("Johnny Me")
          expect(response.body).to include("Amy Me")
          expect(response.body).not_to include("Edward Yu")
        end
      end
    end
  end
end
