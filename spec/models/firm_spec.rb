require "rails_helper"

RSpec.describe Firm, type: :model do
  describe ".search" do
    context "when a search term is given" do
      it "returns firms whose name matches the search term" do
        _firm1 = create(:firm, name: "Testing, Test & Co.")
        firm2 = create(:firm, name: "Cage and Fish")
        firm3 = create(:firm, name: "Fish & Co.")
        search_term = "Fish"

        firms = described_class.search(search_term)

        expect(firms).to contain_exactly(firm2, firm3)
      end
    end

    context "when the search term is empty" do
      it "returns all firms" do
        firm1 = create(:firm, name: "Testing, Test & Co")
        firm2 = create(:firm, name: "Cage and Fish")
        search_term = ""

        firms = described_class.search(search_term)

        expect(firms).to contain_exactly(firm1, firm2)
      end
    end
  end

  describe ".after_commit callback" do
    context "when a firm is created" do
      it "fires the dashboard.firm_created event" do
        firm = build(:firm)
        allow(ActiveSupport::Notifications).to receive(:instrument)

        firm.save!

        expect(ActiveSupport::Notifications).to have_received(:instrument).with("dashboard.firm_created")
      end
    end

    context "when a firm is updated" do
      it "does not fire the dashboard.firm_created event" do
        firm = create(:firm)
        allow(ActiveSupport::Notifications).to receive(:instrument)

        firm.update!(name: "Updated Co.")

        expect(ActiveSupport::Notifications).not_to have_received(:instrument).with("dashboard.firm_created")
      end
    end
  end

  describe "#permissions" do
    context "when there are no permissions set" do
      it "returns the default permission" do
        default_permission = create(:permission, :passported)
        firm = create(:firm, :with_no_permissions)

        permissions = firm.permissions

        expect(permissions).to contain_exactly(default_permission)
      end
    end

    context "when there are permissions set" do
      it "returns the correct permissions" do
        default_permission = create(:permission, :passported)
        employed_permission = create(:permission, :employed)
        firm = create(:firm, :with_no_permissions)
        firm.permissions << employed_permission
        firm.save!

        permissions = firm.permissions

        expect(permissions).to contain_exactly(default_permission, employed_permission)
      end
    end
  end
end
