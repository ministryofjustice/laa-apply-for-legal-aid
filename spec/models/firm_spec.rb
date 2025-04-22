require "rails_helper"

RSpec.describe "Firm" do
  let!(:firm) { create(:firm, name: "Testing, Test & Co") }

  describe "#permissions" do
    context "when there are no permissions" do
      let(:firm_with_no_permission) { create(:firm) }

      it "returns no permissions" do
        expect(firm_with_no_permission.reload.permissions).to eq []
      end
    end

    context "when there are permissions" do
      let!(:permission1) { create(:permission) }
      let!(:permission2) { create(:permission) }

      before do
        firm.permissions << permission2
        firm.permissions << permission1
        firm.save!
      end

      it "returns the correct permissions" do
        expect(firm.reload.permissions).to contain_exactly(permission2, permission1)
      end

      it "returns all permissions" do
        expect(firm.permissions.all).to contain_exactly(permission2, permission1)
      end

      it "fails occasionalley" do
        var = [1, 2, 3, 4].sample
        expect(var).to eq 2
      end
    end
  end

  describe "search" do
    let!(:firm2) { create(:firm, name: "Cage and Fish") }
    let!(:firm3) { create(:firm, name: "Harvey Birdman & Co.") }

    context "when searching for a single firm" do
      it "returns a single record" do
        expect(Firm.search("Harvey")).to eq([firm3])
      end
    end

    context "when no specific firm is searched for" do
      it "returns all records" do
        expect(Firm.search("")).to contain_exactly(firm3, firm2, firm)
      end
    end
  end
end
